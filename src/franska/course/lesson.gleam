//// What a lesson of the course is made of, and the parts it practises.

import franska/exercise.{
  type Drill, Adjectives, Articles, Comparisons, Conjugation, Dictation,
  ListeningTexts, Negation, Numbers, Pronouns, ReadingTexts, Sentences,
  TranslateToFrench, TranslateToSwedish,
}
import franska/lexicon.{type Level}
import franska/numbers
import gleam/int
import gleam/list

/// `topic` is a short line on what the lesson is about, and `note` its
/// grammar note: paragraphs, with lines in a paragraph separated by "\n".
pub type Lesson {
  Lesson(
    id: String,
    level: Level,
    title: String,
    topic: String,
    note: List(String),
    parts: List(Part),
  )
}

/// Some drills of some entries. Numbers are entries "number:<n>".
pub type Part {
  Part(entries: List(String), drills: List(Drill))
}

/// Words: translation both ways, dictation, le/la and adjective agreement.
pub fn words(entries: List(String)) -> Part {
  Part(entries, [
    TranslateToFrench,
    TranslateToSwedish,
    Dictation,
    Articles,
    Adjectives,
  ])
}

/// Verbs as words, with the présent.
pub fn verbs(entries: List(String)) -> Part {
  let Part(drills:, ..) = words(entries)
  Part(entries, [Conjugation(lexicon.Presens), ..drills])
}

pub fn conjugation(tense: lexicon.Tense, entries: List(String)) -> Part {
  Part(entries, [Conjugation(tense)])
}

/// Gap-fill sentences and sentences to rewrite.
pub fn sentences(entries: List(String)) -> Part {
  Part(entries, [Sentences, Negation, Pronouns])
}

pub fn texts(entries: List(String)) -> Part {
  Part(entries, [ReadingTexts, ListeningTexts])
}

/// The practised numbers from `from` to `to`.
pub fn numbers(from: Int, to: Int) -> Part {
  numbers.practised()
  |> list.filter(fn(n) { n >= from && n <= to })
  |> list.map(fn(n) { "number:" <> int.to_string(n) })
  |> Part([Numbers])
}

/// Comparisons and superlatives of adjectives.
pub fn comparisons(entries: List(String)) -> Part {
  Part(entries, [Comparisons])
}
