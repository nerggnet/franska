import franska/answer.{Correct, French, Wrong}
import franska/exercise.{Exercise, ToFrench, Translate}
import franska/lexicon.{A1}
import franska/progress.{Progress, Stats, Streak}
import franska/srs.{type CardState, CardState}
import gleam/dict
import gleam/list

const now = 1_000_000

const day = 86_400

fn exercise(id: String) {
  Exercise(
    id:,
    entry_id: id,
    kind: Translate(ToFrench),
    prompt: id,
    accepted: [id],
    answer_language: French,
    french: id,
    level: A1,
  )
}

fn with_cards(cards: List(#(String, CardState))) {
  Progress(..progress.new(), cards: dict.from_list(cards))
}

fn ids(exercises: List(exercise.Exercise)) {
  list.map(exercises, fn(e) { e.id })
}

pub fn record_creates_and_reviews_card_test() {
  let p = progress.new() |> progress.record("a", Correct, now:, today: 100)
  assert dict.get(p.cards, "a")
    == Ok(CardState(box: 1, due: now + day, reviews: 1, lapses: 0))
}

pub fn streak_grows_on_consecutive_days_test() {
  let p =
    progress.new()
    |> progress.record("a", Correct, now:, today: 100)
    |> progress.record("b", Correct, now:, today: 100)
    |> progress.record("a", Wrong("a"), now:, today: 101)
  assert p.streak == Streak(last_day: 101, days: 2)
}

pub fn streak_restarts_after_a_missed_day_test() {
  let p =
    Progress(..progress.new(), streak: Streak(last_day: 100, days: 5))
    |> progress.record("a", Correct, now:, today: 102)
  assert p.streak == Streak(last_day: 102, days: 1)
}

pub fn streak_days_counts_until_a_day_is_missed_test() {
  let p = Progress(..progress.new(), streak: Streak(last_day: 100, days: 5))
  assert progress.streak_days(p, 100) == 5
  assert progress.streak_days(p, 101) == 5
  assert progress.streak_days(p, 102) == 0
}

pub fn plan_round_puts_most_overdue_first_then_new_test() {
  let p =
    with_cards([
      #("due-late", CardState(box: 1, due: now - 50, reviews: 1, lapses: 0)),
      #("due-soon", CardState(box: 1, due: now - 10, reviews: 1, lapses: 0)),
      #("later", CardState(box: 2, due: now + day, reviews: 1, lapses: 0)),
    ])
  let exercises =
    list.map(["new-1", "due-soon", "later", "due-late", "new-2"], exercise)
  assert ids(progress.plan_round(p, exercises, now:, size: 3))
    == ["due-late", "due-soon", "new-1"]
}

pub fn plan_round_fills_up_with_cards_due_soonest_test() {
  let p =
    with_cards([
      #(
        "in-a-week",
        CardState(box: 3, due: now + 7 * day, reviews: 3, lapses: 0),
      ),
      #("tomorrow", CardState(box: 1, due: now + day, reviews: 1, lapses: 0)),
    ])
  let exercises = list.map(["in-a-week", "tomorrow", "new"], exercise)
  assert ids(progress.plan_round(p, exercises, now:, size: 10))
    == ["new", "tomorrow", "in-a-week"]
}

pub fn stats_count_new_due_learning_and_learned_test() {
  let p =
    with_cards([
      #("due", CardState(box: 4, due: now - 1, reviews: 4, lapses: 0)),
      #("learning", CardState(box: 2, due: now + day, reviews: 2, lapses: 0)),
      #("learned", CardState(box: 3, due: now + day, reviews: 3, lapses: 0)),
      #(
        "removed-from-content",
        CardState(box: 1, due: 0, reviews: 1, lapses: 0),
      ),
    ])
  let exercises = list.map(["new", "due", "learning", "learned"], exercise)
  assert progress.stats(p, exercises, now:)
    == Stats(new: 1, due: 1, learning: 1, learned: 1)
}

