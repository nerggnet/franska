//// The vocabulary a learner studies. Content is curated as a list of
//// `Entry` values; exercises are derived from them (see `franska/exercise`).

import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type Level {
  A1
  A2
}

/// Orders levels from easiest to hardest.
pub fn compare_levels(a: Level, b: Level) -> order.Order {
  int.compare(level_rank(a), level_rank(b))
}

fn level_rank(level: Level) -> Int {
  case level {
    A1 -> 1
    A2 -> 2
  }
}

pub type Gender {
  Masculine
  Feminine
}

/// Grammatical persons. `Il` covers il/elle/on and `Ils` covers ils/elles.
pub type Person {
  Je
  Tu
  Il
  Nous
  Vous
  Ils
}

/// Présent de l'indicatif, one form per person (without pronoun).
pub type Present {
  Present(
    je: String,
    tu: String,
    il: String,
    nous: String,
    vous: String,
    ils: String,
  )
}

pub type Word {
  /// `fr` is the bare noun ("chat"). `elides` is True when the definite
  /// article becomes l' ("l'école", "l'homme").
  Noun(fr: String, gender: Gender, elides: Bool)
  Verb(infinitive: String, present: Present)
  /// Any fixed phrase. The first French variant is the canonical one.
  Expression(fr: List(String))
}

/// A unit of curated content. `id` must be unique across all content and
/// stable over time, since learner progress is stored against it.
/// `sv` lists accepted Swedish translations, canonical one first.
pub type Entry {
  Entry(id: String, level: Level, theme: String, sv: List(String), word: Word)
}

pub const persons = [Je, Tu, Il, Nous, Vous, Ils]

pub type Tense {
  Presens
  /// aller + infinitive: "je vais parler".
  FuturProche
}

pub const tenses = [Presens, FuturProche]

/// Stable id of a tense, part of exercise ids.
pub fn tense_id(tense: Tense) -> String {
  case tense {
    Presens -> "present"
    FuturProche -> "futur-proche"
  }
}

/// A noun whose article elision follows the spelling: l' before a vowel or
/// h. Use `noun_aspirated_h` for the h aspiré exceptions ("le héros").
pub fn noun(fr: String, gender: Gender) -> Word {
  Noun(fr:, gender:, elides: starts_with_vowel_sound(fr))
}

pub fn noun_aspirated_h(fr: String, gender: Gender) -> Word {
  Noun(fr:, gender:, elides: False)
}

pub fn definite_article(word: Word) -> Result(String, Nil) {
  case word {
    Noun(elides: True, ..) -> Ok("l'")
    Noun(gender: Masculine, ..) -> Ok("le")
    Noun(gender: Feminine, ..) -> Ok("la")
    Verb(..) | Expression(..) -> Error(Nil)
  }
}

/// The canonical French form a learner should produce: nouns with their
/// definite article, verbs as infinitives.
pub fn french(word: Word) -> String {
  case word {
    Noun(fr:, elides: True, ..) -> "l'" <> fr
    Noun(fr:, gender: Masculine, ..) -> "le " <> fr
    Noun(fr:, gender: Feminine, ..) -> "la " <> fr
    Verb(infinitive:, ..) -> infinitive
    Expression(fr: [first, ..]) -> first
    Expression(fr: []) -> ""
  }
}

pub fn conjugate(present: Present, person: Person) -> String {
  case person {
    Je -> present.je
    Tu -> present.tu
    Il -> present.il
    Nous -> present.nous
    Vous -> present.vous
    Ils -> present.ils
  }
}

/// The subject pronoun joined to a verb form: "je parle", "j'aime".
pub fn with_pronoun(form: String, person: Person) -> String {
  with_subject(pronoun(person), form)
}

fn with_subject(subject: String, form: String) -> String {
  case subject, starts_with_vowel_sound(form) {
    "je", True -> "j'" <> form
    _, _ -> subject <> " " <> form
  }
}

/// Every subject a person covers, the canonical one first.
fn subjects(person: Person) -> List(String) {
  case person {
    Il -> ["il", "elle", "on"]
    Ils -> ["ils", "elles"]
    _ -> [pronoun(person)]
  }
}

/// The accepted forms of a verb for one subject, canonical first, without
/// the subject.
fn forms(
  word: Word,
  tense: Tense,
  person: Person,
  _subject: String,
) -> List(String) {
  case word, tense {
    Verb(present:, ..), Presens -> [conjugate(present, person)]
    Verb(infinitive:, ..), FuturProche -> [
      conjugate(aller, person) <> " " <> infinitive,
    ]
    _, _ -> []
  }
}

const aller = Present("vais", "vas", "va", "allons", "allez", "vont")

/// Every accepted answer for a verb in a tense and person: the forms on
/// their own ("parlons") and with each subject ("nous parlons"), canonical
/// first. Empty for anything but a verb.
pub fn conjugation_answers(
  word: Word,
  tense: Tense,
  person: Person,
) -> List(String) {
  let by_subject =
    list.map(subjects(person), fn(subject) {
      #(subject, forms(word, tense, person, subject))
    })
  let bare = list.flat_map(by_subject, fn(pair) { pair.1 })
  let with_subjects =
    list.flat_map(by_subject, fn(pair) {
      list.map(pair.1, with_subject(pair.0, _))
    })
  list.unique(list.append(bare, with_subjects))
}

/// The canonical conjugated form with its pronoun: "nous allons parler".
pub fn conjugated(word: Word, tense: Tense, person: Person) -> String {
  case forms(word, tense, person, pronoun(person)) {
    [form, ..] -> with_pronoun(form, person)
    [] -> ""
  }
}

pub fn pronoun(person: Person) -> String {
  case person {
    Je -> "je"
    Tu -> "tu"
    Il -> "il"
    Nous -> "nous"
    Vous -> "vous"
    Ils -> "ils"
  }
}

fn starts_with_vowel_sound(word: String) -> Bool {
  case string.first(string.lowercase(word)) {
    Ok(c) -> string.contains("aàâeéèêëiîïoôuùûüyœh", c)
    Error(Nil) -> False
  }
}
