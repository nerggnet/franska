//// French number words, generated rather than curated. Spelling follows
//// the traditional rules (hyphens below a hundred except around "et",
//// "quatre-vingts" and "deux cents" but "deux cent un"); the 1990 reform,
//// which hyphenates everything, is accepted too.

import franska/answer
import franska/exercise.{type Exercise, Exercise, WriteNumber}
import franska/lexicon.{A1, A2}
import gleam/int
import gleam/list
import gleam/string

/// The numbers practised: everything up to a hundred, then round hundreds
/// and a couple of thousands.
pub fn practised() -> List(Int) {
  list.flatten([
    int.range(from: 0, to: 101, with: [], run: list.prepend) |> list.reverse,
    [200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000],
  ])
}

pub fn exercises() -> List(Exercise) {
  use number <- list.map(practised())
  let french = to_french(number)
  Exercise(
    id: "number:" <> int.to_string(number),
    entry_id: "number:" <> int.to_string(number),
    kind: WriteNumber(number),
    prompt: int.to_string(number),
    accepted: accepted(number),
    answer_language: answer.French,
    french:,
    level: case number <= 100 {
      True -> A1
      False -> A2
    },
  )
}

/// Every accepted spelling, traditional first.
pub fn accepted(number: Int) -> List(String) {
  let traditional = to_french(number)
  let reformed = string.replace(traditional, " ", "-")
  let feminine = case number {
    1 -> ["une"]
    _ -> []
  }
  list.unique([traditional, reformed, ..feminine])
}

/// The number in words, traditional spelling. Covers 0 to 9 999.
pub fn to_french(number: Int) -> String {
  case number {
    0 -> "zéro"
    _ -> {
      let thousands = number / 1000
      let rest = number % 1000
      let thousands_words = case thousands {
        0 -> []
        1 -> ["mille"]
        _ -> [below_hundred(thousands), "mille"]
      }
      let rest_words = case rest {
        0 -> []
        _ -> [below_thousand(rest)]
      }
      string.join(list.append(thousands_words, rest_words), " ")
    }
  }
}

fn below_thousand(number: Int) -> String {
  let hundreds = number / 100
  let rest = number % 100
  let hundreds_words = case hundreds, rest {
    0, _ -> []
    1, _ -> ["cent"]
    // "cent" takes an s when multiplied and nothing follows.
    _, 0 -> [unit(hundreds), "cents"]
    _, _ -> [unit(hundreds), "cent"]
  }
  let rest_words = case rest {
    0 -> []
    _ -> [below_hundred(rest)]
  }
  string.join(list.append(hundreds_words, rest_words), " ")
}

fn below_hundred(number: Int) -> String {
  case number {
    _ if number < 17 -> unit(number)
    _ if number < 20 -> "dix-" <> unit(number - 10)
    _ if number < 70 -> {
      let tens = tens_word(number / 10)
      case number % 10 {
        0 -> tens
        1 -> tens <> " et un"
        units -> tens <> "-" <> unit(units)
      }
    }
    71 -> "soixante et onze"
    _ if number < 80 -> "soixante-" <> below_hundred(number - 60)
    80 -> "quatre-vingts"
    _ -> "quatre-vingt-" <> below_hundred(number - 80)
  }
}

fn tens_word(tens: Int) -> String {
  case tens {
    2 -> "vingt"
    3 -> "trente"
    4 -> "quarante"
    5 -> "cinquante"
    _ -> "soixante"
  }
}

fn unit(number: Int) -> String {
  case number {
    1 -> "un"
    2 -> "deux"
    3 -> "trois"
    4 -> "quatre"
    5 -> "cinq"
    6 -> "six"
    7 -> "sept"
    8 -> "huit"
    9 -> "neuf"
    10 -> "dix"
    11 -> "onze"
    12 -> "douze"
    13 -> "treize"
    14 -> "quatorze"
    15 -> "quinze"
    _ -> "seize"
  }
}
