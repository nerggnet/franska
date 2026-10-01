import franska/answer.{Almost, Correct, MissingAccents, Wrong}
import franska/srs.{CardState}
import gleam/dict

const now = 1_000_000

const day = 86_400

pub fn new_card_is_due_immediately_test() {
  assert srs.is_due(srs.new(now), now)
}

pub fn correct_moves_up_a_box_test() {
  let state = srs.new(now) |> srs.review(Correct, now)
  assert state == CardState(box: 1, due: now + day, reviews: 1, lapses: 0)
  let state = srs.review(state, Correct, now + day)
  assert state.box == 2
  assert state.due == now + day + 3 * day
}

pub fn box_is_capped_test() {
  let state = CardState(box: srs.max_box, due: now, reviews: 10, lapses: 0)
  assert srs.review(state, Correct, now).box == srs.max_box
}

pub fn almost_keeps_box_test() {
  let state = CardState(box: 3, due: now, reviews: 5, lapses: 0)
  let state = srs.review(state, Almost("école", MissingAccents), now)
  assert state.box == 3
  assert state.due == now + 7 * day
}

pub fn almost_on_new_card_enters_first_box_test() {
  let state = srs.new(now) |> srs.review(Almost("école", MissingAccents), now)
  assert state.box == 1
}

pub fn wrong_resets_to_first_box_and_counts_lapse_test() {
  let state = CardState(box: 4, due: now, reviews: 8, lapses: 1)
  let state = srs.review(state, Wrong("école"), now)
  assert state == CardState(box: 1, due: now + 600, reviews: 9, lapses: 2)
  assert !srs.is_due(state, now)
  assert srs.is_due(state, now + 600)
}

pub fn due_lists_most_overdue_first_test() {
  let cards =
    dict.from_list([
      #("a", CardState(box: 1, due: now - 10, reviews: 1, lapses: 0)),
      #("b", CardState(box: 2, due: now + 10, reviews: 1, lapses: 0)),
      #("c", CardState(box: 1, due: now - 50, reviews: 1, lapses: 0)),
    ])
  assert srs.due(cards, now) == ["c", "a"]
}
