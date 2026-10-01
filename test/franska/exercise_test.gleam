import franska/answer.{Almost, Correct, MissingArticle, Wrong}
import franska/exercise.{
  ChooseArticle, Conjugate, Listen, ToFrench, ToSwedish, Translate,
}
import franska/lexicon.{A1, Entry, Expression, Feminine, Present, Verb}
import gleam/list

fn maison() {
  Entry(
    id: "maison",
    level: A1,
    theme: "hemmet",
    sv: ["hus", "hem"],
    word: lexicon.noun("maison", Feminine),
  )
}

fn aimer() {
  Entry(
    id: "aimer",
    level: A1,
    theme: "verb",
    sv: ["älska", "tycka om"],
    word: Verb(
      "aimer",
      Present("aime", "aimes", "aime", "aimons", "aimez", "aiment"),
    ),
  )
}

fn find(entry, id) {
  let assert Ok(found) =
    exercise.from_entry(entry) |> list.find(fn(e) { e.id == id })
  found
}

pub fn noun_yields_translations_dictation_and_article_exercise_test() {
  let kinds = exercise.from_entry(maison()) |> list.map(fn(e) { e.kind })
  assert kinds
    == [Translate(ToFrench), Translate(ToSwedish), Listen, ChooseArticle]
}

pub fn noun_to_french_requires_article_test() {
  let ex = find(maison(), "maison:to-fr")
  assert ex.prompt == "hus"
  assert exercise.check(ex, "la maison") == Correct
  assert exercise.check(ex, "maison") == Almost("la maison", MissingArticle)
}

pub fn noun_to_swedish_accepts_any_translation_test() {
  let ex = find(maison(), "maison:to-sv")
  assert ex.prompt == "la maison"
  assert exercise.check(ex, "ett hem") == Correct
}

pub fn article_exercise_checks_gender_test() {
  let ex = find(maison(), "maison:article")
  assert exercise.check(ex, "la") == Correct
  assert exercise.check(ex, "le") == Wrong("la")
}

pub fn verb_yields_one_exercise_per_person_test() {
  let conjugations =
    exercise.from_entry(aimer())
    |> list.filter(fn(e) {
      case e.kind {
        Conjugate(_) -> True
        _ -> False
      }
    })
  assert list.length(conjugations) == 6
}

pub fn conjugation_accepts_form_with_or_without_pronoun_test() {
  let je = find(aimer(), "aimer:present:je")
  assert exercise.check(je, "aime") == Correct
  assert exercise.check(je, "j'aime") == Correct
  let il = find(aimer(), "aimer:present:il")
  assert exercise.check(il, "elle aime") == Correct
  let nous = find(aimer(), "aimer:present:nous")
  assert exercise.check(nous, "aimez") == Wrong("aimons")
}

pub fn expression_accepts_all_french_variants_test() {
  let entry =
    Entry(
      id: "hej",
      level: A1,
      theme: "hälsningar",
      sv: ["hej"],
      word: Expression(["salut", "coucou"]),
    )
  assert exercise.check(find(entry, "hej:to-fr"), "coucou") == Correct
}

pub fn french_is_the_full_form_test() {
  assert find(maison(), "maison:article").french == "la maison"
  assert find(aimer(), "aimer:present:je").french == "j'aime"
  assert find(aimer(), "aimer:to-sv").french == "aimer"
}

pub fn drill_matches_kind_test() {
  assert exercise.drill(ChooseArticle) == exercise.Articles
  assert exercise.drill(Conjugate(lexicon.Nous)) == exercise.Conjugation
  assert exercise.drill(Translate(ToSwedish)) == exercise.TranslateToSwedish
}

pub fn dictation_hints_the_meaning_and_expects_the_french_test() {
  let ex = find(maison(), "maison:listen")
  assert ex.prompt == "hus"
  assert ex.french == "la maison"
  assert exercise.check(ex, "la maison") == Correct
}
