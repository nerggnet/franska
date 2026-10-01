//// All curated content. Add a new level or content module here.

import franska/content/a1
import franska/exercise.{type Drill, type Exercise}
import franska/lexicon.{type Entry}
import gleam/list
import gleam/option.{type Option, None, Some}

pub fn entries() -> List(Entry) {
  a1.entries()
}

/// Every theme in the content, in the order it first appears.
pub fn themes() -> List(String) {
  entries()
  |> list.map(fn(entry) { entry.theme })
  |> list.unique
}

/// Every exercise of a drill, optionally limited to one theme.
pub fn exercises(drill: Drill, theme: Option(String)) -> List(Exercise) {
  entries()
  |> list.filter(fn(entry) {
    case theme {
      Some(theme) -> entry.theme == theme
      None -> True
    }
  })
  |> list.flat_map(exercise.from_entry)
  |> list.filter(fn(exercise) { exercise.drill(exercise.kind) == drill })
}

/// The themes that have at least one exercise for the drill.
pub fn themes_for(drill: Drill) -> List(String) {
  list.filter(themes(), fn(theme) { exercises(drill, Some(theme)) != [] })
}
