import franska/answer.{
  Almost, Correct, MissingAccents, MissingArticle, Typo, Wrong,
}
import franska/exercise.{
  ChooseArticle, Conjugate, Listen, ToFrench, ToSwedish, Translate,
}
import franska/lexicon.{A1, Entry, Expression, Feminine, Present, Verb}
import gleam/list
import gleam/string

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
      "aimé",
      lexicon.Avoir,
      False,
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
        Conjugate(lexicon.Presens, _) -> True
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
  assert exercise.drill(Conjugate(lexicon.FuturProche, lexicon.Nous))
    == exercise.Conjugation(lexicon.FuturProche)
  assert exercise.drill(Translate(ToSwedish)) == exercise.TranslateToSwedish
}

pub fn dictation_hints_the_meaning_and_expects_the_french_test() {
  let ex = find(maison(), "maison:listen")
  assert ex.prompt == "hus"
  assert ex.french == "la maison"
  assert exercise.check(ex, "la maison") == Correct
}

pub fn existing_present_ids_are_kept_test() {
  let ids = exercise.from_entry(aimer()) |> list.map(fn(e) { e.id })
  assert list.contains(ids, "aimer:present:je")
  assert list.contains(ids, "aimer:present:ils")
}

pub fn futur_proche_is_aller_and_the_infinitive_test() {
  let je = find(aimer(), "aimer:futur-proche:je")
  assert je.french == "je vais aimer"
  assert exercise.check(je, "vais aimer") == Correct
  assert exercise.check(je, "je vais aimer") == Correct
  let elles = find(aimer(), "aimer:futur-proche:ils")
  assert exercise.check(elles, "elles vont aimer") == Correct
  assert exercise.check(elles, "ils vont aimer") == Correct
}

fn aller() {
  Entry(
    id: "aller",
    level: A1,
    theme: "verb",
    sv: ["gå"],
    word: Verb(
      "aller",
      Present("vais", "vas", "va", "allons", "allez", "vont"),
      "allé",
      lexicon.Etre,
      False,
    ),
  )
}

pub fn passe_compose_with_avoir_test() {
  let je = find(aimer(), "aimer:passe-compose:je")
  assert je.french == "j'ai aimé"
  assert exercise.check(je, "ai aimé") == Correct
  assert exercise.check(je, "j'ai aimé") == Correct
  let nous = find(aimer(), "aimer:passe-compose:nous")
  assert nous.french == "nous avons aimé"
}

pub fn passe_compose_with_etre_agrees_with_the_subject_test() {
  let je = find(aller(), "aller:passe-compose:je")
  assert je.french == "je suis allé"
  assert exercise.check(je, "je suis allée") == Correct
  let il = find(aller(), "aller:passe-compose:il")
  assert exercise.check(il, "il est allé") == Correct
  assert exercise.check(il, "elle est allée") == Correct
  assert exercise.check(il, "on est allés") == Correct
  let ils = find(aller(), "aller:passe-compose:ils")
  assert ils.french == "ils sont allés"
  assert exercise.check(ils, "elles sont allées") == Correct
  assert exercise.check(ils, "ils sont allé") == Almost("ils sont allés", Typo)
}

pub fn a_sentence_yields_only_a_gap_exercise_test() {
  let entry =
    Entry(
      id: "je-suis",
      level: A1,
      theme: "meningar",
      sv: ["Jag är svensk."],
      word: lexicon.Sentence("Je ___ suédois.", ["suis"], "être"),
    )
  let assert [ex] = exercise.from_entry(entry)
  assert ex.kind
    == exercise.FillGap(hint: "être", translation: "Jag är svensk.")
  assert ex.prompt == "Je ___ suédois."
  assert ex.french == "Je suis suédois."
  assert exercise.check(ex, "suis") == Correct
  assert exercise.check(ex, "es") == Wrong("suis")
}

fn adjective(id: String, word: lexicon.Word) {
  Entry(id:, level: A1, theme: "egenskaper", sv: ["x"], word:)
}

pub fn adjectives_practise_the_forms_that_differ_test() {
  let grand = adjective("grand", lexicon.adjective("grand", "grande"))
  let ids = exercise.from_entry(grand) |> list.map(fn(e) { e.id })
  assert list.filter(ids, string.starts_with(_, "grand:agree"))
    == ["grand:agree:fs", "grand:agree:mp", "grand:agree:fp"]
  let fp = find(grand, "grand:agree:fp")
  assert fp.prompt == "grand"
  assert exercise.check(fp, "grandes") == Correct
  // rouge is rouge in the feminine, so only the plural is practised.
  let rouge = adjective("rouge", lexicon.adjective("rouge", "rouge"))
  assert exercise.from_entry(rouge)
    |> list.filter(fn(e) { string.starts_with(e.id, "rouge:agree") })
    |> list.map(fn(e) { e.id })
    == ["rouge:agree:mp"]
}

pub fn either_gender_translates_an_adjective_test() {
  let petit = adjective("petit", lexicon.adjective("petit", "petite"))
  let ex = find(petit, "petit:to-fr")
  assert exercise.check(ex, "petit") == Correct
  assert exercise.check(ex, "petite") == Correct
}

pub fn a_negation_rewrite_takes_the_whole_sentence_test() {
  let entry =
    Entry(
      id: "neg-tu-as",
      level: A1,
      theme: "negation",
      sv: ["Du har ingen hund."],
      word: lexicon.Rewrite(lexicon.Negate, "Tu as un chien.", [
        "Tu n'as pas de chien.",
      ]),
    )
  let assert [ex] = exercise.from_entry(entry)
  assert exercise.drill(ex.kind) == exercise.Negation
  assert ex.prompt == "Tu as un chien."
  assert exercise.check(ex, "tu n’as pas de chien") == Correct
  assert exercise.check(ex, "tu n'as pas de chien") == Correct
  assert exercise.check(ex, "Tu n'as pas un chien.")
    == Wrong("Tu n'as pas de chien.")
  assert exercise.check(ex, "Tu n'as pas de chién.")
    == Almost("Tu n'as pas de chien.", MissingAccents)
}
