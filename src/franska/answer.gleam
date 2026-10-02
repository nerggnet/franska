//// Grading of typed answers. Grading is forgiving in the ways that matter
//// to a learner: case, spacing, apostrophe style and trailing punctuation
//// never count, while missing accents, small typos and article mistakes
//// are reported as `Almost` so the learner gets a precise hint.

import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Language {
  French
  Swedish
}

pub type Mistake {
  /// Right letters, wrong or missing diacritics: "ecole" for "école".
  MissingAccents
  /// One or two letters off.
  Typo
  /// The noun is right, give or take accents and a typo, but the article
  /// was left out: "chat" for "le chat".
  MissingArticle
  /// The noun is right but the article is wrong: "la chat" for "le chat".
  WrongArticle
}

pub type Grade {
  Correct
  Almost(expected: String, mistake: Mistake)
  Wrong(expected: String)
}

/// Grades `answer` against the accepted answers, canonical answer first.
pub fn grade(
  answer: String,
  accepted accepted: List(String),
  language language: Language,
) -> Grade {
  grade_with(answer, accepted, language, allow_typos: True)
}

/// Like `grade`, but a small spelling difference is wrong rather than a
/// typo. For rewriting whole sentences, where one or two letters are the
/// point of the exercise: "Je le vois" for "Je la vois".
pub fn grade_without_typos(
  answer: String,
  accepted accepted: List(String),
  language language: Language,
) -> Grade {
  grade_with(answer, accepted, language, allow_typos: False)
}

