import franska/lexicon.{Feminine, Masculine}
import gleam/list

pub fn french_includes_definite_article_test() {
  assert lexicon.french(lexicon.noun("chat", Masculine)) == "le chat"
  assert lexicon.french(lexicon.noun("maison", Feminine)) == "la maison"
}

pub fn article_elides_before_vowel_and_h_test() {
  assert lexicon.french(lexicon.noun("école", Feminine)) == "l'école"
  assert lexicon.french(lexicon.noun("homme", Masculine)) == "l'homme"
}

pub fn aspirated_h_does_not_elide_test() {
  assert lexicon.french(lexicon.noun_aspirated_h("héros", Masculine))
    == "le héros"
}

pub fn je_elides_before_vowel_test() {
  assert lexicon.with_pronoun("aime", lexicon.Je) == "j'aime"
  assert lexicon.with_pronoun("parle", lexicon.Je) == "je parle"
  assert lexicon.with_pronoun("parlons", lexicon.Nous) == "nous parlons"
}

fn verb(infinitive: String, present: List(String)) -> lexicon.Word {
  let assert [je, tu, il, nous, vous, ils] = present
  lexicon.Verb(
    infinitive:,
    present: lexicon.Present(je:, tu:, il:, nous:, vous:, ils:),
    participle: "",
    auxiliary: lexicon.Avoir,
  )
}

fn imparfait(word: lexicon.Word) -> List(String) {
  list.map(lexicon.persons, lexicon.conjugated(word, lexicon.Imparfait, _))
}

pub fn imparfait_comes_from_the_nous_stem_test() {
  let parler =
    verb("parler", ["parle", "parles", "parle", "parlons", "parlez", "parlent"])
  assert imparfait(parler)
    == [
      "je parlais", "tu parlais", "il parlait", "nous parlions", "vous parliez",
      "ils parlaient",
    ]
  let faire =
    verb("faire", ["fais", "fais", "fait", "faisons", "faites", "font"])
  assert imparfait(faire)
    == [
      "je faisais", "tu faisais", "il faisait", "nous faisions", "vous faisiez",
      "ils faisaient",
    ]
}

pub fn imparfait_of_etre_and_elision_test() {
  let etre = verb("être", ["suis", "es", "est", "sommes", "êtes", "sont"])
  assert imparfait(etre)
    == [
      "j'étais", "tu étais", "il était", "nous étions", "vous étiez",
      "ils étaient",
    ]
}

pub fn imparfait_spelling_changes_before_i_test() {
  let manger =
    verb("manger", ["mange", "manges", "mange", "mangeons", "mangez", "mangent"])
  assert imparfait(manger)
    == [
      "je mangeais", "tu mangeais", "il mangeait", "nous mangions",
      "vous mangiez", "ils mangeaient",
    ]
  let commencer =
    verb("commencer", [
      "commence", "commences", "commence", "commençons", "commencez",
      "commencent",
    ])
  assert lexicon.conjugated(commencer, lexicon.Imparfait, lexicon.Je)
    == "je commençais"
  assert lexicon.conjugated(commencer, lexicon.Imparfait, lexicon.Nous)
    == "nous commencions"
}
