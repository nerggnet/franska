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
  /// `participle` and `auxiliary` form the passé composé ("parlé" with
  /// avoir, "allé" with être). A `reflexive` verb ("se lever") is given
  /// without its pronoun; it always takes être in the passé composé.
  Verb(
    infinitive: String,
    present: Present,
    participle: String,
    auxiliary: Auxiliary,
    reflexive: Bool,
  )
  /// The four forms of an adjective. Build with `adjective` or
  /// `invariable_adjective`.
  Adjective(
    masculine: String,
    feminine: String,
    masculine_plural: String,
    feminine_plural: String,
  )
  /// Any fixed phrase. The first French variant is the canonical one.
  Expression(fr: List(String))
  /// A sentence to rewrite as `task` says; `answers` are the rewritten
  /// sentence, canonical first.
  Rewrite(task: Task, source: String, answers: List(String))
  /// A sentence with one gap, written `___` in `text`. `answers` fill the
  /// gap, canonical first; `hint` (such as the verb's infinitive) may be "".
  Sentence(text: String, answers: List(String), hint: String)
}

/// A unit of curated content. `id` must be unique across all content and
/// stable over time, since learner progress is stored against it.
/// `sv` lists accepted Swedish translations, canonical one first.
pub type Entry {
  Entry(id: String, level: Level, theme: String, sv: List(String), word: Word)
}

pub const persons = [Je, Tu, Il, Nous, Vous, Ils]

/// How the gap is written in a `Sentence`.
pub const gap = "___"

pub type Auxiliary {
  Avoir
  /// The participle agrees with the subject: "elle est allée".
  Etre
}

pub type Tense {
  Presens
  /// aller + infinitive: "je vais parler".
  FuturProche
  /// auxiliary + past participle: "j'ai parlé", "elle est allée".
  PasseCompose
  /// Generated from the nous stem: "nous parlons" gives "je parlais".
  Imparfait
  /// Only tu, nous and vous: "parle", "parlons", "parlez", "lève-toi".
  Imperatif
}

pub const tenses = [Presens, FuturProche, PasseCompose, Imparfait, Imperatif]

/// The persons a tense has: the imperative only has tu, nous and vous.
pub fn persons_for(tense: Tense) -> List(Person) {
  case tense {
    Imperatif -> [Tu, Nous, Vous]
    _ -> persons
  }
}

