import franska/answer.{Correct}
import franska/content
import franska/exercise
import franska/lexicon.{Expression}
import gleam/list
import gleam/option
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

pub fn exercises_are_limited_to_drill_and_theme_test() {
  let found = content.exercises(exercise.Articles, option.Some("djur"))
  assert list.map(found, fn(e) { e.prompt })
    == ["chat", "chien", "oiseau", "cheval"]
}

pub fn conjugation_is_only_available_for_verbs_test() {
  assert content.themes_for(exercise.Conjugation) == ["verb"]
}

pub fn articles_are_not_offered_for_themes_without_nouns_test() {
  let themes = content.themes_for(exercise.Articles)
  assert !list.contains(themes, "hälsningar")
  assert !list.contains(themes, "verb")
  assert list.contains(themes, "mat")
}
