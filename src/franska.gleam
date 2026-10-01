//// The browser app. All learning logic lives in the pure `franska/*`
//// modules; this module only holds UI state and renders it.

import franska/answer.{type Grade, Almost, Correct, Wrong}
import franska/content
import franska/exercise.{type Exercise, ToFrench, Translate}
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
import lustre/event

const round_size = 10

const answer_input_id = "answer"

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// MODEL -----------------------------------------------------------------------

/// `theme` is the chosen theme, or `None` for all themes.
pub type Model {
  Menu(theme: Option(String))
  Practising(
    theme: Option(String),
    session: Session,
    input: String,
    grade: Option(Grade),
  )
  Finished(theme: Option(String), session: Session)
}

fn init(_: Nil) -> #(Model, Effect(Msg)) {
  #(Menu(theme: None), effect.none())
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  UserPickedTheme(Option(String))
  UserStartedRound
  UserTypedAnswer(String)
  UserSubmittedAnswer
  UserQuitRound
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case model, msg {
    Menu(..), UserPickedTheme(theme) -> #(Menu(theme:), effect.none())

    Menu(theme:), UserStartedRound | Finished(theme:, ..), UserStartedRound -> #(
      Practising(theme:, session: new_round(theme), input: "", grade: None),
      focus_answer(),
    )

    Practising(grade: None, ..), UserTypedAnswer(input) -> #(
      Practising(..model, input:),
      effect.none(),
    )

    Practising(session:, input:, grade: None, ..), UserSubmittedAnswer ->
      case session.current(session), string.trim(input) {
        _, "" | Error(Nil), _ -> #(model, focus_answer())
        Ok(exercise), _ -> #(
          Practising(..model, grade: Some(exercise.check(exercise, input))),
          focus_answer(),
        )
      }

    Practising(theme:, session:, grade: Some(grade), ..), UserSubmittedAnswer -> {
      let session = session.record(session, grade)
      case session.is_finished(session) {
        True -> #(Finished(theme:, session:), effect.none())
        False -> #(
          Practising(theme:, session:, input: "", grade: None),
          focus_answer(),
        )
      }
    }

    Practising(theme:, ..), UserQuitRound
    | Finished(theme:, ..), UserQuitRound
    -> #(Menu(theme:), effect.none())

    _, _ -> #(model, effect.none())
  }
}

/// Picks a random set of Swedish → French translations for one round.
fn new_round(theme: Option(String)) -> Session {
  content.entries()
  |> list.filter(fn(entry) {
    case theme {
      Some(theme) -> entry.theme == theme
      None -> True
    }
  })
  |> list.flat_map(exercise.from_entry)
  |> list.filter(fn(exercise) { exercise.kind == Translate(ToFrench) })
  |> list.shuffle
  |> list.take(round_size)
  |> session.new
}

fn focus_answer() -> Effect(Msg) {
  use _, _ <- effect.after_paint
  focus(answer_input_id)
}

@external(javascript, "./franska.ffi.mjs", "focus")
fn focus(_id: String) -> Nil {
  Nil
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.main([class("app")], [
    html.header([class("header")], [
      html.h1([], [html.text("Franska")]),
      html.p([class("tagline")], [html.text("Öva franska, en fras i taget")]),
    ]),
    case model {
      Menu(theme:) -> view_menu(theme)
      Practising(session:, input:, grade:, ..) ->
        case session.current(session) {
          Ok(exercise) -> view_exercise(session, exercise, input, grade)
          Error(Nil) -> element.none()
        }
      Finished(session:, ..) -> view_finished(session)
    },
  ])
}

fn view_menu(selected: Option(String)) -> Element(Msg) {
  let chip = fn(theme: Option(String), label: String) {
    html.button(
      [
        class("chip"),
        attribute.type_("button"),
        attribute.aria_pressed(case theme == selected {
          True -> "true"
          False -> "false"
        }),
        event.on_click(UserPickedTheme(theme)),
      ],
      [html.text(label)],
    )
  }

  html.section([class("card")], [
    html.h2([], [html.text("Välj tema")]),
    html.div([class("chips")], [
      chip(None, "Alla"),
      ..list.map(content.themes(), fn(theme) {
        chip(Some(theme), string.capitalise(theme))
      })
    ]),
    html.p([class("hint")], [
      html.text(
        "Du får "
        <> int.to_string(round_size)
        <> " ord att översätta från svenska till franska.",
      ),
    ]),
    html.button([class("primary"), event.on_click(UserStartedRound)], [
      html.text("Börja öva"),
    ]),
  ])
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
    html.p([class("instruction")], [html.text("Översätt till franska")]),
    html.p([class("prompt"), attribute.lang("sv")], [
      html.text(exercise.prompt),
    ]),
    html.form(
      [class("answer"), event.on_submit(fn(_) { UserSubmittedAnswer })],
      [
        html.input([
          attribute.id(answer_input_id),
          attribute.name("answer"),
          attribute.lang("fr"),
          attribute.value(input),
          attribute.readonly(answered),
          attribute.autocomplete("off"),
          attribute.spellcheck(False),
          attribute("autocapitalize", "off"),
          attribute("autocorrect", "off"),
          attribute.placeholder("Skriv på franska…"),
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
    case grade {
      Some(grade) -> view_feedback(grade)
      None -> element.none()
    },
  ])
}

fn view_feedback(grade: Grade) -> Element(Msg) {
  let tone = case grade {
    Correct -> "correct"
    Almost(..) -> "almost"
    Wrong(..) -> "wrong"
  }
  html.p([class("feedback " <> tone), attribute.role("status")], [
    html.text(answer.explain(grade)),
  ])
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
        html.text("Byt tema"),
      ]),
    ]),
  ])
}
