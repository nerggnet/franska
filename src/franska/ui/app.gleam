//// The app's state, update and view. The clock, shuffling and speech
//// support come in through `Env`, so `update` can be tested with a fixed
//// clock and no randomness. Effects (storage, speech, focus) go through
//// `franska/ui/browser` and only run in the browser.

import franska/answer.{type Grade, Almost, Correct, Wrong}
import franska/content
import franska/exercise.{
  type Drill, type Exercise, Adjectives, Agree, Articles, ChooseArticle,
  Conjugate, Conjugation, Dictation, FillGap, Listen, Numbers, Sentences,
  ToFrench, ToSwedish, Translate, TranslateToFrench, TranslateToSwedish,
  WriteNumber,
}
import franska/gender
import franska/lexicon
import franska/progress.{type Progress, Progress}
import franska/session.{type Session}
import franska/srs
import franska/ui/browser
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre/attribute.{attribute, class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event

const round_size = 10

/// Dagens repetition covers everything due, but not more than this at once.
const review_size = 20

const answer_input_id = "answer"

const import_input_id = "import-file"

pub const storage_key = "franska:progress"

const accents = ["é", "è", "ê", "ë", "à", "â", "ç", "î", "ï", "ô", "ù", "û", "œ"]

// MODEL -----------------------------------------------------------------------

/// What the app needs from the outside world.
pub type Env {
  Env(
    /// Unix time in seconds.
    now: fn() -> Int,
    /// Local day number (days since 1970-01-01).
    today: fn() -> Int,
    shuffle: fn(List(Exercise)) -> List(Exercise),
    can_speak: Bool,
  )
}

/// `theme` is the chosen theme, or `None` for all themes. `round` is the
/// kind of the current or last round, so "Öva igen" repeats it.
pub type Model {
  Model(
    env: Env,
    drill: Drill,
    theme: Option(String),
    progress: Progress,
    round: Round,
    screen: Screen,
  )
}

pub type Round {
  /// The drill and theme chosen in the menu.
  DrillRound
  /// Dagens repetition: everything due.
  ReviewRound
  /// Svåra ord: the exercises with the most mistakes.
  DifficultRound
}

pub type Screen {
  Menu
  Practising(session: Session, input: String, grade: Option(Grade))
  Finished(session: Session)
  Statistics(confirming_reset: Bool, notice: Option(Notice))
}

pub type Notice {
  Imported
  CouldNotImport
}

pub fn init(flags: #(Env, Progress)) -> #(Model, Effect(Msg)) {
  let #(env, progress) = flags
  #(
    Model(
      env:,
      drill: TranslateToFrench,
      theme: None,
      progress:,
      round: DrillRound,
      screen: Menu,
    ),
    effect.none(),
  )
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  UserPickedDrill(Drill)
  UserPickedTheme(Option(String))
  UserToggledReadAloud(Bool)
  UserStartedRound
  UserStartedReview
  UserStartedDifficultRound
  UserTypedAnswer(String)
  UserPressedAccent(String)
  UserChoseAnswer(String)
  UserSubmittedAnswer
  UserAskedToHear(String)
  UserQuitRound
  UserOpenedStatistics
  UserAskedToReset
  UserConfirmedReset
  UserCancelledReset
  UserExportedProgress
  UserChoseImportFile
  ImportFileRead(String)
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case model.screen, msg {
    Menu, UserPickedDrill(drill) -> {
      // Keep the theme only if the new drill has exercises for it.
      let theme = case model.theme {
        Some(theme) ->
          case list.contains(content.themes_for(drill), theme) {
            True -> Some(theme)
            False -> None
          }
        None -> None
      }
      #(Model(..model, drill:, theme:), effect.none())
    }

    Menu, UserPickedTheme(theme) -> #(Model(..model, theme:), effect.none())

    Menu, UserToggledReadAloud(read_aloud) ->
      update_progress(model, Progress(..model.progress, read_aloud:))

    Menu, UserStartedRound | Finished(..), UserStartedRound -> {
      // Shuffle first so new exercises come in random order, and again so
      // the round does not start with all the reviews.
      let session =
        content.exercises(model.drill, model.theme)
        |> model.env.shuffle
        |> progress.plan_round(
          model.progress,
          _,
          now: model.env.now(),
          size: round_size,
        )
        |> model.env.shuffle
        |> session.new
      show_exercise(Model(..model, round: DrillRound), session)
    }

    Menu, UserStartedReview | Finished(..), UserStartedReview -> {
      let session =
        content.all_exercises()
        |> progress.due(model.progress, _, now: model.env.now())
        |> list.take(review_size)
        |> model.env.shuffle
        |> session.new
      case session.is_finished(session) {
        True -> #(Model(..model, screen: Menu), effect.none())
        False -> show_exercise(Model(..model, round: ReviewRound), session)
      }
    }

    Statistics(..), UserStartedDifficultRound
    | Finished(..), UserStartedDifficultRound
    -> {
      let session =
        progress.difficult(model.progress, content.all_exercises())
        |> list.take(round_size)
        |> list.map(fn(pair) { pair.0 })
        |> model.env.shuffle
        |> session.new
      case session.is_finished(session) {
        True -> #(model, effect.none())
        False -> show_exercise(Model(..model, round: DifficultRound), session)
      }
    }

    Practising(grade: None, ..) as screen, UserTypedAnswer(input) -> #(
      Model(..model, screen: Practising(..screen, input:)),
      effect.none(),
    )

    Practising(grade: None, ..), UserPressedAccent(accent) -> #(
      model,
      insert_accent(accent),
    )

    Practising(session:, grade: None, ..), UserChoseAnswer(input) ->
      check_answer(model, session, input)

    Practising(session:, input:, grade: None), UserSubmittedAnswer ->
      check_answer(model, session, input)

    Practising(session:, grade: Some(grade), ..), UserSubmittedAnswer -> {
      let session = session.record(session, grade)
      case session.is_finished(session) {
        True -> #(Model(..model, screen: Finished(session:)), effect.none())
        False -> show_exercise(model, session)
      }
    }

    Practising(..), UserAskedToHear(text) -> #(model, speak_effect(text))

    Practising(..), UserQuitRound
    | Finished(..), UserQuitRound
    | Statistics(..), UserQuitRound
    -> #(Model(..model, screen: Menu), effect.none())

    Menu, UserOpenedStatistics -> #(statistics(model, None), effect.none())

    Statistics(..), UserAskedToReset -> #(
      Model(..model, screen: Statistics(confirming_reset: True, notice: None)),
      effect.none(),
    )

    Statistics(..), UserCancelledReset -> #(
      statistics(model, None),
      effect.none(),
    )

    Statistics(confirming_reset: True, ..), UserConfirmedReset -> {
      // Only learning progress is reset; the read-aloud setting stays.
      let fresh =
        Progress(..progress.new(), read_aloud: model.progress.read_aloud)
      let #(model, save) = update_progress(model, fresh)
      #(statistics(model, None), save)
    }

    Statistics(..), UserExportedProgress -> #(
      model,
      export_effect(model.progress),
    )

    Statistics(..), UserChoseImportFile -> #(model, read_import_effect())

    Statistics(..), ImportFileRead(text) ->
      case progress.from_json(text) {
        Ok(imported) -> {
          let #(model, save) = update_progress(model, imported)
          #(statistics(model, Some(Imported)), save)
        }
        Error(Nil) -> #(statistics(model, Some(CouldNotImport)), effect.none())
      }

    _, _ -> #(model, effect.none())
  }
}

