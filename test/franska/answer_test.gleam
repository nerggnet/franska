import franska/answer.{
  Almost, Correct, French, MissingAccents, MissingArticle, Swedish, Typo, Wrong,
  WrongArticle,
}

fn fr(given: String, accepted: List(String)) {
  answer.grade(given, accepted:, language: French)
}

fn sv(given: String, accepted: List(String)) {
  answer.grade(given, accepted:, language: Swedish)
}

pub fn exact_answer_is_correct_test() {
  assert fr("l'école", ["l'école"]) == Correct
}

pub fn case_spacing_and_punctuation_are_ignored_test() {
  assert fr("  Bonjour   Madame ! ", ["bonjour madame"]) == Correct
  assert fr("Ça va?", ["ça va ?"]) == Correct
}

pub fn apostrophe_style_is_ignored_test() {
  assert fr("l’école", ["l'école"]) == Correct
  assert fr("l' école", ["l'école"]) == Correct
}

pub fn decomposed_accents_match_precomposed_test() {
  assert fr("e\u{301}cole", ["école"]) == Correct
}

pub fn any_accepted_answer_is_correct_test() {
  assert sv("hej", ["hallå", "hej"]) == Correct
}

pub fn missing_accents_are_almost_test() {
  assert fr("l'ecole", ["l'école"]) == Almost("l'école", MissingAccents)
  assert fr("francais", ["français"]) == Almost("français", MissingAccents)
  assert fr("soeur", ["sœur"]) == Almost("sœur", MissingAccents)
}

pub fn wrong_accent_is_almost_test() {
  assert fr("trés", ["très"]) == Almost("très", MissingAccents)
}

pub fn missing_article_is_almost_test() {
  assert fr("chat", ["le chat"]) == Almost("le chat", MissingArticle)
  assert fr("ecole", ["l'école"]) == Almost("l'école", MissingArticle)
  assert fr("beure", ["le beurre"]) == Almost("le beurre", MissingArticle)
}

pub fn wrong_article_is_almost_test() {
  assert fr("la chat", ["le chat"]) == Almost("le chat", WrongArticle)
  assert fr("la école", ["l'école"]) == Almost("l'école", WrongArticle)
  assert fr("le maisson", ["la maison"]) == Almost("la maison", WrongArticle)
}

pub fn small_typo_is_almost_test() {
  assert fr("bonjuor", ["bonjour"]) == Almost("bonjour", Typo)
  assert fr("aujourdhui", ["aujourd'hui"]) == Almost("aujourd'hui", Typo)
}

pub fn short_words_allow_no_typos_test() {
  assert fr("oiu", ["oui"]) == Wrong("oui")
}

pub fn unrelated_answer_is_wrong_with_canonical_answer_test() {
  assert fr("merci", ["bonjour", "salut"]) == Wrong("bonjour")
}

pub fn empty_answer_is_wrong_test() {
  assert fr("   ", ["bonjour"]) == Wrong("bonjour")
}

pub fn swedish_leading_article_is_optional_test() {
  assert sv("en katt", ["katt"]) == Correct
  assert sv("katt", ["en katt"]) == Correct
  assert sv("att tala", ["tala"]) == Correct
}

pub fn swedish_letters_are_not_folded_test() {
  // "bat" is not a missing accent on "båt", but it is a one-letter typo.
  assert sv("bat", ["båt"]) == Wrong("båt")
  assert sv("flicka", ["flicka"]) == Correct
}

pub fn explanation_is_in_swedish_test() {
  assert answer.explain(Almost("l'école", MissingAccents))
    == "Nästan! Glöm inte accenterna: l'école"
  assert answer.explain(Wrong("le chat")) == "Fel. Rätt svar: le chat"
}
