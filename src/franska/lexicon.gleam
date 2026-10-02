//// The vocabulary a learner studies. Content is curated as a list of
//// `Entry` values; exercises are derived from them (see `franska/exercise`).

import gleam/bool
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
  /// A short text to read or listen to, with comprehension questions in
  /// Swedish. Lines in `french` and `swedish` are separated by "\n".
  Text(
    title: String,
    french: String,
    swedish: String,
    questions: List(Question),
  )
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
  /// être en train de + infinitive: "je suis en train de manger".
  PresentProgressif
  /// aller + infinitive: "je vais parler".
  FuturProche
  /// venir de + infinitive: "je viens de manger".
  PasseRecent
  /// A stem, mostly the infinitive, plus -ai, -as, -a, -ons, -ez, -ont:
  /// "je parlerai", "j'irai".
  FuturSimple
  /// auxiliary + past participle: "j'ai parlé", "elle est allée".
  PasseCompose
  /// Generated from the nous stem: "nous parlons" gives "je parlais".
  Imparfait
  /// The futur simple stem with the imparfait endings: "je parlerais",
  /// "j'irais", "je voudrais".
  Conditionnel
  /// Only tu, nous and vous: "parle", "parlons", "parlez", "lève-toi".
  Imperatif
}

pub const tenses = [
  Presens,
  PresentProgressif,
  FuturProche,
  PasseRecent,
  FuturSimple,
  PasseCompose,
  Imparfait,
  Conditionnel,
  Imperatif,
]

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
    PresentProgressif -> "present-progressif"
    FuturProche -> "futur-proche"
    PasseRecent -> "passe-recent"
    FuturSimple -> "futur-simple"
    PasseCompose -> "passe-compose"
    Imparfait -> "imparfait"
    Conditionnel -> "conditionnel"
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

/// A multiple-choice question about a `Text`; `answer` is the index of the
/// right option.
pub type Question {
  Question(question: String, options: List(String), answer: Int)
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
  /// The superlative in the masculine singular: "le plus grand".
  MostSingular
}

pub const degrees = [More, Less, Equal, Most, MostSingular]

/// Stable id of a degree, part of exercise ids.
pub fn degree_id(degree: Degree) -> String {
  case degree {
    More -> "more"
    Less -> "less"
    Equal -> "equal"
    Most -> "most"
    MostSingular -> "most-singular"
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
    MostSingular -> "Il est " <> gap <> " de tous."
  }
}

/// Adjectives that are not compared: plus première or plus suédoise make
/// no sense.
const not_gradable = [
  "premier", "dernier", "prochain", "même", "autre", "gratuit", "suédois",
  "français", "anglais", "allemand", "espagnol", "italien", "américain",
  "norvégien", "danois", "finlandais", "obligatoire", "facultatif", "actuel",
  "absent", "présent", "mort", "vivant", "enceinte", "végétarien", "cru", "cuit",
  "meublé",
]

/// Accepted answers for the gap in `comparison_frame(degree)`, canonical
/// first: "plus grande", "moins grands", "aussi grand", "les plus grandes".
/// Bon is irregular (meilleure, les meilleures), and mauvais can also be
/// pire. Invariable adjectives such as marron, and adjectives that cannot
/// be compared (premier, suédois), get none.
pub fn compared(word: Word, degree: Degree) -> List(String) {
  case word {
    Adjective(masculine:, feminine:, masculine_plural:, feminine_plural:)
      if masculine != feminine_plural
    -> {
      use <- bool.guard(list.contains(not_gradable, masculine), [])
      let #(form, irregular) = case degree, masculine {
        More, "bon" -> #(feminine, ["meilleure"])
        Most, "bon" -> #(feminine_plural, ["les meilleures"])
        MostSingular, "bon" -> #(masculine, ["le meilleur"])
        More, "mauvais" -> #(feminine, ["plus mauvaise", "pire"])
        Most, "mauvais" -> #(feminine_plural, [
          "les plus mauvaises",
          "les pires",
        ])
        More, _ -> #(feminine, [])
        Less, _ -> #(masculine_plural, [])
        Equal, _ -> #(masculine, [])
        MostSingular, "mauvais" -> #(masculine, [
          "le plus mauvais",
          "le pire",
        ])
        Most, _ -> #(feminine_plural, [])
        MostSingular, _ -> #(masculine, [])
      }
      case irregular {
        [_, ..] -> irregular
        [] ->
          case degree {
            More -> ["plus " <> form]
            Less -> ["moins " <> form]
            Equal -> ["aussi " <> form]
            Most -> ["les plus " <> form]
            MostSingular -> ["le plus " <> form]
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
    Verb(..)
    | Adjective(..)
    | Expression(..)
    | Rewrite(..)
    | Sentence(..)
    | Text(..) -> Error(Nil)
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
    Text(french:, ..) -> french
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
    Verb(infinitive:, ..), PresentProgressif ->
      case list.contains(not_progressive, infinitive) {
        True -> []
        False -> [
          conjugate(etre, person)
          <> " en train "
          <> elide("de", reflexive(word, person, infinitive)),
        ]
      }
    Verb(infinitive:, ..), PasseRecent ->
      case list.contains(not_recent, infinitive) {
        True -> []
        False -> [
          conjugate(venir, person)
          <> " "
          <> elide("de", reflexive(word, person, infinitive)),
        ]
      }
    Verb(participle:, auxiliary: Avoir, reflexive: False, ..), PasseCompose -> [
      conjugate(avoir, person) <> " " <> participle,
    ]
    Verb(participle:, ..), PasseCompose ->
      agreements(subject)
      |> list.map(fn(ending) { agree(participle, ending) })
      |> list.unique
      |> list.map(fn(participle) {
        reflexive(word, person, conjugate(etre, person) <> " " <> participle)
      })
    Verb(infinitive:, present:, ..), Imparfait -> [
      reflexive(word, person, imparfait(infinitive, present, person)),
    ]
    Verb(infinitive:, present:, ..), FuturSimple ->
      list.map(future_stems(infinitive, present), fn(stem) {
        reflexive(word, person, stem <> future_ending(person))
      })
    Verb(infinitive:, present:, ..), Conditionnel ->
      list.map(future_stems(infinitive, present), fn(stem) {
        reflexive(word, person, stem <> imparfait_ending(person))
      })
    Verb(..), Imperatif -> imperative(word, person)
    _, _ -> []
  }
}

