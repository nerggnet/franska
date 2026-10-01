//// Leitner-style spaced repetition. Every exercise sits in a box; a correct
//// answer moves it up a box and pushes the next review further away, a
//// wrong answer sends it back to the first box.
////
//// All times are Unix timestamps in seconds, passed in by the caller, so
//// scheduling stays pure and easy to test.

import franska/answer.{type Grade, Almost, Correct, Wrong}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list

pub type CardState {
  /// `box` 0 means never reviewed.
  CardState(box: Int, due: Int, reviews: Int, lapses: Int)
}

pub const max_box = 6

const minute = 60

const day = 86_400

/// A card that has never been reviewed is due immediately.
pub fn new(now: Int) -> CardState {
  CardState(box: 0, due: now, reviews: 0, lapses: 0)
}

/// Time until the next review for a card that has just reached `box`.
pub fn interval(box: Int) -> Int {
  case box {
    1 -> day
    2 -> 3 * day
    3 -> 7 * day
    4 -> 14 * day
    5 -> 30 * day
    _ if box >= max_box -> 90 * day
    _ -> 0
  }
}

pub fn review(state: CardState, grade: Grade, now: Int) -> CardState {
  let reviews = state.reviews + 1
  case grade {
    Correct -> {
      let box = int.min(state.box + 1, max_box)
      CardState(..state, box:, due: now + interval(box), reviews:)
    }
    // Almost right: not good enough to move up, but no reason to start over.
    Almost(..) -> {
      let box = int.max(state.box, 1)
      CardState(..state, box:, due: now + interval(box), reviews:)
    }
    // Wrong: back to the first box and shown again later in the session.
    Wrong(..) ->
      CardState(
        box: 1,
        due: now + 10 * minute,
        reviews:,
        lapses: state.lapses + 1,
      )
  }
}

pub fn is_due(state: CardState, now: Int) -> Bool {
  state.due <= now
}

/// Ids of the cards that are due, the most overdue first.
pub fn due(cards: Dict(String, CardState), now: Int) -> List(String) {
  cards
  |> dict.to_list
  |> list.filter(fn(card) { is_due(card.1, now) })
  |> list.sort(fn(a, b) {
    let #(_, a) = a
    let #(_, b) = b
    int.compare(a.due, b.due)
  })
  |> list.map(fn(card) { card.0 })
}
