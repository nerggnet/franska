//// Exercises are derived from lexicon entries, so adding an entry to the
//// content automatically adds every exercise that fits it.

import franska/answer.{type Grade, type Language}
import franska/lexicon.{
  type Entry, type Level, type Person, type Tense, Expression, Noun, Verb,
}
import gleam/list

pub type Direction {
  ToFrench
  ToSwedish
}

pub type Kind {
  Translate(Direction)
  /// Pick le or la for a noun shown without its article.
  ChooseArticle
  /// Give the form of a verb in a tense for a person.
  Conjugate(Tense, Person)
  /// Write down French that is read aloud. The prompt is the Swedish
  /// meaning, shown as a hint since some words sound the same.
  Listen
  /// Write a number in words (see `franska/numbers`).
  WriteNumber(Int)
}

/// The kinds of practice a learner can choose between.
pub type Drill {
  TranslateToFrench
  TranslateToSwedish
  Articles
  Dictation
  Numbers
  Conjugation(Tense)
}

pub fn drills() -> List(Drill) {
  [
    TranslateToFrench,
    TranslateToSwedish,
    Articles,
    Dictation,
    Numbers,
    ..list.map(lexicon.tenses, Conjugation)
  ]
}

/// `id` is stable and unique, so it can key the learner's progress.
/// `prompt` is the bare stimulus; the UI adds instructions per `kind`.
/// `french` is the complete French text the exercise is about ("l'école",
/// "nous parlons"), for revealing after an answer and for reading aloud.
pub type Exercise {
  Exercise(
    id: String,
    entry_id: String,
    kind: Kind,
    prompt: String,
    accepted: List(String),
    answer_language: Language,
    french: String,
    level: Level,
  )
}

pub fn drill(kind: Kind) -> Drill {
  case kind {
    Translate(ToFrench) -> TranslateToFrench
    Translate(ToSwedish) -> TranslateToSwedish
    ChooseArticle -> Articles
    Conjugate(tense, _) -> Conjugation(tense)
    Listen -> Dictation
    WriteNumber(_) -> Numbers
  }
}

pub fn from_entry(entry: Entry) -> List(Exercise) {
  let french = lexicon.french(entry.word)
  let swedish = case entry.sv {
    [first, ..] -> first
    [] -> ""
  }
  let exercise = fn(suffix, kind, prompt, accepted, answer_language, french) {
    Exercise(
      id: entry.id <> ":" <> suffix,
      entry_id: entry.id,
      kind:,
      prompt:,
      accepted:,
      answer_language:,
      french:,
      level: entry.level,
    )
  }
  let to_french_accepted = case entry.word {
    Expression(fr:) -> fr
    Noun(..) | Verb(..) -> [french]
  }

  let translations = [
    exercise(
      "to-fr",
      Translate(ToFrench),
      swedish,
      to_french_accepted,
      answer.French,
      french,
    ),
    exercise(
      "to-sv",
      Translate(ToSwedish),
      french,
      entry.sv,
      answer.Swedish,
      french,
    ),
    exercise(
      "listen",
      Listen,
      swedish,
      to_french_accepted,
      answer.French,
      french,
    ),
  ]

  let extras = case entry.word {
    Noun(fr:, gender:, ..) -> [
      exercise(
        "article",
        ChooseArticle,
        fr,
        case gender {
          lexicon.Masculine -> ["le", "un"]
          lexicon.Feminine -> ["la", "une"]
        },
        answer.French,
        french,
      ),
    ]
    Verb(infinitive:, ..) as verb -> {
      use tense <- list.flat_map(lexicon.tenses)
      use person <- list.map(lexicon.persons)
      exercise(
        lexicon.tense_id(tense) <> ":" <> lexicon.pronoun(person),
        Conjugate(tense, person),
        infinitive,
        lexicon.conjugation_answers(verb, tense, person),
        answer.French,
        lexicon.conjugated(verb, tense, person),
      )
    }
    Expression(..) -> []
  }

  list.append(translations, extras)
}

pub fn check(exercise: Exercise, given: String) -> Grade {
  answer.grade(
    given,
    accepted: exercise.accepted,
    language: exercise.answer_language,
  )
}
