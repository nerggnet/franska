//// A little Swedish grammar, for showing translations in the right form.

import gleam/string

/// The plural of a Swedish adjective: stor → stora, vacker → vackra,
/// öppen → öppna, tom → tomma, förvånad → förvånade. Adjectives ending in
/// a vowel other than the long ones (bra, rosa, nästa) and fel do not
/// change, nor do blå and grå in writing; liten, gammal and annan are
/// irregular.
pub fn adjective_plural(adjective: String) -> String {
  case adjective {
    "liten" -> "små"
    "gammal" -> "gamla"
    "annan" -> "andra"
    "fel" | "blå" | "grå" -> adjective
    _ ->
      case ends_with_any(adjective, ["a", "e", "o"]) {
        True -> adjective
        False -> regular_plural(adjective)
      }
  }
}

fn regular_plural(adjective: String) -> String {
  let length = string.length(adjective)
  case adjective {
    // vacker, säker, enkel: the e drops.
    _ if length > 3 ->
      case
        ends_with_any(adjective, ["er", "el"]),
        ends_with_unstressed_en(adjective)
      {
        True, _ | _, True ->
          string.drop_end(adjective, 2)
          <> string.slice(adjective, length - 1, 1)
          <> "a"
        False, False ->
          // Past participles in -ad (förvånad), not short words like glad.
          case string.ends_with(adjective, "ad") && length > 5 {
            True -> adjective <> "e"
            False -> double_final_m(adjective) <> "a"
          }
      }
    _ -> double_final_m(adjective) <> "a"
  }
}

/// öppen, ledsen, mogen, but not ren or grön.
fn ends_with_unstressed_en(adjective: String) -> Bool {
  string.ends_with(adjective, "en")
  && !ends_with_any(string.drop_end(adjective, 2), [
    "a",
    "e",
    "i",
    "o",
    "u",
    "y",
    "å",
    "ä",
    "ö",
  ])
}

/// tom → tomm-, ensam → ensamm-, but varm stays varm-.
fn double_final_m(adjective: String) -> String {
  case
    string.ends_with(adjective, "m"),
    ends_with_any(string.drop_end(adjective, 1), [
      "a",
      "e",
      "i",
      "o",
      "u",
      "y",
      "å",
      "ä",
      "ö",
    ])
  {
    True, True -> adjective <> "m"
    _, _ -> adjective
  }
}

fn ends_with_any(text: String, endings: List(String)) -> Bool {
  case endings {
    [] -> False
    [ending, ..rest] ->
      string.ends_with(text, ending) || ends_with_any(text, rest)
  }
}