/// The stems of the futur simple, canonical first. Common verbs like être
/// (ser-) and aller (ir-) have an irregular stem. Otherwise -er verbs build on the je form, so the
/// spelling changes carry over (j'achète, j'achèterai; j'appelle,
/// j'appellerai), except that é→è verbs keep their é (préférerai) with
/// the reformed è (préfèrerai) also accepted. Other verbs use the
/// infinitive, -re verbs without the final e (prendr-).
fn future_stems(infinitive: String, present: Present) -> List(String) {
  case irregular_future_stem(infinitive) {
    Ok(stem) -> [stem]
    Error(Nil) ->
      case string.ends_with(infinitive, "er") {
        True -> {
          let from_je = present.je <> "r"
          let reformed_e =
            string.contains(present.je, "è") && string.contains(infinitive, "é")
          case from_je != infinitive, reformed_e {
            True, True -> [infinitive, from_je]
            // -ayer verbs have both spellings: essaierai and essayerai.
            True, False ->
              case string.ends_with(infinitive, "ayer") {
                True -> [from_je, infinitive]
                False -> [from_je]
              }
            False, _ -> [from_je]
          }
        }
        False ->
          case string.ends_with(infinitive, "re") {
            True -> [string.drop_end(infinitive, 1)]
            False -> [infinitive]
          }
      }
  }
}

fn irregular_future_stem(infinitive: String) -> Result(String, Nil) {
  case infinitive {
    "être" -> Ok("ser")
    "avoir" -> Ok("aur")
    "aller" -> Ok("ir")
    "faire" -> Ok("fer")
    "venir" -> Ok("viendr")
    "voir" -> Ok("verr")
    "pouvoir" -> Ok("pourr")
    "vouloir" -> Ok("voudr")
    "savoir" -> Ok("saur")
    "devoir" -> Ok("devr")
    "courir" -> Ok("courr")
    "envoyer" -> Ok("enverr")
    "devenir" -> Ok("deviendr")
    "revenir" -> Ok("reviendr")
    "recevoir" -> Ok("recevr")
    "souvenir" -> Ok("souviendr")
    "mourir" -> Ok("mourr")
    "tenir" -> Ok("tiendr")
    "obtenir" -> Ok("obtiendr")
    "prévenir" -> Ok("préviendr")
    "asseoir" -> Ok("assiér")
    "accueillir" -> Ok("accueiller")
    _ -> Error(Nil)
  }
}

/// The endings of the imparfait, also used by the conditionnel.
fn imparfait_ending(person: Person) -> String {
  case person {
    Je | Tu -> "ais"
    Il -> "ait"
    Nous -> "ions"
    Vous -> "iez"
    Ils -> "aient"
  }
}

fn future_ending(person: Person) -> String {
  case person {
    Je -> "ai"
    Tu -> "as"
    Il -> "a"
    Nous -> "ons"
    Vous -> "ez"
    Ils -> "ont"
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

/// Joins a short word to the next one, eliding me, te, se, je and de
/// before a vowel sound: "s'habiller", "je m'appelle", "d'arriver".
fn elide(word: String, next: String) -> String {
  case word, starts_with_vowel_sound(next) {
    "me", True | "te", True | "se", True | "je", True | "de", True ->
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
  let ending = imparfait_ending(person)
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

/// A participle ending in s takes no plural s: "ils sont assis".
fn agree(participle: String, ending: String) -> String {
  case string.ends_with(participle, "s"), ending {
    True, "s" -> participle
    _, _ -> participle <> ending
  }
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

const venir = Present("viens", "viens", "vient", "venons", "venez", "viennent")

/// Verbs for states rather than actions, which sound wrong as "en train
/// de" or "venir de": je suis en train de vouloir.
const stative = [
  "vouloir", "pouvoir", "devoir", "savoir", "connaître", "aimer", "préférer",
  "croire", "sembler", "espérer", "souhaiter",
]

const not_progressive = ["être", "avoir", ..stative]

const not_recent = ["venir", ..stative]

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
    // Not y: le yaourt.
    Ok(c) -> string.contains("aàâeéèêëiîïoôuùûüœh", c)
    Error(Nil) -> False
  }
}
