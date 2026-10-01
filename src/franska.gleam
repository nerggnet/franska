//// The browser app. All learning logic lives in the pure `franska/*`
//// modules; this module only holds UI state and renders it.

import franska/answer.{type Grade, Almost, Correct, Wrong}
import franska/content
import franska/exercise.{
  type Drill, type Exercise, Articles, ChooseArticle, Conjugate, Conjugation,
  ToFrench, ToSwedish, Translate, TranslateToFrench, TranslateToSwedish,
}
import franska/lexicon
import franska/session.{type Session}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre
import lustre/attribute.{attribute, class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event

const round_size = 10

const answer_input_id = "answer"

const accents = ["é", "è", "ê", "ë", "à", "â", "ç", "î", "ï", "ô", "ù", "û", "œ"]

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// MODEL -----------------------------------------------------------------------

/// `theme` is the chosen theme, or `None` for all themes. `read_aloud` says
/// whether French is spoken automatically.
pub type Model {
  Model(drill: Drill, theme: Option(String), read_aloud: Bool, screen: Screen)
}

pub type Screen {
  Menu
  Practising(session: Session, input: String, grade: Option(Grade))
  Finished(session: Session)
}

fn init(_: Nil) -> #(Model, Effect(Msg)) {
  #(
    Model(drill: TranslateToFrench, theme: None, read_aloud: True, screen: Menu),
    effect.none(),
  )
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  UserPickedDrill(Drill)
  UserPickedTheme(Option(String))
  UserToggledReadAloud(Bool)
  UserStartedRound
  UserTypedAnswer(String)
  UserPressedAccent(String)
  UserChoseAnswer(String)
  UserSubmittedAnswer
  UserAskedToHear(String)
  UserQuitRound
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
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

    Menu, UserToggledReadAloud(read_aloud) -> #(
      Model(..model, read_aloud:),
      effect.none(),
    )

    Menu, UserStartedRound | Finished(..), UserStartedRound -> {
      let session =
        content.exercises(model.drill, model.theme)
        |> list.shuffle
        |> list.take(round_size)
        |> session.new
      show_exercise(model, session)
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

    Practising(..), UserQuitRound | Finished(..), UserQuitRound -> #(
      Model(..model, screen: Menu),
      effect.none(),
    )

    _, _ -> #(model, effect.none())
  }
}

fn show_exercise(model: Model, session: Session) -> #(Model, Effect(Msg)) {
  let screen = Practising(session:, input: "", grade: None)
  // A French prompt is read aloud as soon as it is shown.
  let speech = case session.current(session), model.read_aloud {
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
      let screen = Practising(session:, input:, grade: Some(grade))
      // Hear the right French after answering, unless it was just read out.
      let speech = case model.read_aloud, exercise.kind {
        True, Translate(ToSwedish) | False, _ -> effect.none()
        True, _ -> speak_effect(exercise.french)
      }
      #(Model(..model, screen:), effect.batch([focus_answer(), speech]))
    }
  }
}

fn focus_answer() -> Effect(Msg) {
  use _, _ <- effect.after_paint
  focus(answer_input_id)
}

fn insert_accent(accent: String) -> Effect(Msg) {
  use dispatch <- effect.from
  dispatch(UserTypedAnswer(insert_at_cursor(answer_input_id, accent)))
}

fn speak_effect(text: String) -> Effect(Msg) {
  use _ <- effect.from
  speak(text)
}

@external(javascript, "./franska.ffi.mjs", "focus")
fn focus(_id: String) -> Nil {
  Nil
}

@external(javascript, "./franska.ffi.mjs", "insert_at_cursor")
fn insert_at_cursor(_id: String, text: String) -> String {
  text
}

@external(javascript, "./franska.ffi.mjs", "can_speak")
fn can_speak() -> Bool {
  False
}

@external(javascript, "./franska.ffi.mjs", "speak")
fn speak(_text: String) -> Nil {
  Nil
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.main([class("app")], [
    html.header([class("header")], [
      html.h1([], [html.text("Franska")]),
      html.p([class("tagline")], [html.text("Öva franska, en fras i taget")]),
    ]),
    case model.screen {
      Menu -> view_menu(model)
      Practising(session:, input:, grade:) ->
        case session.current(session) {
          Ok(exercise) -> view_exercise(session, exercise, input, grade)
          Error(Nil) -> element.none()
        }
      Finished(session:) -> view_finished(session)
    },
  ])
}

