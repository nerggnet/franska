import franska/lexicon.{Feminine, Masculine}

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
