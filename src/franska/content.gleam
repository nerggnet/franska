//// All curated content. Add a new level or content module here.

import franska/content/a1
import franska/lexicon.{type Entry}
import gleam/list

pub fn entries() -> List(Entry) {
  a1.entries()
}

/// Every theme in the content, in the order it first appears.
pub fn themes() -> List(String) {
  entries()
  |> list.map(fn(entry) { entry.theme })
  |> list.unique
}