fn statistics(model: Model, notice: Option(Notice)) -> Model {
  Model(..model, screen: Statistics(confirming_reset: False, notice:))
}

fn update_progress(model: Model, progress: Progress) -> #(Model, Effect(Msg)) {
  #(Model(..model, progress:), save_effect(progress))
}

fn show_exercise(model: Model, session: Session) -> #(Model, Effect(Msg)) {
  let screen = Practising(session:, input: "", grade: None)
  // Dictation is always read out; a French prompt is if read-aloud is on.
  let speech = case session.current(session), model.progress.read_aloud {
    Ok(exercise), _ if exercise.kind == Listen -> speak_effect(exercise.french)
    Ok(exercise), True if exercise.kind == Translate(ToSwedish) ->
      speak_effect(exercise.french)
    _, _ -> effect.none()
  }
  #(Model(..model, screen:), effect.batch([focus_answer(), speech]))
}

fn check_answer(
  model: Model,
  session: Session,
  input: String,
) -> #(Model, Effect(Msg)) {
  case session.current(session), string.trim(input) {
    _, "" | Error(Nil), _ -> #(model, focus_answer())
    Ok(exercise), _ -> {
      let grade = exercise.check(exercise, input)
      // Only first attempts count: a retry comes right after the answer.
      let #(model, save) = case session.is_first_attempt(session, exercise) {
        True ->
          model.progress
          |> progress.record(
            exercise.id,
            grade,
            now: model.env.now(),
            today: model.env.today(),
          )
          |> update_progress(model, _)
        False -> #(model, effect.none())
      }
      // Hear the right French after answering, unless it was just read out.
      let speech = case model.progress.read_aloud, exercise.kind {
        True, Translate(ToSwedish) | True, Listen | False, _ -> effect.none()
        True, _ -> speak_effect(exercise.french)
      }
      let screen = Practising(session:, input:, grade: Some(grade))
      #(Model(..model, screen:), effect.batch([focus_answer(), speech, save]))
    }
  }
}

