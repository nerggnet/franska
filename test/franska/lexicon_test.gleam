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
    reflexive: False,
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

pub fn adjective_plurals_follow_the_usual_rules_test() {
  assert lexicon.adjective("grand", "grande")
    == lexicon.Adjective("grand", "grande", "grands", "grandes")
  assert lexicon.adjective("gris", "grise")
    == lexicon.Adjective("gris", "grise", "gris", "grises")
  assert lexicon.adjective("heureux", "heureuse")
    == lexicon.Adjective("heureux", "heureuse", "heureux", "heureuses")
  assert lexicon.adjective("beau", "belle")
    == lexicon.Adjective("beau", "belle", "beaux", "belles")
  assert lexicon.adjective("normal", "normale")
    == lexicon.Adjective("normal", "normale", "normaux", "normales")
}

fn reflexive(infinitive: String, present: List(String), participle: String) {
  let assert [je, tu, il, nous, vous, ils] = present
  lexicon.Verb(
    infinitive:,
    present: lexicon.Present(je:, tu:, il:, nous:, vous:, ils:),
    participle:,
    auxiliary: lexicon.Etre,
    reflexive: True,
  )
}

fn all_persons(word: lexicon.Word, tense: lexicon.Tense) -> List(String) {
  list.map(lexicon.persons, lexicon.conjugated(word, tense, _))
}

pub fn reflexive_verbs_take_their_pronoun_test() {
  let lever =
    reflexive(
      "lever",
      ["lève", "lèves", "lève", "levons", "levez", "lèvent"],
      "levé",
    )
  assert lexicon.french(lever) == "se lever"
  assert all_persons(lever, lexicon.Presens)
    == [
      "je me lève", "tu te lèves", "il se lève", "nous nous levons",
      "vous vous levez", "ils se lèvent",
    ]
  assert all_persons(lever, lexicon.FuturProche)
    == [
      "je vais me lever", "tu vas te lever", "il va se lever",
      "nous allons nous lever", "vous allez vous lever", "ils vont se lever",
    ]
  assert all_persons(lever, lexicon.PasseCompose)
    == [
      "je me suis levé", "tu t'es levé", "il s'est levé",
      "nous nous sommes levés", "vous vous êtes levés", "ils se sont levés",
    ]
  assert lexicon.conjugated(lever, lexicon.Imparfait, lexicon.Je)
    == "je me levais"
}

pub fn reflexive_pronouns_elide_before_a_vowel_sound_test() {
  let habiller =
    reflexive(
      "habiller",
      ["habille", "habilles", "habille", "habillons", "habillez", "habillent"],
      "habillé",
    )
  assert lexicon.french(habiller) == "s'habiller"
  assert all_persons(habiller, lexicon.Presens)
    == [
      "je m'habille", "tu t'habilles", "il s'habille", "nous nous habillons",
      "vous vous habillez", "ils s'habillent",
    ]
  assert lexicon.conjugated(habiller, lexicon.FuturProche, lexicon.Je)
    == "je vais m'habiller"
}

pub fn reflexive_passe_compose_agrees_with_the_subject_test() {
  let lever =
    reflexive(
      "lever",
      ["lève", "lèves", "lève", "levons", "levez", "lèvent"],
      "levé",
    )
  let answers =
    lexicon.conjugation_answers(lever, lexicon.PasseCompose, lexicon.Il)
  assert list.contains(answers, "elle s'est levée")
  assert list.contains(answers, "on s'est levés")
}

pub fn marked_part_test() {
  assert lexicon.marked_part("Je vois [Marie].")
    == Ok(#("Je vois ", "Marie", "."))
  assert lexicon.marked_part("Je vois Marie.") == Error(Nil)
  assert lexicon.marked_part("[Je] vois [Marie].") == Error(Nil)
}

fn imperative(word: lexicon.Word) -> List(String) {
  list.map([lexicon.Tu, lexicon.Nous, lexicon.Vous], fn(person) {
    lexicon.conjugated(word, lexicon.Imperatif, person)
  })
}

pub fn imperative_of_er_verbs_drops_the_s_test() {
  let parler =
    verb("parler", ["parle", "parles", "parle", "parlons", "parlez", "parlent"])
  assert imperative(parler) == ["parle", "parlons", "parlez"]
  let aller = verb("aller", ["vais", "vas", "va", "allons", "allez", "vont"])
  assert imperative(aller) == ["va", "allons", "allez"]
  let finir =
    verb("finir", [
      "finis",
      "finis",
      "finit",
      "finissons",
      "finissez",
      "finissent",
    ])
  assert imperative(finir) == ["finis", "finissons", "finissez"]
}

pub fn irregular_imperatives_test() {
  let etre = verb("être", ["suis", "es", "est", "sommes", "êtes", "sont"])
  assert imperative(etre) == ["sois", "soyons", "soyez"]
  let avoir = verb("avoir", ["ai", "as", "a", "avons", "avez", "ont"])
  assert imperative(avoir) == ["aie", "ayons", "ayez"]
}

pub fn verbs_without_an_imperative_test() {
  let pouvoir =
    verb("pouvoir", ["peux", "peux", "peut", "pouvons", "pouvez", "peuvent"])
  assert lexicon.conjugation_answers(pouvoir, lexicon.Imperatif, lexicon.Tu)
    == []
  let parler =
    verb("parler", ["parle", "parles", "parle", "parlons", "parlez", "parlent"])
  assert lexicon.conjugation_answers(parler, lexicon.Imperatif, lexicon.Je)
    == []
}

pub fn reflexive_imperative_puts_the_pronoun_after_test() {
  let lever =
    reflexive(
      "lever",
      ["lève", "lèves", "lève", "levons", "levez", "lèvent"],
      "levé",
    )
  assert imperative(lever) == ["lève-toi", "levons-nous", "levez-vous"]
}

fn compared(masculine: String, feminine: String) -> List(List(String)) {
  list.map(lexicon.degrees, lexicon.compared(
    lexicon.adjective(masculine, feminine),
    _,
  ))
}

pub fn comparisons_agree_with_the_subject_test() {
  assert compared("grand", "grande")
    == [
      ["plus grande"],
      ["moins grands"],
      ["aussi grand"],
      ["les plus grandes"],
    ]
  assert compared("beau", "belle")
    == [["plus belle"], ["moins beaux"], ["aussi beau"], ["les plus belles"]]
}

pub fn bon_and_mauvais_are_irregular_test() {
  assert compared("bon", "bonne")
    == [["meilleure"], ["moins bons"], ["aussi bon"], ["les meilleures"]]
  assert compared("mauvais", "mauvaise")
    == [
      ["plus mauvaise", "pire"],
      ["moins mauvais"],
      ["aussi mauvais"],
      ["les plus mauvaises", "les pires"],
    ]
}

pub fn invariable_adjectives_are_not_compared_test() {
  assert lexicon.compared(lexicon.invariable_adjective("marron"), lexicon.More)
    == []
}