fn grade_with(
  answer: String,
  accepted: List(String),
  language: Language,
  allow_typos allow_typos: Bool,
) -> Grade {
  let canonical = list.first(accepted) |> result.unwrap("")
  let given = normalise(answer, language)
  let candidates = list.map(accepted, fn(a) { #(a, normalise(a, language)) })
  let folded = fold(given, language)

  let close = fn(check: fn(String) -> Bool, mistake: Mistake) {
    list.find(candidates, fn(c) { check(c.1) })
    |> result.map(fn(c) { Almost(c.0, mistake) })
  }

  use <- bool.guard(given == "", Wrong(canonical))
  use <- bool.guard(list.any(candidates, fn(c) { c.1 == given }), Correct)

  close(fn(c) { fold(c, language) == folded }, MissingAccents)
  |> result.lazy_or(fn() { article_mistake(given, candidates, language) })
  |> result.lazy_or(fn() {
    use <- bool.guard(!allow_typos, Error(Nil))
    close(
      fn(c) {
        let c = fold(c, language)
        distance(folded, c) <= allowed_typos(string.length(c))
      },
      Typo,
    )
  })
  |> result.unwrap(Wrong(canonical))
}

/// A short Swedish explanation of a grade, for showing to the learner.
pub fn explain(grade: Grade) -> String {
  case grade {
    Correct -> "Rätt!"
    Almost(expected:, mistake: MissingAccents) ->
      "Nästan! Glöm inte accenterna: " <> expected
    Almost(expected:, mistake: Typo) -> "Nästan! Kolla stavningen: " <> expected
    Almost(expected:, mistake: MissingArticle) ->
      "Nästan! Glöm inte artikeln: " <> expected
    Almost(expected:, mistake: WrongArticle) ->
      "Nästan! Fel artikel: " <> expected
    Wrong(expected:) -> "Fel. Rätt svar: " <> expected
  }
}

/// Removes differences that never matter: case, surrounding and repeated
/// whitespace, apostrophe style, trailing punctuation and Unicode
/// composition. Swedish answers may also leave out a leading en/ett/att.
pub fn normalise(text: String, language: Language) -> String {
  let text =
    text
    |> string.lowercase
    |> compose_accents
    |> string.replace("’", "'")
    |> string.replace("‘", "'")
    |> string.replace("`", "'")
    |> string.split(" ")
    |> list.filter(fn(word) { word != "" })
    |> string.join(" ")
    |> string.replace("' ", "'")
    |> strip_trailing_punctuation

  case language {
    French -> text
    Swedish ->
      case text {
        "en " <> rest | "ett " <> rest | "att " <> rest -> rest
        _ -> text
      }
  }
}

/// Removes diacritics that a learner may plausibly leave out. Swedish å, ä
/// and ö are distinct letters, so they are kept.
pub fn fold(text: String, language: Language) -> String {
  text
  |> string.to_graphemes
  |> list.map(fn(c) {
    case language, c {
      _, "é" | _, "è" -> "e"
      Swedish, _ -> c
      French, "à" | French, "â" | French, "ä" -> "a"
      French, "ê" | French, "ë" -> "e"
      French, "î" | French, "ï" -> "i"
      French, "ô" | French, "ö" -> "o"
      French, "ù" | French, "û" | French, "ü" -> "u"
      French, "ÿ" -> "y"
      French, "ç" -> "c"
      French, "œ" -> "oe"
      French, "æ" -> "ae"
      French, _ -> c
    }
  })
  |> string.concat
}

fn article_mistake(
  given: String,
  candidates: List(#(String, String)),
  language: Language,
) -> Result(Grade, Nil) {
  use <- bool.guard(language != French, Error(Nil))
  let #(given_article, given_rest) = split_article(given)
  let given_rest = fold(given_rest, language)
  list.find_map(candidates, fn(candidate) {
    let #(original, normalised) = candidate
    let #(article, rest) = split_article(normalised)
    let rest = fold(rest, language)
    let same_noun =
      distance(given_rest, rest) <= allowed_typos(string.length(rest))
    case article, given_article {
      Some(_), _ if !same_noun -> Error(Nil)
      Some(_), None -> Ok(Almost(original, MissingArticle))
      Some(a), Some(b) if a != b -> Ok(Almost(original, WrongArticle))
      _, _ -> Error(Nil)
    }
  })
}

fn split_article(text: String) -> #(Option(String), String) {
  case text {
    "l'" <> rest -> #(Some("l'"), rest)
    _ ->
      case string.split_once(text, " ") {
        Ok(#(article, rest)) ->
          case list.contains(["le", "la", "les", "un", "une", "des"], article) {
            True -> #(Some(article), rest)
            False -> #(None, text)
          }
        Error(Nil) -> #(None, text)
      }
  }
}

fn allowed_typos(length: Int) -> Int {
  case length {
    _ if length < 4 -> 0
    _ if length < 8 -> 1
    _ -> 2
  }
}

fn strip_trailing_punctuation(text: String) -> String {
  // ends_with first: string.last is slow on JavaScript, and most text has
  // no trailing punctuation.
  case list.any([".", "!", "?", "…", " "], string.ends_with(text, _)) {
    True -> strip_trailing_punctuation(string.drop_end(text, 1))
    False -> text
  }
}

/// Composes letters followed by a combining accent, if there are any.
fn compose_accents(text: String) -> String {
  case list.any(combining_accents, string.contains(text, _)) {
    False -> text
    True ->
      text
      |> string.to_graphemes
      |> list.map(compose)
      |> string.concat
  }
}

const combining_accents = [
  "\u{300}", "\u{301}", "\u{302}", "\u{308}", "\u{30A}", "\u{327}",
]

/// Composes a base letter followed by a combining accent into the single
/// precomposed character, so "e\u{301}" compares equal to "é".
fn compose(grapheme: String) -> String {
  case grapheme {
    "a\u{300}" -> "à"
    "a\u{302}" -> "â"
    "a\u{308}" -> "ä"
    "a\u{30A}" -> "å"
    "c\u{327}" -> "ç"
    "e\u{300}" -> "è"
    "e\u{301}" -> "é"
    "e\u{302}" -> "ê"
    "e\u{308}" -> "ë"
    "i\u{302}" -> "î"
    "i\u{308}" -> "ï"
    "o\u{302}" -> "ô"
    "o\u{308}" -> "ö"
    "u\u{300}" -> "ù"
    "u\u{302}" -> "û"
    "u\u{308}" -> "ü"
    "y\u{308}" -> "ÿ"
    _ -> grapheme
  }
}

/// Edit distance between two strings, counted in graphemes, where an
/// insertion, deletion, substitution or swap of two adjacent letters each
/// count as one edit (optimal string alignment distance).
fn distance(a: String, b: String) -> Int {
  let a = list.index_map(string.to_graphemes(a), fn(c, i) { #(i + 1, c) })
  let b = list.index_map(string.to_graphemes(b), fn(c, j) { #(j + 1, c) })
  let at = fn(table, i, j) {
    case i, j {
      0, _ -> j
      _, 0 -> i
      _, _ -> dict.get(table, #(i, j)) |> result.unwrap(0)
    }
  }
  let table =
    list.fold(a, dict.new(), fn(table, x) {
      let #(i, ca) = x
      list.fold(b, table, fn(table, y) {
        let #(j, cb) = y
        let cost = case ca == cb {
          True -> 0
          False -> 1
        }
        let best =
          int.min(at(table, i - 1, j) + 1, at(table, i, j - 1) + 1)
          |> int.min(at(table, i - 1, j - 1) + cost)
        let swapped =
          i > 1
          && j > 1
          && Ok(ca) == list.key_find(b, j - 1)
          && Ok(cb) == list.key_find(a, i - 1)
        let best = case swapped {
          True -> int.min(best, at(table, i - 2, j - 2) + 1)
          False -> best
        }
        dict.insert(table, #(i, j), best)
      })
    })
  at(table, list.length(a), list.length(b))
}
