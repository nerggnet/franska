//// All curated content. Add a new level or content module here.

import franska/answer
import franska/content/a1
import franska/content/a2
import franska/exercise.{type Drill, type Exercise}
import franska/lexicon.{type Entry}
import franska/numbers
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}

/// A1 entries come first, so new A1 words are practised before A2 ones.
pub fn entries() -> List(Entry) {
  list.append(a1.entries(), a2.entries())
}

/// Every theme in the content, in the order it first appears.
pub fn themes() -> List(String) {
  entries()
  |> list.map(fn(entry) { entry.theme })
  |> list.unique
}

/// The entry with the given id.
pub fn entry(id: String) -> Result(Entry, Nil) {
  list.find(entries(), fn(entry) { entry.id == id })
}

/// Every exercise of every drill.
pub fn all_exercises() -> List(Exercise) {
  list.flat_map(entries(), exercise.from_entry)
  |> list.append(numbers.exercises())
}

/// Every exercise of a drill, optionally limited to one theme. Numbers are
/// generated and have no theme.
pub fn exercises(drill: Drill, theme: Option(String)) -> List(Exercise) {
  case drill, theme {
    exercise.Numbers, None -> numbers.exercises()
    exercise.Numbers, Some(_) -> []
    exercise.Mixed, _ ->
      list.flatten([
        entries_in(theme) |> list.flat_map(exercise.from_entry),
        case theme {
          None -> numbers.exercises()
          Some(_) -> []
        },
      ])
      |> list.filter(fn(e) { exercise.in_mixed_rounds(e.kind) })
    _, _ -> entry_exercises(drill, theme)
  }
}

fn entries_in(theme: Option(String)) -> List(Entry) {
  list.filter(entries(), fn(entry) {
    case theme {
      Some(theme) -> entry.theme == theme
      None -> True
    }
  })
}

fn entry_exercises(drill: Drill, theme: Option(String)) -> List(Exercise) {
  entries_in(theme)
  |> list.flat_map(exercise.from_entry)
  |> list.filter(fn(exercise) { exercise.drill(exercise.kind) == drill })
}

/// The themes that have at least one exercise for the drill.
pub fn themes_for(drill: Drill) -> List(String) {
  list.filter(themes(), fn(theme) { exercises(drill, Some(theme)) != [] })
}

/// Groups of exercise ids that share a kind and a prompt. Such exercises
/// cannot both be answered right, since each only accepts its own answers.
/// Dictation is left out (its stimulus is the audio, the prompt only a
/// hint), and so are questions about texts.
pub fn ambiguous_prompts(entries: List(Entry)) -> List(List(String)) {
  entries
  |> list.flat_map(exercise.from_entry)
  |> list.filter(fn(e) {
    case e.kind {
      // Questions about texts are asked in the context of their text.
      exercise.Listen | exercise.Comprehend(..) -> False
      _ -> True
    }
  })
  |> list.group(fn(e) { #(e.kind, answer.normalise(e.prompt, answer.Swedish)) })
  |> dict.values
  |> list.filter(fn(group) { list.length(group) > 1 })
  |> list.map(fn(group) { list.reverse(list.map(group, fn(e) { e.id })) })
}
