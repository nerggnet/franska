//// The learner's saved state: spaced-repetition cards, settings and the
//// practice streak, plus how it is stored as JSON and used to plan rounds.

import franska/answer.{type Grade}
import franska/exercise.{type Exercise}
import franska/lexicon.{type Level}
import franska/srs.{type CardState, CardState}
import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result

/// Bump when the stored format changes incompatibly.
const version = 1

/// Cards in this box or higher count as learned (next review in 7+ days).
pub const learned_box = 3

/// `level` is the level chosen in the menu, or `None` for both. `voice` is
/// the name of the chosen speech voice, or `None` for the best available.
pub type Progress {
  Progress(
    cards: Dict(String, CardState),
    read_aloud: Bool,
    level: Option(Level),
    voice: Option(String),
    streak: Streak,
  )
}

/// `last_day` is the last local day number (days since 1970-01-01) with
/// practice, `days` the number of consecutive days up to it.
pub type Streak {
  Streak(last_day: Int, days: Int)
}

pub type Stats {
  Stats(new: Int, due: Int, learning: Int, learned: Int)
}

pub fn new() -> Progress {
  Progress(
    cards: dict.new(),
    read_aloud: True,
    level: None,
    voice: None,
    streak: Streak(-1, 0),
  )
}

/// Records the first answer to an exercise in a round.
pub fn record(
  progress: Progress,
  exercise_id: String,
  grade: Grade,
  now now: Int,
  today today: Int,
) -> Progress {
  let card =
    dict.get(progress.cards, exercise_id)
    |> result.unwrap(srs.new(now))
    |> srs.review(grade, now)
  Progress(
    ..progress,
    cards: dict.insert(progress.cards, exercise_id, card),
    streak: extend_streak(progress.streak, today),
  )
}

fn extend_streak(streak: Streak, today: Int) -> Streak {
  case today - streak.last_day {
    0 -> streak
    1 -> Streak(last_day: today, days: streak.days + 1)
    _ -> Streak(last_day: today, days: 1)
  }
}

/// Consecutive practice days, still counting today if the learner practised
/// yesterday but not yet today.
pub fn streak_days(progress: Progress, today: Int) -> Int {
  case today - progress.streak.last_day {
    0 | 1 -> progress.streak.days
    _ -> 0
  }
}

/// Picks up to `size` exercises: due ones first, most overdue first, then
/// new ones, easiest level first and otherwise in the given order. If that
/// is not enough, the rest are the ones due soonest, which can be practised
/// ahead without being promoted.
pub fn plan_round(
  progress: Progress,
  exercises: List(Exercise),
  now now: Int,
  size size: Int,
) -> List(Exercise) {
  let #(seen, new) =
    list.partition(exercises, fn(e) { dict.has_key(progress.cards, e.id) })
  let by_due =
    seen
    |> list.map(fn(e) {
      let assert Ok(card) = dict.get(progress.cards, e.id)
      #(e, card)
    })
    |> list.sort(fn(a, b) { int.compare({ a.1 }.due, { b.1 }.due) })
  // `list.sort` is stable, so the given order is kept within a level.
  let new =
    list.sort(new, fn(a, b) { lexicon.compare_levels(a.level, b.level) })
  let #(due, later) =
    list.partition(by_due, fn(pair) { srs.is_due(pair.1, now) })

  list.flatten([
    list.map(due, fn(p) { p.0 }),
    new,
    list.map(later, fn(p) { p.0 }),
  ])
  |> list.take(size)
}

/// Picks up to `size` exercises from several groups (one per drill) for a
/// mixed round. Due exercises come first, most overdue first, whatever
/// their group. Then new exercises are taken one group at a time in turn,
/// easiest level first within a group, so that a big group (conjugation)
/// does not crowd out the others. Any rest are the ones due soonest.
pub fn plan_mixed_round(
  progress: Progress,
  groups: List(List(Exercise)),
  now now: Int,
  size size: Int,
) -> List(Exercise) {
  let all = list.flatten(groups)
  let due = due(progress, all, now:) |> list.take(size)
  let new =
    groups
    |> list.map(fn(group) {
      group
      |> list.filter(fn(e) { !dict.has_key(progress.cards, e.id) })
      |> list.sort(fn(a, b) { lexicon.compare_levels(a.level, b.level) })
    })
    |> round_robin([])
    |> list.take(size - list.length(due))
  let chosen = list.append(due, new)
  let later =
    plan_round(progress, all, now:, size: size)
    |> list.filter(fn(e) { !list.contains(chosen, e) })
  list.append(chosen, later) |> list.take(size)
}

/// Takes the first of every list, then the second of every list, and so on.
fn round_robin(lists: List(List(a)), acc: List(a)) -> List(a) {
  case list.filter(lists, fn(l) { l != [] }) {
    [] -> list.reverse(acc)
    lists -> {
      let firsts = list.filter_map(lists, list.first)
      let rests = list.map(lists, fn(l) { list.drop(l, 1) })
      round_robin(rests, list.append(list.reverse(firsts), acc))
    }
  }
}

