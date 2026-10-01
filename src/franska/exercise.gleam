//// Exercises are derived from lexicon entries, so adding an entry to the
//// content automatically adds every exercise that fits it.

import franska/answer.{type Grade, type Language}
import franska/lexicon.{
  type Entry, type Level, type Person, Expression, Noun, Verb,
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
  /// Give the présent form of a verb for a person.
  Conjugate(Person)
}

/// The kinds of practice a learner can choose between.
pub type Drill {
  TranslateToFrench
  TranslateToSwedish
  Articles
  Conjugation
}

pub const drills = [TranslateToFrench, TranslateToSwedish, Articles, Conjugation]

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
    Conjugate(_) -> Conjugation
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
    Verb(infinitive:, present:) ->
      list.map(lexicon.persons, fn(person) {
        let form = lexicon.conjugate(present, person)
        exercise(
          "present:" <> lexicon.pronoun(person),
          Conjugate(person),
          infinitive,
          conjugation_answers(form, person),
          answer.French,
          lexicon.with_pronoun(form, person),
        )
      })
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

fn conjugation_answers(form: String, person: Person) -> List(String) {
  let alternatives = case person {
    lexicon.Il -> ["elle " <> form, "on " <> form]
    lexicon.Ils -> ["elles " <> form]
    _ -> []
  }
  [form, lexicon.with_pronoun(form, person), ..alternatives]
}
