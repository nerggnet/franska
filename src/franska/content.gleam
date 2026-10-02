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
import gleam/set

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

/// Every exercise, built once, with each entry's theme, so that choosing
/// exercises by drill, theme and level is a cheap filter. Building it is
/// the expensive part: do it once (the app does it at start-up).
pub type Catalog {
  Catalog(
    all: List(Exercise),
    theme_of: dict.Dict(String, String),
    themes: List(String),
  )
}

pub fn catalog() -> Catalog {
  Catalog(
    all: all_exercises(),
    theme_of: entries()
      |> list.map(fn(entry) { #(entry.id, entry.theme) })
      |> dict.from_list,
    themes: themes(),
  )
}

/// The exercises of a drill for a theme and a level (`None` for any).
pub fn select(
  catalog: Catalog,
  drill: Drill,
  theme: Option(String),
  level: Option(lexicon.Level),
) -> List(Exercise) {
  catalog.all
  |> list.filter(fn(e) { in_drill(e, drill) && has_theme(catalog, e, theme) })
  |> at_level(level)
}

/// The themes with at least one exercise for the drill at the level, in
/// content order.
pub fn select_themes(
  catalog: Catalog,
  drill: Drill,
  level: Option(lexicon.Level),
) -> List(String) {
  let found =
    catalog.all
    |> list.filter(fn(e) { in_drill(e, drill) })
    |> at_level(level)
    |> list.filter_map(fn(e) { dict.get(catalog.theme_of, e.entry_id) })
    |> set.from_list
  list.filter(catalog.themes, set.contains(found, _))
}

fn in_drill(e: Exercise, drill: Drill) -> Bool {
  case drill {
    exercise.Mixed -> exercise.in_mixed_rounds(e.kind)
    _ -> exercise.drill(e.kind) == drill
  }
}

/// Numbers have no theme, so they only count when no theme is chosen.
fn has_theme(catalog: Catalog, e: Exercise, theme: Option(String)) -> Bool {
  case theme {
    None -> True
    Some(theme) -> dict.get(catalog.theme_of, e.entry_id) == Ok(theme)
  }
}

/// Every exercise of every drill.
pub fn all_exercises() -> List(Exercise) {
  exercises_of(entries())
  |> list.append(numbers.exercises())
}

/// The exercises of some entries, where a Swedish → French translation
/// also accepts the French of every other entry with the prompt among its
/// translations: "ringa" is appeler, but téléphoner is right too.
fn exercises_of(some: List(Entry)) -> List(Exercise) {
  let synonyms = synonyms()
  some
  |> list.flat_map(exercise.from_entry)
  |> list.map(fn(e) {
    case
      e.kind,
      dict.get(synonyms, answer.normalise(e.prompt, answer.Swedish))
    {
      exercise.Translate(exercise.ToFrench), Ok(french) ->
        exercise.Exercise(
          ..e,
          accepted: list.unique(list.append(e.accepted, french)),
        )
      _, _ -> e
    }
  })
}

/// Every Swedish translation, normalised, with the French answers of the
/// entries that list it.
fn synonyms() -> dict.Dict(String, List(String)) {
  entries()
  |> list.flat_map(fn(entry) {
    let french =
      exercise.from_entry(entry)
      |> list.filter(fn(e) { e.kind == exercise.Translate(exercise.ToFrench) })
      |> list.flat_map(fn(e) { e.accepted })
    list.map(entry.sv, fn(sv) {
      #(answer.normalise(sv, answer.Swedish), french)
    })
  })
  |> list.fold(dict.new(), fn(acc, pair) {
    dict.upsert(acc, pair.0, fn(existing) {
      case existing {
        option.Some(french) -> list.append(french, pair.1)
        option.None -> pair.1
      }
    })
  })
}

/// Every exercise of a drill, optionally limited to one theme. Numbers are
/// generated and have no theme. Builds the whole catalogue: the app uses
/// `select` on a catalogue it keeps instead.
pub fn exercises(drill: Drill, theme: Option(String)) -> List(Exercise) {
  select(catalog(), drill, theme, None)
}

/// Only the exercises of the given level, or all for `None`.
pub fn at_level(
  exercises: List(Exercise),
  level: Option(lexicon.Level),
) -> List(Exercise) {
  case level {
    None -> exercises
    Some(level) -> list.filter(exercises, fn(e) { e.level == level })
  }
}

/// The themes that have at least one exercise for the drill.
pub fn themes_for(drill: Drill) -> List(String) {
  select_themes(catalog(), drill, None)
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
  |> list.group(fn(e) {
    // Only Swedish → French has a Swedish prompt; "en haut" is not "haut".
    let language = case e.kind {
      exercise.Translate(exercise.ToFrench) -> answer.Swedish
      _ -> answer.French
    }
    #(e.kind, answer.normalise(e.prompt, language))
  })
  |> dict.values
  |> list.filter(fn(group) { list.length(group) > 1 })
  |> list.map(fn(group) { list.reverse(list.map(group, fn(e) { e.id })) })
}