/// The exercises that are due for review, the most overdue first.
pub fn due(
  progress: Progress,
  exercises: List(Exercise),
  now now: Int,
) -> List(Exercise) {
  exercises
  |> list.filter_map(fn(e) {
    case dict.get(progress.cards, e.id) {
      Ok(card) if card.due <= now -> Ok(#(e, card.due))
      _ -> Error(Nil)
    }
  })
  |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
  |> list.map(fn(pair) { pair.0 })
}

/// The exercises answered wrong at least once, most mistakes first and,
/// among equals, the least well known first.
pub fn difficult(
  progress: Progress,
  exercises: List(Exercise),
) -> List(#(Exercise, CardState)) {
  exercises
  |> list.filter_map(fn(e) {
    case dict.get(progress.cards, e.id) {
      Ok(card) if card.lapses > 0 -> Ok(#(e, card))
      _ -> Error(Nil)
    }
  })
  |> list.sort(fn(a, b) {
    case int.compare({ b.1 }.lapses, { a.1 }.lapses) {
      order.Eq -> int.compare({ a.1 }.box, { b.1 }.box)
      other -> other
    }
  })
}

pub fn stats(
  progress: Progress,
  exercises: List(Exercise),
  now now: Int,
) -> Stats {
  list.fold(exercises, Stats(0, 0, 0, 0), fn(stats, exercise) {
    case dict.get(progress.cards, exercise.id) {
      Error(Nil) -> Stats(..stats, new: stats.new + 1)
      Ok(card) ->
        case srs.is_due(card, now), card.box >= learned_box {
          True, _ -> Stats(..stats, due: stats.due + 1)
          False, True -> Stats(..stats, learned: stats.learned + 1)
          False, False -> Stats(..stats, learning: stats.learning + 1)
        }
    }
  })
}

// JSON ------------------------------------------------------------------------

pub fn to_json(progress: Progress) -> String {
  json.object([
    #("version", json.int(version)),
    #("read_aloud", json.bool(progress.read_aloud)),
    #(
      "level",
      json.nullable(progress.level, fn(level) { json.string(level_id(level)) }),
    ),
    #("voice", json.nullable(progress.voice, json.string)),
    #(
      "streak",
      json.object([
        #("last_day", json.int(progress.streak.last_day)),
        #("days", json.int(progress.streak.days)),
      ]),
    ),
    #(
      "cards",
      json.dict(progress.cards, fn(id) { id }, fn(card) {
        json.object([
          #("box", json.int(card.box)),
          #("due", json.int(card.due)),
          #("reviews", json.int(card.reviews)),
          #("lapses", json.int(card.lapses)),
        ])
      }),
    ),
  ])
  |> json.to_string
}

/// Fails on anything that is not progress in the current format.
pub fn from_json(text: String) -> Result(Progress, Nil) {
  json.parse(text, progress_decoder())
  |> result.replace_error(Nil)
}

fn progress_decoder() -> Decoder(Progress) {
  use stored_version <- decode.field("version", decode.int)
  case stored_version == version {
    False ->
      decode.failure(new(), "progress version " <> int.to_string(version))
    True -> {
      use read_aloud <- decode.optional_field("read_aloud", True, decode.bool)
      use level <- decode.optional_field(
        "level",
        None,
        decode.optional(decode.string)
          |> decode.map(option.then(_, parse_level)),
      )
      use voice <- decode.optional_field(
        "voice",
        None,
        decode.optional(decode.string),
      )
      use streak <- decode.optional_field(
        "streak",
        Streak(-1, 0),
        streak_decoder(),
      )
      use cards <- decode.field(
        "cards",
        decode.dict(decode.string, card_decoder()),
      )
      decode.success(Progress(cards:, read_aloud:, level:, voice:, streak:))
    }
  }
}

fn level_id(level: Level) -> String {
  case level {
    lexicon.A1 -> "A1"
    lexicon.A2 -> "A2"
  }
}

/// An unknown level falls back to both, rather than failing the load.
fn parse_level(id: String) -> Option(Level) {
  case id {
    "A1" -> Some(lexicon.A1)
    "A2" -> Some(lexicon.A2)
    _ -> None
  }
}

fn streak_decoder() -> Decoder(Streak) {
  use last_day <- decode.field("last_day", decode.int)
  use days <- decode.field("days", decode.int)
  decode.success(Streak(last_day:, days:))
}

fn card_decoder() -> Decoder(CardState) {
  use box <- decode.field("box", decode.int)
  use due <- decode.field("due", decode.int)
  use reviews <- decode.field("reviews", decode.int)
  use lapses <- decode.field("lapses", decode.int)
  decode.success(CardState(box:, due:, reviews:, lapses:))
}