fn focus_answer() -> Effect(Msg) {
  use _, _ <- effect.after_paint
  browser.focus(answer_input_id)
}

fn insert_accent(accent: String) -> Effect(Msg) {
  use dispatch <- effect.from
  dispatch(UserTypedAnswer(browser.insert_at_cursor(answer_input_id, accent)))
}

fn save_effect(progress: Progress) -> Effect(Msg) {
  use _ <- effect.from
  browser.save(storage_key, progress.to_json(progress))
  browser.request_persistence()
}

fn export_effect(progress: Progress) -> Effect(Msg) {
  use _ <- effect.from
  browser.download("franska-framsteg", progress.to_json(progress))
}

fn read_import_effect() -> Effect(Msg) {
  use dispatch <- effect.from
  use text <- browser.read_chosen_file(import_input_id)
  dispatch(ImportFileRead(text))
}

fn speak_effect(text: String) -> Effect(Msg) {
  use _ <- effect.from
  browser.speak(text)
}

// VIEW ------------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  html.main([class("app")], [
    html.header([class("header")], [
      html.h1([], [html.text("Franska")]),
      html.p([class("tagline")], [html.text("Öva franska, en fras i taget")]),
    ]),
    case model.screen {
      Menu -> view_menu(model)
      Practising(session:, input:, grade:) ->
        case session.current(session) {
          Ok(exercise) ->
            view_exercise(model.env, session, exercise, input, grade)
          Error(Nil) -> element.none()
        }
      Finished(session:) -> view_finished(session, model.round)
      Statistics(confirming_reset:, notice:) ->
        view_statistics(
          model.progress,
          available_drills(model.env),
          model.env.now(),
          confirming_reset,
          notice,
        )
    },
  ])
}

fn view_menu(model: Model) -> Element(Msg) {
  let themes = content.themes_for(model.drill)
  let stats =
    progress.stats(
      model.progress,
      content.exercises(model.drill, model.theme),
      now: model.env.now(),
    )
  let streak = progress.streak_days(model.progress, model.env.today())
  let due_everywhere =
    list.length(progress.due(
      model.progress,
      content.all_exercises(),
      now: model.env.now(),
    ))

  element.fragment([
    case due_everywhere {
      0 -> element.none()
      due -> view_review_banner(due)
    },
    view_drill_picker(model, themes, stats, streak),
  ])
}

fn view_review_banner(due: Int) -> Element(Msg) {
  let size = int.min(due, review_size)
  html.section([class("card review")], [
    html.div([], [
      html.h2([], [html.text("Dagens repetition")]),
      html.p([], [
        html.text(
          plural(due, "övning", "övningar")
          <> " från alla delar väntar på repetition."
          <> case due > review_size {
            True -> " Vi tar " <> int.to_string(size) <> " i taget."
            False -> ""
          },
        ),
      ]),
    ]),
    html.button([class("primary"), event.on_click(UserStartedReview)], [
      html.text("Repetera"),
    ]),
  ])
}

