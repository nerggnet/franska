import franska/answer.{Correct, Wrong}
import franska/content
import franska/exercise.{Articles, Conjugation, TranslateToFrench}
import franska/lexicon
import franska/progress
import franska/session
import franska/srs
import franska/ui/app.{
  Env, Finished, Menu, Practising, Statistics, UserAskedToReset,
  UserConfirmedReset, UserPickedDrill, UserPickedTheme, UserQuitRound,
  UserStartedReview, UserStartedRound, UserSubmittedAnswer, UserTypedAnswer,
}
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import lustre/element

const now = 1_000_000

const today = 100

fn start() -> app.Model {
  let env =
    Env(
      now: fn() { now },
      today: fn() { today },
      shuffle: fn(exercises) { exercises },
      can_speak: False,
    )
  app.init(#(env, progress.new())).0
}

fn send(model: app.Model, msgs: List(app.Msg)) -> app.Model {
  list.fold(msgs, model, fn(model, msg) { app.update(model, msg).0 })
}

fn current(model: app.Model) {
  let assert Practising(session:, ..) = model.screen
  let assert Ok(exercise) = session.current(session)
  exercise
}

fn answer(model: app.Model, text: String) -> app.Model {
  send(model, [UserTypedAnswer(text), UserSubmittedAnswer])
}

fn answer_correctly(model: app.Model) -> app.Model {
  let assert [accepted, ..] = current(model).accepted
  answer(model, accepted)
}

pub fn starts_in_the_menu_test() {
  assert start().screen == Menu
}

pub fn picking_a_drill_drops_a_theme_it_does_not_have_test() {
  let model =
    start()
    |> send([UserPickedTheme(Some("djur")), UserPickedDrill(Articles)])
  assert model.theme == Some("djur")
  let model = send(model, [UserPickedDrill(Conjugation(lexicon.Presens))])
  assert model.theme == None
}

pub fn a_round_has_ten_exercises_of_the_chosen_drill_test() {
  let model = start() |> send([UserStartedRound])
  let assert Practising(session:, input: "", grade: None) = model.screen
  assert list.length(session.queue) == 10
  assert list.all(session.queue, fn(e) {
    exercise.drill(e.kind) == TranslateToFrench
  })
}

pub fn a_round_is_limited_to_the_chosen_theme_test() {
  let model = start() |> send([UserPickedTheme(Some("djur")), UserStartedRound])
  let assert Practising(session:, ..) = model.screen
  assert list.map(session.queue, fn(e) { e.prompt })
    == ["katt", "hund", "fågel", "häst"]
}

pub fn an_answer_is_graded_and_saved_test() {
  let model = start() |> send([UserStartedRound])
  let first = current(model)
  let model = answer_correctly(model)
  let assert Practising(grade: Some(Correct), ..) = model.screen
  let assert Ok(card) = dict.get(model.progress.cards, first.id)
  assert card.box == 1
  assert model.progress.streak.last_day == today
}

pub fn an_empty_answer_is_ignored_test() {
  let model = start() |> send([UserStartedRound])
  let model = answer(model, "   ")
  let assert Practising(grade: None, ..) = model.screen
  assert dict.is_empty(model.progress.cards)
}

pub fn only_the_first_attempt_is_saved_test() {
  let model = start() |> send([UserPickedTheme(Some("djur")), UserStartedRound])
  let first = current(model)
  // Wrong, then three right answers until the wrong one comes back.
  let model = answer(model, "xyz") |> send([UserSubmittedAnswer])
  let model =
    list.fold([1, 2, 3], model, fn(model, _) {
      answer_correctly(model) |> send([UserSubmittedAnswer])
    })
  assert current(model).id == first.id
  let model = answer_correctly(model)
  let assert Ok(card) = dict.get(model.progress.cards, first.id)
  assert card.reviews == 1
  assert card.lapses == 1
}

pub fn finishing_all_exercises_ends_the_round_test() {
  let model = start() |> send([UserPickedTheme(Some("djur")), UserStartedRound])
  let model =
    list.fold([1, 2, 3, 4], model, fn(model, _) {
      answer_correctly(model) |> send([UserSubmittedAnswer])
    })
  let assert Finished(session:) = model.screen
  assert session.summary(session) == session.Summary(4, 0, 0)
}

pub fn wrong_answers_show_the_expected_answer_test() {
  let model = start() |> send([UserPickedTheme(Some("djur")), UserStartedRound])
  let model = answer(model, "xyz")
  let assert Practising(grade: Some(Wrong("le chat")), ..) = model.screen
}

pub fn quitting_returns_to_the_menu_test() {
  let model = start() |> send([UserStartedRound, UserQuitRound])
  assert model.screen == Menu
}

pub fn reset_needs_confirmation_test() {
  let model = start() |> send([UserStartedRound]) |> answer_correctly
  let model = send(model, [UserQuitRound, app.UserOpenedStatistics])
  assert model.screen == Statistics(confirming_reset: False, notice: None)
  let model = send(model, [UserConfirmedReset])
  assert !dict.is_empty(model.progress.cards)
  let model = send(model, [UserAskedToReset, UserConfirmedReset])
  assert dict.is_empty(model.progress.cards)
  assert model.screen == Statistics(confirming_reset: False, notice: None)
}

fn with_progress(model: app.Model, cards: List(#(String, srs.CardState))) {
  app.Model(
    ..model,
    progress: progress.Progress(..model.progress, cards: dict.from_list(cards)),
  )
}

pub fn review_round_takes_due_exercises_from_every_drill_test() {
  let due = srs.CardState(box: 1, due: now - 1, reviews: 1, lapses: 0)
  let later = srs.CardState(box: 1, due: now + 1, reviews: 1, lapses: 0)
  let model =
    start()
    |> with_progress([
      #("chat:to-fr", due),
      #("chat:article", due),
      #("parler:present:nous", due),
      #("chien:to-fr", later),
    ])
    |> send([UserStartedReview])
  assert model.reviewing
  let assert Practising(session:, ..) = model.screen
  assert list.sort(list.map(session.queue, fn(e) { e.id }), string.compare)
    == ["chat:article", "chat:to-fr", "parler:present:nous"]
}

pub fn review_round_with_nothing_due_stays_in_the_menu_test() {
  let model = start() |> send([UserStartedReview])
  assert model.screen == Menu
}

pub fn review_round_is_limited_to_twenty_test() {
  let due = srs.CardState(box: 1, due: now - 1, reviews: 1, lapses: 0)
  let cards =
    content.all_exercises()
    |> list.take(30)
    |> list.map(fn(e) { #(e.id, due) })
  let model = start() |> with_progress(cards) |> send([UserStartedReview])
  let assert Practising(session:, ..) = model.screen
  assert list.length(session.queue) == 20
}

pub fn importing_valid_progress_replaces_it_test() {
  let card = srs.CardState(box: 3, due: now, reviews: 4, lapses: 0)
  let exported =
    progress.Progress(
      ..progress.new(),
      cards: dict.from_list([#("chat:to-fr", card)]),
    )
    |> progress.to_json
  let model =
    start()
    |> send([
      app.UserOpenedStatistics,
      app.ImportFileRead(exported),
    ])
  assert dict.to_list(model.progress.cards) == [#("chat:to-fr", card)]
  assert model.screen
    == Statistics(confirming_reset: False, notice: Some(app.Imported))
}

pub fn importing_an_unreadable_file_keeps_progress_test() {
  let model = start() |> send([UserStartedRound]) |> answer_correctly
  let before = model.progress
  let model =
    send(model, [
      UserQuitRound,
      app.UserOpenedStatistics,
      app.ImportFileRead("{"),
    ])
  assert model.progress == before
  assert model.screen
    == Statistics(confirming_reset: False, notice: Some(app.CouldNotImport))
}

pub fn dictation_is_hidden_without_speech_test() {
  let model = start()
  let html = element.to_string(app.view(model))
  assert !string.contains(html, "Diktamen")
  let speaking = app.Model(..model, env: Env(..model.env, can_speak: True))
  assert string.contains(element.to_string(app.view(speaking)), "Diktamen")
}