fn view_menu(model: Model) -> Element(Msg) {
  let themes = content.themes_for(model.drill)
  let available = list.length(content.exercises(model.drill, model.theme))

  html.section([class("card")], [
    html.h2([], [html.text("Vad vill du öva?")]),
    html.div(
      [class("chips")],
      list.map(exercise.drills, fn(drill) {
        chip(drill_name(drill), drill == model.drill, UserPickedDrill(drill))
      }),
    ),
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
    case can_speak() {
      True ->
        html.label([class("toggle")], [
          html.input([
            attribute.type_("checkbox"),
            attribute.checked(model.read_aloud),
            event.on_check(UserToggledReadAloud),
          ]),
          html.text("Läs upp franskan"),
        ])
      False -> element.none()
    },
    html.p([class("hint")], [
      html.text(
        "En runda har "
        <> int.to_string(int.min(round_size, available))
        <> " övningar.",
      ),
    ]),
    html.button([class("primary"), event.on_click(UserStartedRound)], [
      html.text("Börja öva"),
    ]),
  ])
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
    Conjugation -> "Böj verb"
  }
}

fn view_exercise(
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
    view_prompt(exercise),
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
      ChooseArticle, False -> view_choices(["le", "la"])
      _, False if exercise.answer_language == answer.French -> view_accents()
      _, _ -> element.none()
    },
    case grade {
      Some(grade) -> view_feedback(exercise, grade)
      None -> element.none()
    },
  ])
}

fn instruction(exercise: Exercise) -> String {
  case exercise.kind {
    Translate(ToFrench) -> "Översätt till franska"
    Translate(ToSwedish) -> "Översätt till svenska"
    ChooseArticle -> "Heter det le eller la?"
    Conjugate(_) -> "Böj verbet i presens"
  }
}

fn view_prompt(exercise: Exercise) -> Element(Msg) {
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
        speaker_button(exercise.french),
      ])
    ChooseArticle ->
      html.p([class("prompt"), attribute.lang("fr")], [
        html.span([class("blank")], [html.text("___")]),
        html.text(" " <> exercise.prompt),
      ])
    Conjugate(person) ->
      html.p([class("prompt"), attribute.lang("fr")], [
        html.text(person_label(person) <> " "),
        html.span([class("blank")], [html.text("___")]),
        html.span([class("infinitive")], [
          html.text(" (" <> exercise.prompt <> ")"),
        ]),
      ])
  }
}

fn person_label(person: lexicon.Person) -> String {
  case person {
    lexicon.Il -> "il/elle/on"
    lexicon.Ils -> "ils/elles"
    _ -> lexicon.pronoun(person)
  }
}

fn view_choices(choices: List(String)) -> Element(Msg) {
  html.div(
    [class("choices")],
    list.map(choices, fn(choice) {
      html.button(
        [
          class("secondary"),
          attribute.type_("button"),
          attribute.lang("fr"),
          event.on_click(UserChoseAnswer(choice)),
        ],
        [html.text(choice)],
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

fn view_feedback(exercise: Exercise, grade: Grade) -> Element(Msg) {
  let tone = case grade {
    Correct -> "correct"
    Almost(..) -> "almost"
    Wrong(..) -> "wrong"
  }
  html.div([class("feedback " <> tone), attribute.role("status")], [
    html.p([], [html.text(answer.explain(grade))]),
    html.div([class("reveal")], [
      html.span([attribute.lang("fr")], [html.text(exercise.french)]),
      speaker_button(exercise.french),
    ]),
  ])
}

fn speaker_button(text: String) -> Element(Msg) {
  case can_speak() {
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

fn view_finished(session: Session) -> Element(Msg) {
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
      html.button([class("primary"), event.on_click(UserStartedRound)], [
        html.text("Öva igen"),
      ]),
      html.button([class("secondary"), event.on_click(UserQuitRound)], [
        html.text("Till menyn"),
      ]),
    ]),
  ])
}
