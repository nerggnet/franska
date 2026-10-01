import franska/answer.{Correct}
import franska/content
import franska/exercise
import franska/lexicon.{Expression}
import gleam/list
import gleam/string

pub fn entry_ids_are_unique_test() {
  let ids = list.map(content.entries(), fn(e) { e.id })
  assert list.length(ids) == list.length(list.unique(ids))
}

pub fn entry_ids_are_ascii_slugs_test() {
  let allowed = string.to_graphemes("abcdefghijklmnopqrstuvwxyz-")
  let bad =
    list.filter(content.entries(), fn(e) {
      !list.all(string.to_graphemes(e.id), list.contains(allowed, _))
    })
  assert bad == []
}

pub fn every_entry_has_translations_test() {
  let bad =
    list.filter(content.entries(), fn(e) {
      e.sv == []
      || case e.word {
        Expression(fr: []) -> True
        _ -> False
      }
    })
  assert bad == []
}

pub fn every_canonical_answer_grades_as_correct_test() {
  let bad =
    content.entries()
    |> list.flat_map(exercise.from_entry)
    |> list.filter(fn(ex) {
      list.any(ex.accepted, fn(a) { exercise.check(ex, a) != Correct })
    })
    |> list.map(fn(ex) { ex.id })
  assert bad == []
}

pub fn there_are_about_fifty_entries_test() {
  assert list.length(content.entries()) >= 50
}
