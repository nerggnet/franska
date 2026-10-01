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
  assert content.themes_for(exercise.Conjugation(lexicon.Presens)) == ["verb"]
  assert content.themes_for(exercise.Conjugation(lexicon.FuturProche))
    == ["verb"]
}

pub fn articles_are_not_offered_for_themes_without_nouns_test() {
  let themes = content.themes_for(exercise.Articles)
  assert !list.contains(themes, "hälsningar")
  assert !list.contains(themes, "verb")
  assert list.contains(themes, "mat")
}

pub fn content_has_both_levels_with_a1_first_test() {
  let levels = list.map(content.entries(), fn(e) { e.level })
  let #(a1, rest) = list.split_while(levels, fn(l) { l == lexicon.A1 })
  assert a1 != []
  assert rest != []
  assert list.all(rest, fn(l) { l == lexicon.A2 })
}

pub fn prompts_are_unambiguous_test() {
  assert content.ambiguous_prompts(content.entries()) == []
}

pub fn ambiguous_prompts_are_found_test() {
  let entry = fn(id, sv, fr) {
    lexicon.Entry(id:, level: lexicon.A1, theme: "t", sv:, word: Expression(fr))
  }
  let entries = [
    entry("hej", ["hej"], ["salut"]),
    entry("hej-igen", ["Hej!"], ["coucou"]),
    entry("tack", ["tack"], ["merci"]),
  ]
  assert content.ambiguous_prompts(entries) == [["hej:to-fr", "hej-igen:to-fr"]]
}

/// The imparfait is generated from the nous form, so it must end in -ons.
pub fn nous_forms_end_in_ons_test() {
  let bad =
    content.entries()
    |> list.filter_map(fn(e) {
      case e.word {
        lexicon.Verb(infinitive:, present:, ..) if infinitive != "être" ->
          case string.ends_with(present.nous, "ons") {
            True -> Error(Nil)
            False -> Ok(e.id)
          }
        _ -> Error(Nil)
      }
    })
  assert bad == []
}

pub fn sentences_have_one_gap_and_an_answer_test() {
  let bad =
    content.entries()
    |> list.filter_map(fn(e) {
      case e.word {
        lexicon.Sentence(text:, answers:, ..) ->
          case list.length(string.split(text, lexicon.gap)), answers {
            2, [_, ..] -> Error(Nil)
            _, _ -> Ok(e.id)
          }
        _ -> Error(Nil)
      }
    })
  assert bad == []
}
