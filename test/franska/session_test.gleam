import franska/answer.{Almost, Correct, French, MissingAccents, Wrong}
import franska/exercise.{Exercise, ToFrench, Translate}
import franska/session.{Summary}
import gleam/list

fn exercise(id: String) {
  Exercise(
    id:,
    entry_id: id,
    kind: Translate(ToFrench),
    prompt: id,
    accepted: [id],
    answer_language: French,
    french: id,
  )
}

fn ids(s: session.Session) {
  list.map(s.queue, fn(e) { e.id })
}

pub fn new_session_starts_with_first_exercise_test() {
  let s = session.new([exercise("a"), exercise("b")])
  assert session.current(s) == Ok(exercise("a"))
  assert !session.is_finished(s)
}

pub fn correct_and_almost_move_on_test() {
  let s =
    session.new([exercise("a"), exercise("b")])
    |> session.record(Correct)
    |> session.record(Almost("b", MissingAccents))
  assert session.is_finished(s)
  assert session.current(s) == Error(Nil)
}

pub fn wrong_answer_comes_back_later_test() {
  let s =
    session.new(list.map(["a", "b", "c", "d", "e"], exercise))
    |> session.record(Wrong("a"))
  assert ids(s) == ["b", "c", "d", "a", "e"]
}

pub fn wrong_answer_near_the_end_goes_last_test() {
  let s =
    session.new([exercise("a"), exercise("b")])
    |> session.record(Wrong("a"))
  assert ids(s) == ["b", "a"]
}

pub fn summary_counts_every_answer_test() {
  let s =
    session.new([exercise("a"), exercise("b")])
    |> session.record(Wrong("a"))
    |> session.record(Correct)
    |> session.record(Almost("a", MissingAccents))
  assert session.summary(s) == Summary(correct: 1, almost: 1, wrong: 1)
}
