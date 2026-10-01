//// Exercises are derived from lexicon entries, so adding an entry to the
//// content automatically adds every exercise that fits it.

import franska/answer.{type Grade, type Language}
import franska/lexicon.{type Entry, type Person, Expression, Noun, Verb}
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

/// `id` is stable and unique, so it can key the learner's progress.
/// `prompt` is the bare stimulus; the UI adds instructions per `kind`.
pub type Exercise {
  Exercise(
    id: String,
    entry_id: String,
    kind: Kind,
    prompt: String,
    accepted: List(String),
    answer_language: Language,
  )
}

pub fn from_entry(entry: Entry) -> List(Exercise) {
  let french = lexicon.french(entry.word)
  let swedish = case entry.sv {
    [first, ..] -> first
    [] -> ""
  }
  let exercise = fn(suffix, kind, prompt, accepted, answer_language) {
    Exercise(
      id: entry.id <> ":" <> suffix,
      entry_id: entry.id,
      kind:,
      prompt:,
      accepted:,
      answer_language:,
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
    ),
    exercise("to-sv", Translate(ToSwedish), french, entry.sv, answer.Swedish),
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