/// Stable id of a tense, part of exercise ids.
pub fn tense_id(tense: Tense) -> String {
  case tense {
    Presens -> "present"
    FuturProche -> "futur-proche"
    PasseCompose -> "passe-compose"
    Imparfait -> "imparfait"
    Imperatif -> "imperatif"
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

pub type Task {
  /// Make the sentence negative.
  Negate
  /// Replace the part of the sentence marked with [brackets] by a pronoun.
  UsePronoun
}

/// Splits a `UsePronoun` source into the text before, inside and after the
/// [marked] part.
pub fn marked_part(source: String) -> Result(#(String, String, String), Nil) {
  case string.split_once(source, "[") {
    Ok(#(before, rest)) ->
      case string.split_once(rest, "]") {
        Ok(#(marked, after)) ->
          case string.contains(after, "[") || string.contains(marked, "[") {
            True -> Error(Nil)
            False -> Ok(#(before, marked, after))
          }
        Error(Nil) -> Error(Nil)
      }
    Error(Nil) -> Error(Nil)
  }
}

pub type AdjectiveForm {
  FeminineSingular
  MasculinePlural
  FemininePlural
}

pub const adjective_forms = [FeminineSingular, MasculinePlural, FemininePlural]

/// An adjective from its masculine and feminine singular, with the plurals
/// by the usual rules: +s, no change after s or x, -eau gives -eaux and
/// -al gives -aux.
pub fn adjective(masculine: String, feminine: String) -> Word {
  let masculine_plural = case
    string.ends_with(masculine, "s") || string.ends_with(masculine, "x"),
    string.ends_with(masculine, "eau"),
    string.ends_with(masculine, "al")
  {
    True, _, _ -> masculine
    _, True, _ -> masculine <> "x"
    _, _, True -> string.drop_end(masculine, 1) <> "ux"
    _, _, _ -> masculine <> "s"
  }
  let feminine_plural = case string.ends_with(feminine, "s") {
    True -> feminine
    False -> feminine <> "s"
  }
  Adjective(masculine:, feminine:, masculine_plural:, feminine_plural:)
}

/// An adjective with one form for everything, like marron and orange.
pub fn invariable_adjective(form: String) -> Word {
  Adjective(form, form, form, form)
}

pub fn adjective_form(word: Word, form: AdjectiveForm) -> Result(String, Nil) {
  case word, form {
    Adjective(feminine:, ..), FeminineSingular -> Ok(feminine)
    Adjective(masculine_plural:, ..), MasculinePlural -> Ok(masculine_plural)
    Adjective(feminine_plural:, ..), FemininePlural -> Ok(feminine_plural)
    _, _ -> Error(Nil)
  }
}

pub type Degree {
  More
  Less
  Equal
  /// The superlative: "les plus grandes".
  Most
}

pub const degrees = [More, Less, Equal, Most]

/// Stable id of a degree, part of exercise ids.
pub fn degree_id(degree: Degree) -> String {
  case degree {
    More -> "more"
    Less -> "less"
    Equal -> "equal"
    Most -> "most"
  }
}

/// The French sentence each degree is practised in. The subject decides the
/// form: feminine, masculine plural, masculine and feminine plural.
pub fn comparison_frame(degree: Degree) -> String {
  case degree {
    More -> "Elle est " <> gap <> " que lui."
    Less -> "Ils sont " <> gap <> " que nous."
    Equal -> "Il est " <> gap <> " que toi."
    Most -> "Elles sont " <> gap <> " de toutes."
  }
}

/// Accepted answers for the gap in `comparison_frame(degree)`, canonical
/// first: "plus grande", "moins grands", "aussi grand", "les plus grandes".
/// Bon is irregular (meilleure, les meilleures), and mauvais can also be
/// pire. Invariable adjectives such as marron get none.
pub fn compared(word: Word, degree: Degree) -> List(String) {
  case word {
    Adjective(masculine:, feminine:, masculine_plural:, feminine_plural:)
      if masculine != feminine_plural
    -> {
      let #(form, irregular) = case degree, masculine {
        More, "bon" -> #(feminine, ["meilleure"])
        Most, "bon" -> #(feminine_plural, ["les meilleures"])
        More, "mauvais" -> #(feminine, ["plus mauvaise", "pire"])
        Most, "mauvais" -> #(feminine_plural, [
          "les plus mauvaises",
          "les pires",
        ])
        More, _ -> #(feminine, [])
        Less, _ -> #(masculine_plural, [])
        Equal, _ -> #(masculine, [])
        Most, _ -> #(feminine_plural, [])
      }
      case irregular {
        [_, ..] -> irregular
        [] ->
          case degree {
            More -> ["plus " <> form]
            Less -> ["moins " <> form]
            Equal -> ["aussi " <> form]
            Most -> ["les plus " <> form]
          }
      }
    }
    _ -> []
  }
}

/// Stable id of an adjective form, part of exercise ids.
pub fn adjective_form_id(form: AdjectiveForm) -> String {
  case form {
    FeminineSingular -> "fs"
    MasculinePlural -> "mp"
    FemininePlural -> "fp"
  }
}

pub fn definite_article(word: Word) -> Result(String, Nil) {
  case word {
    Noun(elides: True, ..) -> Ok("l'")
    Noun(gender: Masculine, ..) -> Ok("le")
    Noun(gender: Feminine, ..) -> Ok("la")
    Verb(..) | Adjective(..) | Expression(..) | Rewrite(..) | Sentence(..) ->
      Error(Nil)
  }
}

/// The canonical French form a learner should produce: nouns with their
/// definite article, verbs as infinitives.
pub fn french(word: Word) -> String {
  case word {
    Noun(fr:, elides: True, ..) -> "l'" <> fr
    Noun(fr:, gender: Masculine, ..) -> "le " <> fr
    Noun(fr:, gender: Feminine, ..) -> "la " <> fr
    Verb(infinitive:, reflexive: False, ..) -> infinitive
    Verb(infinitive:, reflexive: True, ..) -> elide("se", infinitive)
    Adjective(masculine:, ..) -> masculine
    Expression(fr: [first, ..]) -> first
    Expression(fr: []) -> ""
    Sentence(text:, answers: [first, ..], ..) ->
      string.replace(text, gap, first)
    Sentence(text:, answers: [], ..) -> text
    Rewrite(answers: [first, ..], ..) -> first
    Rewrite(source:, answers: [], ..) -> source
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
  elide(subject, form)
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
  subject: String,
) -> List(String) {
  case word, tense {
    Verb(present:, ..), Presens -> [
      reflexive(word, person, conjugate(present, person)),
    ]
    // The pronoun goes with the infinitive: "je vais me lever".
    Verb(infinitive:, ..), FuturProche -> [
      conjugate(aller, person) <> " " <> reflexive(word, person, infinitive),
    ]
    Verb(participle:, auxiliary: Avoir, reflexive: False, ..), PasseCompose -> [
      conjugate(avoir, person) <> " " <> participle,
    ]
    Verb(participle:, ..), PasseCompose ->
      list.map(agreements(subject), fn(ending) {
        reflexive(
          word,
          person,
          conjugate(etre, person) <> " " <> participle <> ending,
        )
      })
    Verb(infinitive:, present:, ..), Imparfait -> [
      reflexive(word, person, imparfait(infinitive, present, person)),
    ]
    Verb(..), Imperatif -> imperative(word, person)
    _, _ -> []
  }
}

/// The affirmative imperative: the présent without the subject, where -er
/// verbs (and aller, ouvrir) drop the s of the tu form. Être, avoir and
/// savoir are irregular; pouvoir, vouloir and devoir are left out, as their
/// imperatives are hardly used. Reflexive verbs take a stressed pronoun
/// after a hyphen: "lève-toi".
fn imperative(word: Word, person: Person) -> List(String) {
  case word, person {
    Verb(infinitive: "pouvoir", ..), _
    | Verb(infinitive: "vouloir", ..), _
    | Verb(infinitive: "devoir", ..), _
    | _, Je
    | _, Il
    | _, Ils
    -> []
    Verb(infinitive:, present:, reflexive:, ..), _ -> {
      let form = case irregular_imperative(infinitive, person) {
        Ok(form) -> form
        Error(Nil) ->
          case person {
            Tu ->
              case string.ends_with(present.tu, "es") || present.tu == "vas" {
                True -> string.drop_end(present.tu, 1)
                False -> present.tu
              }
            Nous -> present.nous
            _ -> present.vous
          }
      }
      case reflexive, person {
        True, Tu -> [form <> "-toi"]
        True, Nous -> [form <> "-nous"]
        True, _ -> [form <> "-vous"]
        False, _ -> [form]
      }
    }
    _, _ -> []
  }
}

fn irregular_imperative(
  infinitive: String,
  person: Person,
) -> Result(String, Nil) {
  case infinitive, person {
    "être", Tu -> Ok("sois")
    "être", Nous -> Ok("soyons")
    "être", Vous -> Ok("soyez")
    "avoir", Tu -> Ok("aie")
    "avoir", Nous -> Ok("ayons")
    "avoir", Vous -> Ok("ayez")
    "savoir", Tu -> Ok("sache")
    "savoir", Nous -> Ok("sachons")
    "savoir", Vous -> Ok("sachez")
    _, _ -> Error(Nil)
  }
}

/// Puts the reflexive pronoun before `form` if the verb is reflexive.
fn reflexive(word: Word, person: Person, form: String) -> String {
  case word {
    Verb(reflexive: True, ..) -> elide(reflexive_pronoun(person), form)
    _ -> form
  }
}

fn reflexive_pronoun(person: Person) -> String {
  case person {
    Je -> "me"
    Tu -> "te"
    Il | Ils -> "se"
    Nous -> "nous"
    Vous -> "vous"
  }
}

/// Joins a short word to the next one, eliding me, te, se and je before a
/// vowel sound: "s'habiller", "je m'appelle".
fn elide(word: String, next: String) -> String {
  case word, starts_with_vowel_sound(next) {
    "me", True | "te", True | "se", True | "je", True ->
      string.drop_end(word, 1) <> "'" <> next
    _, _ -> word <> " " <> next
  }
}

/// The imparfait: the nous stem of the présent plus the endings. Être is
/// the only exception (ét-). Before an i, -ge- loses its e and -ç- becomes
/// c again: mangeais but mangions, commençais but commencions.
fn imparfait(infinitive: String, present: Present, person: Person) -> String {
  let stem = case infinitive {
    "être" -> "ét"
    _ -> string.drop_end(present.nous, 3)
  }
  let ending = case person {
    Je | Tu -> "ais"
    Il -> "ait"
    Nous -> "ions"
    Vous -> "iez"
    Ils -> "aient"
  }
  let stem = case string.starts_with(ending, "i") {
    False -> stem
    True ->
      case string.ends_with(stem, "ge"), string.ends_with(stem, "ç") {
        True, _ -> string.drop_end(stem, 1)
        _, True -> string.drop_end(stem, 1) <> "c"
        False, False -> stem
      }
  }
  stem <> ending
}

/// Participle endings for a subject with être, the most common first. Je,
/// tu and vous can be either gender, and on can mean "vi".
fn agreements(subject: String) -> List(String) {
  case subject {
    "il" -> [""]
    "elle" -> ["e"]
    "on" -> ["", "s", "es"]
    "nous" | "ils" -> ["s", "es"]
    "elles" -> ["es"]
    "vous" -> ["s", "es", "", "e"]
    _ -> ["", "e"]
  }
}

const aller = Present("vais", "vas", "va", "allons", "allez", "vont")

const avoir = Present("ai", "as", "a", "avons", "avez", "ont")

const etre = Present("suis", "es", "est", "sommes", "êtes", "sont")

/// Every accepted answer for a verb in a tense and person: the forms on
/// their own ("parlons") and with each subject ("nous parlons"), canonical
/// first. Empty for anything but a verb.
pub fn conjugation_answers(
  word: Word,
  tense: Tense,
  person: Person,
) -> List(String) {
  case tense {
    // The imperative has no subject.
    Imperatif -> forms(word, tense, person, pronoun(person))
    _ -> {
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
  }
}

/// The canonical conjugated form with its pronoun: "nous allons parler".
pub fn conjugated(word: Word, tense: Tense, person: Person) -> String {
  case forms(word, tense, person, pronoun(person)), tense {
    [form, ..], Imperatif -> form
    [form, ..], _ -> with_pronoun(form, person)
    [], _ -> ""
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
