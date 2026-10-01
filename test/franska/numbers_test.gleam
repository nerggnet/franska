import franska/answer.{Almost, Correct, Typo}
import franska/exercise
import franska/numbers
import gleam/list

pub fn small_numbers_test() {
  assert list.map([0, 1, 7, 10, 11, 16], numbers.to_french)
    == ["zéro", "un", "sept", "dix", "onze", "seize"]
}

pub fn teens_and_tens_test() {
  assert list.map([17, 19, 20, 21, 22, 30, 31, 45, 60, 61], numbers.to_french)
    == [
      "dix-sept", "dix-neuf", "vingt", "vingt et un", "vingt-deux", "trente",
      "trente et un", "quarante-cinq", "soixante", "soixante et un",
    ]
}

pub fn seventies_to_nineties_test() {
  assert list.map([70, 71, 72, 77, 80, 81, 90, 91, 99], numbers.to_french)
    == [
      "soixante-dix", "soixante et onze", "soixante-douze", "soixante-dix-sept",
      "quatre-vingts", "quatre-vingt-un", "quatre-vingt-dix",
      "quatre-vingt-onze", "quatre-vingt-dix-neuf",
    ]
}

pub fn hundreds_and_thousands_test() {
  assert list.map([100, 101, 200, 201, 280, 999], numbers.to_french)
    == [
      "cent", "cent un", "deux cents", "deux cent un", "deux cent quatre-vingts",
      "neuf cent quatre-vingt-dix-neuf",
    ]
  assert list.map([1000, 1001, 2000, 2026], numbers.to_french)
    == ["mille", "mille un", "deux mille", "deux mille vingt-six"]
}

pub fn reformed_spelling_is_accepted_test() {
  assert numbers.accepted(21) == ["vingt et un", "vingt-et-un"]
  assert numbers.accepted(201) == ["deux cent un", "deux-cent-un"]
  assert numbers.accepted(1) == ["un", "une"]
}

pub fn exercises_ask_for_the_words_test() {
  let assert Ok(ex) =
    numbers.exercises() |> list.find(fn(e) { e.id == "number:71" })
  assert ex.prompt == "71"
  assert exercise.check(ex, "soixante et onze") == Correct
  assert exercise.check(ex, "soixante-et-onze") == Correct
  let assert Ok(ex) =
    numbers.exercises() |> list.find(fn(e) { e.id == "number:70" })
  assert exercise.check(ex, "soixante dix") == Almost("soixante-dix", Typo)
}