fn view_drill_picker(
  model: Model,
  themes: List(String),
  stats: progress.Stats,
  streak: Int,
) -> Element(Msg) {
  let group = fn(heading: String, group: DrillGroup) {
    let drills =
      list.filter(available_drills(model.env), fn(drill) {
        drill_group(drill) == group
      })
    element.fragment([
      html.h2([class("subheading")], [html.text(heading)]),
      html.div(
        [class("chips")],
        list.map(drills, fn(drill) {
          chip(chip_label(drill), drill == model.drill, UserPickedDrill(drill))
        }),
      ),
    ])
  }

  html.section([class("card")], [
    html.h2([], [html.text("Vad vill du öva?")]),
    group("Ord", WordDrills),
    group("Grammatik", GrammarDrills),
    group("Böj verb", VerbDrills),
    // A single theme is not worth choosing between.
    case themes {
      [] | [_] -> element.none()
      _ ->
        element.fragment([
          html.h2([class("subheading")], [html.text("Tema")]),
          html.div([class("chips")], [
            chip("Alla", model.theme == None, UserPickedTheme(None)),
            ..list.map(themes, fn(theme) {
              chip(
                string.capitalise(theme),
                model.theme == Some(theme),
                UserPickedTheme(Some(theme)),
              )
            })
          ]),
        ])
    },
    case model.env.can_speak {
      True ->
        html.label([class("toggle")], [
          html.input([
            attribute.type_("checkbox"),
            attribute.checked(model.progress.read_aloud),
            event.on_check(UserToggledReadAloud),
          ]),
          html.text("Läs upp franskan"),
        ])
      False -> element.none()
    },
    html.p([class("hint")], [html.text(round_hint(stats))]),
    html.div([class("actions")], [
      html.button([class("primary"), event.on_click(UserStartedRound)], [
        html.text("Börja öva"),
      ]),
      html.button([class("secondary"), event.on_click(UserOpenedStatistics)], [
        html.text("Statistik"),
      ]),
    ]),
    case streak {
      0 -> element.none()
      days ->
        html.p([class("streak")], [
          html.text("Du har övat " <> plural(days, "dag", "dagar") <> " i rad."),
        ])
    },
  ])
}

fn round_hint(stats: progress.Stats) -> String {
  case stats.due, stats.new {
    0, 0 -> "Allt är repeterat! Du kan öva i förväg."
    due, 0 -> plural(due, "övning", "övningar") <> " att repetera."
    0, new -> plural(new, "ny övning", "nya övningar") <> "."
    due, new ->
      plural(due, "övning", "övningar")
      <> " att repetera och "
      <> plural(new, "ny", "nya")
      <> "."
  }
}

fn plural(count: Int, one: String, many: String) -> String {
  let word = case count {
    1 -> one
    _ -> many
  }
  int.to_string(count) <> " " <> word
}

fn chip(label: String, pressed: Bool, msg: Msg) -> Element(Msg) {
  html.button(
    [
      class("chip"),
      attribute.type_("button"),
      attribute.aria_pressed(case pressed {
        True -> "true"
        False -> "false"
      }),
      event.on_click(msg),
    ],
    [html.text(label)],
  )
}

fn drill_name(drill: Drill) -> String {
  case drill {
    TranslateToFrench -> "Svenska → franska"
    TranslateToSwedish -> "Franska → svenska"
    Articles -> "le eller la?"
    Conjugation(tense) -> "Böj verb: " <> tense_name(tense)
    Dictation -> "Diktamen"
    Numbers -> "Tal"
    Sentences -> "Meningar"
    Adjectives -> "Böj adjektiv"
  }
}

type DrillGroup {
  WordDrills
  GrammarDrills
  VerbDrills
}

/// Which row of the menu a drill is shown in.
fn drill_group(drill: Drill) -> DrillGroup {
  case drill {
    TranslateToFrench | TranslateToSwedish | Articles | Dictation | Numbers ->
      WordDrills
    Adjectives | Sentences -> GrammarDrills
    Conjugation(_) -> VerbDrills
  }
}

