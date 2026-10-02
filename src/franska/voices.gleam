//// Choosing speech synthesis voices and preparing text for them. Browsers
//// offer very different French voices; some (premium and natural ones)
//// sound much better than others (the novelty voices Eddy, Flo, Rocko...),
//// so the voices are ranked rather than taking the first French one.

import gleam/int
import gleam/list
import gleam/string

/// A voice as the browser describes it.
pub type Voice {
  Voice(name: String, lang: String)
}

/// The French voices, best first.
pub fn rank(voices: List(Voice)) -> List(Voice) {
  voices
  |> list.filter(fn(v) { string.starts_with(string.lowercase(v.lang), "fr") })
  |> list.map(fn(v) { #(v, score(v)) })
  // list.sort is stable, so equal voices keep the browser's order.
  |> list.sort(fn(a, b) { int.compare(b.1, a.1) })
  |> list.map(fn(pair) { pair.0 })
}

fn score(voice: Voice) -> Int {
  let name = string.lowercase(voice.name)
  let points = fn(matches: Bool, points: Int) {
    case matches {
      True -> points
      False -> 0
    }
  }
  let has = fn(words: List(String)) {
    list.any(words, string.contains(name, _))
  }
  points(has(["premium"]), 8)
  + points(has(["enhanced", "förbättrad", "améliorée", "natural", "neural"]), 6)
  + points(has(["online", "google"]), 4)
  + points(is_classic(name), 2)
  + points(is_novelty(name), -10)
  + points(string.lowercase(voice.lang) == "fr-fr", 3)
}

/// Well-made standard voices on macOS, iOS, Windows and Android.
fn is_classic(name: String) -> Bool {
  list.any(
    [
      "thomas", "audrey", "amélie", "aurélie", "marie", "virginie", "julie",
      "hortense", "denise", "henri", "eloise", "paul", "jacques",
    ],
    fn(classic) { string.starts_with(name, classic) },
  )
}

/// Apple's novelty voices, which are clearly worse for learning.
fn is_novelty(name: String) -> Bool {
  list.any(
    [
      "eddy", "flo", "grandma", "grandpa", "reed", "rocko", "sandy", "shelley",
      "bad news", "bells", "boing", "bubbles", "jester", "organ", "superstar",
      "trinoids", "whisper", "wobble", "zarvox", "albert", "bahh", "cellos",
    ],
    fn(novelty) { string.starts_with(name, novelty) },
  )
}

pub type Gender {
  Female
  Male
  Unknown
}

/// The likely gender of a voice from its name, for giving the two people
/// in a dialogue different voices.
pub fn gender(voice: Voice) -> Gender {
  let name = string.lowercase(voice.name)
  let starts = fn(names: List(String)) {
    list.any(names, string.starts_with(name, _))
  }
  case
    starts([
      "audrey", "amélie", "aurélie", "marie", "virginie", "julie", "hortense",
      "denise", "eloise", "flo", "sandy", "shelley", "grandma", "céline",
      "chantal", "léa",
    ]),
    starts([
      "thomas", "jacques", "paul", "henri", "eddy", "reed", "rocko", "grandpa",
      "nicolas", "daniel", "claude",
    ])
  {
    True, _ -> Female
    _, True -> Male
    _, _ -> Unknown
  }
}

/// The voice for the second person in a dialogue: the best voice of the
/// other gender, or else any other voice, or else the same one.
pub fn partner(main: Voice, ranked: List(Voice)) -> Voice {
  let others = list.filter(ranked, fn(v) { v.name != main.name })
  let other_gender = case gender(main) {
    Female -> list.find(others, fn(v) { gender(v) == Male })
    Male -> list.find(others, fn(v) { gender(v) == Female })
    Unknown -> Error(Nil)
  }
  case other_gender, others {
    Ok(voice), _ -> voice
    Error(Nil), [first, ..] -> first
    Error(Nil), [] -> main
  }
}

/// A text split into what to say, one sentence or dialogue line at a time,
/// each with its speaker (0 or 1). Lines starting with a dash are dialogue:
/// the dash is dropped and the speakers take turns. Shorter utterances keep
/// their intonation better, and some browsers stop long ones half-way.
pub fn utterances(text: String) -> List(#(Int, String)) {
  let lines =
    string.split(text, "\n")
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" })
  let #(_, out) =
    list.fold(lines, #(0, []), fn(acc, line) {
      let #(turn, out) = acc
      case dialogue_line(line) {
        Ok(spoken) -> #(turn + 1, [#(turn % 2, spoken), ..out])
        Error(Nil) -> {
          let sentences =
            sentences(line) |> list.map(fn(sentence) { #(0, sentence) })
          #(turn, list.append(list.reverse(sentences), out))
        }
      }
    })
  list.reverse(out)
}

fn dialogue_line(line: String) -> Result(String, Nil) {
  case line {
    "— " <> rest | "– " <> rest | "- " <> rest -> Ok(string.trim(rest))
    "—" <> rest | "–" <> rest -> Ok(string.trim(rest))
    _ -> Error(Nil)
  }
}

/// Splits after . ! ? followed by a space. French puts a space before ! and
/// ?, so "Salut Sophie !" stays whole.
fn sentences(line: String) -> List(String) {
  let #(current, done) =
    string.to_graphemes(line)
    |> list.fold(#("", []), fn(acc, char) {
      let #(current, done) = acc
      let ends =
        { string.ends_with(current, ".") && !is_abbreviation(current) }
        || string.ends_with(current, "!")
        || string.ends_with(current, "?")
      case char == " " && ends {
        True -> #("", [current, ..done])
        False -> #(current <> char, done)
      }
    })
  [current, ..done]
  |> list.map(string.trim)
  |> list.filter(fn(s) { s != "" })
  |> list.reverse
}

/// "M. Dupont" is one sentence.
fn is_abbreviation(text: String) -> Bool {
  case string.split(text, " ") |> list.last {
    Ok("M.") | Ok("Mme.") | Ok("Dr.") | Ok("etc.") -> True
    _ -> False
  }
}