pub fn json_round_trip_test() {
  let p =
    Progress(
      cards: dict.from_list([
        #("chat:to-fr", CardState(box: 2, due: now, reviews: 5, lapses: 1)),
      ]),
      read_aloud: False,
      streak: Streak(last_day: 100, days: 3),
    )
  assert progress.from_json(progress.to_json(p)) == Ok(p)
}

pub fn invalid_json_is_rejected_test() {
  assert progress.from_json("not json") == Error(Nil)
  assert progress.from_json("{\"version\": 99, \"cards\": {}}") == Error(Nil)
}

pub fn missing_optional_fields_get_defaults_test() {
  assert progress.from_json("{\"version\": 1, \"cards\": {}}")
    == Ok(progress.new())
}

pub fn plan_round_takes_new_a1_before_new_a2_test() {
  let exercises = [
    Exercise(..exercise("a2-first"), level: lexicon.A2),
    exercise("a1-first"),
    Exercise(..exercise("a2-second"), level: lexicon.A2),
    exercise("a1-second"),
  ]
  assert ids(progress.plan_round(progress.new(), exercises, now:, size: 3))
    == ["a1-first", "a1-second", "a2-first"]
}

pub fn due_lists_only_due_exercises_most_overdue_first_test() {
  let p =
    with_cards([
      #("a", CardState(box: 1, due: now - 10, reviews: 1, lapses: 0)),
      #("b", CardState(box: 1, due: now + 10, reviews: 1, lapses: 0)),
      #("c", CardState(box: 1, due: now - 50, reviews: 1, lapses: 0)),
    ])
  let exercises = list.map(["a", "b", "c", "new"], exercise)
  assert ids(progress.due(p, exercises, now:)) == ["c", "a"]
}

pub fn difficult_lists_most_mistakes_first_test() {
  let p =
    with_cards([
      #("once", CardState(box: 2, due: now, reviews: 3, lapses: 1)),
      #("never", CardState(box: 3, due: now, reviews: 3, lapses: 0)),
      #("thrice", CardState(box: 1, due: now, reviews: 5, lapses: 3)),
      #("once-weak", CardState(box: 1, due: now, reviews: 2, lapses: 1)),
    ])
  let exercises = list.map(["once", "never", "thrice", "once-weak"], exercise)
  assert progress.difficult(p, exercises)
    |> list.map(fn(pair) { { pair.0 }.id })
    == ["thrice", "once-weak", "once"]
}

pub fn mixed_round_takes_new_exercises_from_every_group_in_turn_test() {
  let groups = [
    list.map(["a1", "a2", "a3", "a4", "a5"], exercise),
    list.map(["b1", "b2"], exercise),
    list.map(["c1", "c2", "c3"], exercise),
  ]
  assert ids(progress.plan_mixed_round(progress.new(), groups, now:, size: 6))
    == ["a1", "b1", "c1", "a2", "b2", "c2"]
}

pub fn mixed_round_puts_due_exercises_first_test() {
  let p =
    with_cards([
      #("c2", CardState(box: 1, due: now - 50, reviews: 1, lapses: 0)),
      #("a3", CardState(box: 1, due: now - 10, reviews: 1, lapses: 0)),
      #("b1", CardState(box: 2, due: now + day, reviews: 1, lapses: 0)),
    ])
  let groups = [
    list.map(["a1", "a2", "a3"], exercise),
    list.map(["b1", "b2"], exercise),
    list.map(["c1", "c2"], exercise),
  ]
  assert ids(progress.plan_mixed_round(p, groups, now:, size: 5))
    == ["c2", "a3", "a1", "b2", "c1"]
}

pub fn mixed_round_fills_up_with_cards_due_soonest_test() {
  let p =
    with_cards([
      #("a1", CardState(box: 1, due: now + day, reviews: 1, lapses: 0)),
    ])
  let groups = [[exercise("a1")], [exercise("b1")]]
  assert ids(progress.plan_mixed_round(p, groups, now:, size: 5))
    == ["b1", "a1"]
}
