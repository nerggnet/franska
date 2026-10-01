//// Exercises are derived from lexicon entries, so adding an entry to the
//// content automatically adds every exercise that fits it.

import franska/answer.{type Grade, type Language}
import franska/lexicon.{
  type AdjectiveForm, type Entry, type Level, type Person, type Tense, Adjective,
  Expression, Noun, Rewrite, Sentence, Verb,
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
  /// Give an adjective in another form; the prompt is the masculine.
  Agree(AdjectiveForm)
  /// Rewrite a sentence; the prompt is the sentence and `translation` the
  /// Swedish meaning of the answer.
  Transform(task: lexicon.Task, translation: String)
  /// Fill the gap in a sentence. The prompt is the sentence with its gap;
  /// `translation` is the Swedish meaning and `hint` may be "".
  FillGap(hint: String, translation: String)
}

/// The kinds of practice a learner can choose between.
pub type Drill {
  TranslateToFrench
  TranslateToSwedish
  Articles
  Dictation
  Numbers
  Sentences
  Adjectives
  Negation
  Conjugation(Tense)
}

pub fn drills() -> List(Drill) {
  [
    TranslateToFrench,
    TranslateToSwedish,
    Articles,
    Dictation,
    Numbers,
    Adjectives,
    Sentences,
    Negation,
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
    FillGap(..) -> Sentences
    Agree(_) -> Adjectives
    Transform(task: lexicon.Negate, ..) -> Negation
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
  case entry.word {
    Sentence(text:, answers:, hint:) -> [
      exercise(
        "gap",
        FillGap(hint:, translation: swedish),
        text,
        answers,
        answer.French,
        french,
      ),
    ]
    Rewrite(task:, source:, answers:) -> [
      exercise(
        "rewrite",
        Transform(task:, translation: swedish),
        source,
        answers,
        answer.French,
        french,
      ),
    ]
    _ -> word_exercises(entry, exercise, french, swedish)
  }
}

fn word_exercises(
  entry: Entry,
  exercise: fn(String, Kind, String, List(String), Language, String) -> Exercise,
  french: String,
  swedish: String,
) -> List(Exercise) {
  let to_french_accepted = case entry.word {
    Expression(fr:) -> fr
    // Without context either gender is a right translation.
    Adjective(masculine:, feminine:, ..) -> list.unique([masculine, feminine])
    _ -> [french]
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
    Verb(..) as verb -> {
      use tense <- list.flat_map(lexicon.tenses)
      use person <- list.map(lexicon.persons)
      exercise(
        lexicon.tense_id(tense) <> ":" <> lexicon.pronoun(person),
        Conjugate(tense, person),
        french,
        lexicon.conjugation_answers(verb, tense, person),
        answer.French,
        lexicon.conjugated(verb, tense, person),
      )
    }
    Adjective(masculine:, ..) as adjective -> {
      // A form that is the same as the masculine or an earlier form is
      // nothing new to practise (rouge, rouges, rouges).
      let #(_, exercises) =
        list.fold(lexicon.adjective_forms, #([masculine], []), fn(acc, form) {
          let #(seen, exercises) = acc
          case lexicon.adjective_form(adjective, form) {
            Ok(agreed) ->
              case list.contains(seen, agreed) {
                True -> acc
                False -> #([agreed, ..seen], [
                  exercise(
                    "agree:" <> lexicon.adjective_form_id(form),
                    Agree(form),
                    masculine,
                    [agreed],
                    answer.French,
                    agreed,
                  ),
                  ..exercises
                ])
              }
            Error(Nil) -> acc
          }
        })
      list.reverse(exercises)
    }
    Expression(..) | Rewrite(..) | Sentence(..) -> []
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