/// A drill's name in the menu, where the row heading gives the context.
fn chip_label(drill: Drill) -> String {
  case drill {
    Conjugation(tense) -> string.capitalise(tense_name(tense))
    _ -> drill_name(drill)
  }
}

fn tense_name(tense: lexicon.Tense) -> String {
  case tense {
    lexicon.Presens -> "presens"
    lexicon.FuturProche -> "futur proche"
    lexicon.PasseCompose -> "passé composé"
    lexicon.Imparfait -> "imparfait"
  }
}

/// Dictation needs speech synthesis.
fn available_drills(env: Env) -> List(Drill) {
  case env.can_speak {
    True -> exercise.drills()
    False -> list.filter(exercise.drills(), fn(drill) { drill != Dictation })
  }
}

fn view_exercise(
  env: Env,
  session: Session,
  exercise: Exercise,
  input: String,
  grade: Option(Grade),
) -> Element(Msg) {
  let remaining = list.length(session.queue)
  let answered = option.is_some(grade)

  html.section([class("card")], [
    html.div([class("progress")], [
      html.span([], [html.text(int.to_string(remaining) <> " kvar")]),
      html.button(
        [
          class("link"),
          attribute.type_("button"),
          event.on_click(UserQuitRound),
        ],
        [html.text("Avsluta")],
      ),
    ]),
    html.p([class("instruction")], [html.text(instruction(exercise))]),
    view_prompt(exercise, env.can_speak),
    html.form(
      [class("answer"), event.on_submit(fn(_) { UserSubmittedAnswer })],
      [
        html.input([
          attribute.id(answer_input_id),
          attribute.name("answer"),
          attribute.lang(case exercise.answer_language {
            answer.French -> "fr"
            answer.Swedish -> "sv"
          }),
          attribute.value(input),
          attribute.readonly(answered),
          attribute.autocomplete("off"),
          attribute.spellcheck(False),
          attribute("autocapitalize", "off"),
          attribute("autocorrect", "off"),
          attribute.placeholder(case exercise.answer_language {
            answer.French -> "Skriv på franska…"
            answer.Swedish -> "Skriv på svenska…"
          }),
          attribute.aria_label("Ditt svar"),
          event.on_input(UserTypedAnswer),
          case exercise.kind, answered {
            ChooseArticle, False -> on_article_shortcut()
            _, _ -> attribute.none()
          },
        ]),
        html.button([class("primary"), attribute.type_("submit")], [
          html.text(case answered {
            True -> "Nästa"
            False -> "Kontrollera"
          }),
        ]),
      ],
    ),
    case exercise.kind, answered {
      ChooseArticle, False -> view_choices()
      _, False if exercise.answer_language == answer.French -> view_accents()
      _, _ -> element.none()
    },
    case grade {
      Some(grade) -> view_feedback(exercise, grade, env.can_speak)
      None -> element.none()
    },
  ])
}

fn instruction(exercise: Exercise) -> String {
  case exercise.kind {
    Translate(ToFrench) -> "Översätt till franska"
    Translate(ToSwedish) -> "Översätt till svenska"
    ChooseArticle -> "Heter det le eller la?"
    Conjugate(tense, _) -> "Böj verbet i " <> tense_name(tense)
    Listen -> "Skriv det du hör"
    WriteNumber(_) -> "Skriv talet med bokstäver"
    FillGap(..) -> "Fyll i luckan"
    Agree(_) -> "Böj adjektivet"
  }
}

fn view_prompt(exercise: Exercise, can_speak: Bool) -> Element(Msg) {
  case exercise.kind {
    Translate(ToFrench) ->
      html.p([class("prompt"), attribute.lang("sv")], [
        html.text(exercise.prompt),
      ])
    Translate(ToSwedish) ->
      html.div([class("prompt-row")], [
        html.p([class("prompt"), attribute.lang("fr")], [
          html.text(exercise.prompt),
        ]),
        speaker_button(exercise.french, can_speak),
      ])
    ChooseArticle ->
      html.p([class("prompt"), attribute.lang("fr")], [
        html.span([class("blank")], [html.text("___")]),
        html.text(" " <> exercise.prompt),
      ])
    Listen ->
      html.div([class("listen")], [
        html.button(
          [
            class("speaker large"),
            attribute.type_("button"),
            attribute.aria_label("Lyssna igen"),
            attribute.title("Lyssna igen"),
            event.on_click(UserAskedToHear(exercise.french)),
          ],
          [speaker_icon()],
        ),
        html.p([class("hint"), attribute.lang("sv")], [
          html.text("Betyder: " <> exercise.prompt),
        ]),
      ])
    WriteNumber(_) ->
      html.p([class("prompt number")], [html.text(exercise.prompt)])
    Agree(form) ->
      html.p([class("prompt"), attribute.lang("fr")], [
        html.text(exercise.prompt),
        html.span([class("infinitive")], [
          html.text(" → " <> adjective_form_name(form)),
        ]),
      ])
    FillGap(hint:, translation:) -> {
      let #(before, after) =
        string.split_once(exercise.prompt, lexicon.gap)
        |> result.unwrap(#(exercise.prompt, ""))
      let hint = case hint {
        "" -> element.none()
        hint ->
          html.span([class("infinitive")], [html.text(" (" <> hint <> ")")])
      }
      html.div([class("sentence")], [
        html.p([class("prompt"), attribute.lang("fr")], [
          html.text(before),
          html.span([class("blank")], [html.text("___")]),
          hint,
          html.text(after),
        ]),
        html.p([class("hint"), attribute.lang("sv")], [html.text(translation)]),
      ])
    }
    Conjugate(_, person) ->
      html.p([class("prompt"), attribute.lang("fr")], [
        html.text(person_label(person) <> " "),
        html.span([class("blank")], [html.text("___")]),
        html.span([class("infinitive")], [
          html.text(" (" <> exercise.prompt <> ")"),
        ]),
      ])
  }
}

fn adjective_form_name(form: lexicon.AdjectiveForm) -> String {
  case form {
    lexicon.FeminineSingular -> "feminin singular"
    lexicon.MasculinePlural -> "maskulin plural"
    lexicon.FemininePlural -> "feminin plural"
  }
}

fn person_label(person: lexicon.Person) -> String {
  case person {
    lexicon.Il -> "il/elle/on"
    lexicon.Ils -> "ils/elles"
    _ -> lexicon.pronoun(person)
  }
}

const article_choices = ["le", "la"]

/// The answer a shortcut key picks: 1 for le, 2 for la.
pub fn article_shortcut(key: String) -> Result(String, Nil) {
  case int.parse(key) {
    Ok(n) if n >= 1 -> list.drop(article_choices, n - 1) |> list.first
    _ -> Error(Nil)
  }
}

/// Answers on 1 or 2 without typing the digit; other keys type as usual.
fn on_article_shortcut() -> attribute.Attribute(Msg) {
  event.advanced("keydown", {
    use key <- decode.field("key", decode.string)
    case article_shortcut(key) {
      Ok(choice) ->
        decode.success(event.handler(
          UserChoseAnswer(choice),
          prevent_default: True,
          stop_propagation: False,
        ))
      Error(Nil) ->
        decode.failure(
          event.handler(UserSubmittedAnswer, False, False),
          "shortcut key",
        )
    }
  })
}

fn view_choices() -> Element(Msg) {
  html.div(
    [class("choices")],
    list.index_map(article_choices, fn(choice, index) {
      html.button(
        [
          class("secondary"),
          attribute.type_("button"),
          attribute.lang("fr"),
          attribute.aria_keyshortcuts(int.to_string(index + 1)),
          event.on_click(UserChoseAnswer(choice)),
        ],
        [
          html.text(choice),
          html.kbd([], [html.text(int.to_string(index + 1))]),
        ],
      )
    }),
  )
}

fn view_accents() -> Element(Msg) {
  html.div(
    [
      class("accents"),
      attribute.role("group"),
      attribute.aria_label("Accenter"),
    ],
    list.map(accents, fn(accent) {
      html.button(
        [
          class("accent"),
          attribute.type_("button"),
          attribute.lang("fr"),
          // Keyboard users type accents directly; keep Tab on the answer.
          attribute.tabindex(-1),
          event.on_click(UserPressedAccent(accent)),
        ],
        [html.text(accent)],
      )
    }),
  )
}

fn view_feedback(
  exercise: Exercise,
  grade: Grade,
  can_speak: Bool,
) -> Element(Msg) {
  let tone = case grade {
    Correct -> "correct"
    Almost(..) -> "almost"
    Wrong(..) -> "wrong"
  }
  html.div([class("feedback " <> tone), attribute.role("status")], [
    html.p([], [html.text(answer.explain(grade))]),
    html.div([class("reveal")], [
      html.span([attribute.lang("fr")], [html.text(exercise.french)]),
      speaker_button(exercise.french, can_speak),
    ]),
    case gender_hint(exercise, grade) {
      Some(hint) -> html.p([class("gender-hint")], [html.text(hint)])
      None -> element.none()
    },
  ])
}

/// A rule of thumb for the noun's gender after a le/la exercise, or after
/// getting the article wrong in a translation.
fn gender_hint(exercise: Exercise, grade: Grade) -> Option(String) {
  let relevant = case exercise.kind, grade {
    ChooseArticle, _ -> True
    _, Almost(mistake: answer.WrongArticle, ..)
    | _, Almost(mistake: answer.MissingArticle, ..)
    -> True
    _, _ -> False
  }
  case relevant, content.entry(exercise.entry_id) {
    True, Ok(lexicon.Entry(word: lexicon.Noun(fr:, gender:, ..), ..)) ->
      gender.hint(fr, gender)
    _, _ -> None
  }
}

fn speaker_button(text: String, can_speak: Bool) -> Element(Msg) {
  case can_speak {
    False -> element.none()
    True ->
      html.button(
        [
          class("speaker"),
          attribute.type_("button"),
          attribute.aria_label("Lyssna"),
          attribute.title("Lyssna"),
          event.on_click(UserAskedToHear(text)),
        ],
        [speaker_icon()],
      )
  }
}

fn speaker_icon() -> Element(Msg) {
  svg.svg(
    [
      attribute("viewBox", "0 0 24 24"),
      attribute("width", "20"),
      attribute("height", "20"),
      attribute("fill", "none"),
      attribute("stroke", "currentColor"),
      attribute("stroke-width", "2"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-linejoin", "round"),
      attribute.aria_hidden(True),
    ],
    [
      svg.path([attribute("d", "M11 5 6 9H3v6h3l5 4V5z")]),
      svg.path([attribute("d", "M15.5 8.5a5 5 0 0 1 0 7")]),
      svg.path([attribute("d", "M18.5 5.5a9 9 0 0 1 0 13")]),
    ],
  )
}

fn view_finished(session: Session, round: Round) -> Element(Msg) {
  let summary = session.summary(session)
  let stat = fn(count: Int, label: String, tone: String) {
    html.div([class("stat " <> tone)], [
      html.span([class("count")], [html.text(int.to_string(count))]),
      html.span([], [html.text(label)]),
    ])
  }

  html.section([class("card")], [
    html.h2([], [html.text("Bra jobbat!")]),
    html.div([class("stats")], [
      stat(summary.correct, "rätt", "correct"),
      stat(summary.almost, "nästan", "almost"),
      stat(summary.wrong, "fel", "wrong"),
    ]),
    html.div([class("actions")], [
      html.button(
        [
          class("primary"),
          event.on_click(case round {
            DrillRound -> UserStartedRound
            ReviewRound -> UserStartedReview
            DifficultRound -> UserStartedDifficultRound
          }),
        ],
        [html.text("Öva igen")],
      ),
      html.button([class("secondary"), event.on_click(UserQuitRound)], [
        html.text("Till menyn"),
      ]),
    ]),
  ])
}

fn view_statistics(
  progress: Progress,
  drills: List(Drill),
  now: Int,
  confirming_reset: Bool,
  notice: Option(Notice),
) -> Element(Msg) {
  let row = fn(drill: Drill) {
    let stats = progress.stats(progress, content.exercises(drill, None), now:)
    html.tr([], [
      html.th([attribute("scope", "row")], [html.text(drill_name(drill))]),
      html.td([], [html.text(int.to_string(stats.new))]),
      html.td([], [html.text(int.to_string(stats.due))]),
      html.td([], [html.text(int.to_string(stats.learning))]),
      html.td([], [html.text(int.to_string(stats.learned))]),
    ])
  }
  let column = fn(label: String) {
    html.th([attribute("scope", "col")], [html.text(label)])
  }

  html.section([class("card")], [
    html.h2([], [html.text("Statistik")]),
    html.div([class("table-wrap")], [
      html.table([class("stats-table")], [
        html.thead([], [
          html.tr([], [
            html.td([], []),
            column("Nya"),
            column("Repetera"),
            column("Pågår"),
            column("Inlärda"),
          ]),
        ]),
        html.tbody([], list.map(drills, row)),
      ]),
    ]),
    html.p([class("hint")], [
      html.text(
        "En övning räknas som inlärd när nästa repetition är minst en vecka bort.",
      ),
    ]),
    view_difficult(progress.difficult(progress, content.all_exercises())),
    view_backup(notice),
    case confirming_reset {
      False ->
        html.div([class("actions")], [
          html.button([class("primary"), event.on_click(UserQuitRound)], [
            html.text("Tillbaka"),
          ]),
          html.button([class("danger"), event.on_click(UserAskedToReset)], [
            html.text("Nollställ framsteg"),
          ]),
        ])
      True ->
        html.div([class("confirm"), attribute.role("alert")], [
          html.p([], [
            html.text("Vill du radera alla framsteg? Det går inte att ångra."),
          ]),
          html.div([class("actions")], [
            html.button([class("danger"), event.on_click(UserConfirmedReset)], [
              html.text("Ja, radera"),
            ]),
            html.button(
              [class("secondary"), event.on_click(UserCancelledReset)],
              [html.text("Avbryt")],
            ),
          ]),
        ])
    },
  ])
}

fn view_backup(notice: Option(Notice)) -> Element(Msg) {
  html.div([class("backup")], [
    html.h2([class("subheading")], [html.text("Säkerhetskopia")]),
    html.p([class("hint")], [
      html.text(
        "Framstegen sparas bara i den här webbläsaren. Exportera dem till en fil för att ha en kopia eller flytta dem till en annan enhet. En import ersätter de nuvarande framstegen.",
      ),
    ]),
    html.div([class("actions")], [
      html.button([class("secondary"), event.on_click(UserExportedProgress)], [
        html.text("Exportera"),
      ]),
      html.label([class("file-button secondary")], [
        html.input([
          attribute.id(import_input_id),
          attribute.type_("file"),
          attribute.accept(["application/json", ".json"]),
          event.on("change", decode.success(UserChoseImportFile)),
        ]),
        html.text("Importera"),
      ]),
    ]),
    case notice {
      None -> element.none()
      Some(Imported) ->
        html.p([class("feedback correct"), attribute.role("status")], [
          html.text("Framstegen är importerade."),
        ])
      Some(CouldNotImport) ->
        html.p([class("feedback wrong"), attribute.role("status")], [
          html.text(
            "Filen kunde inte läsas. Välj en fil som exporterats härifrån.",
          ),
        ])
    },
  ])
}

fn view_difficult(difficult: List(#(Exercise, srs.CardState))) -> Element(Msg) {
  case difficult {
    [] -> element.none()
    _ ->
      html.div([class("difficult")], [
        html.h2([class("subheading")], [html.text("Svåra ord")]),
        html.ul(
          [class("difficult-list")],
          list.map(list.take(difficult, round_size), fn(pair) {
            let #(exercise, card) = pair
            html.li([], [
              html.span([attribute.lang("fr")], [html.text(exercise.french)]),
              html.span([class("muted")], [
                html.text(
                  drill_name(exercise.drill(exercise.kind))
                  <> " · fel "
                  <> plural(card.lapses, "gång", "gånger"),
                ),
              ]),
            ])
          }),
        ),
        html.button(
          [class("secondary"), event.on_click(UserStartedDifficultRound)],
          [html.text("Öva på svåra ord")],
        ),
      ])
  }
}
