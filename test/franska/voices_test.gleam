import franska/voices.{Voice}
import gleam/list

pub fn rank_prefers_better_voices_test() {
  let ranked =
    voices.rank([
      Voice("Eddy (français (France))", "fr-FR"),
      Voice("Amélie", "fr-CA"),
      Voice("Samantha", "en-US"),
      Voice("Jacques", "fr-FR"),
      Voice("Thomas", "fr-FR"),
      Voice("Google français", "fr-FR"),
      Voice("Audrey (Premium)", "fr-FR"),
    ])
  assert list.map(ranked, fn(v) { v.name })
    == [
      "Audrey (Premium)", "Google français", "Jacques", "Thomas", "Amélie",
      "Eddy (français (France))",
    ]
}

pub fn rank_keeps_order_of_equal_voices_test() {
  let ranked =
    voices.rank([Voice("Thomas", "fr-FR"), Voice("Jacques", "fr-FR")])
  assert list.map(ranked, fn(v) { v.name }) == ["Thomas", "Jacques"]
}

pub fn gender_test() {
  assert voices.gender(Voice("Audrey (Premium)", "fr-FR")) == voices.Female
  assert voices.gender(Voice("Thomas", "fr-FR")) == voices.Male
  assert voices.gender(Voice("Google français", "fr-FR")) == voices.Unknown
}

pub fn partner_has_other_gender_test() {
  let ranked = [
    Voice("Audrey", "fr-FR"),
    Voice("Amélie", "fr-CA"),
    Voice("Thomas", "fr-FR"),
  ]
  assert voices.partner(Voice("Audrey", "fr-FR"), ranked).name == "Thomas"
  assert voices.partner(Voice("Thomas", "fr-FR"), ranked).name == "Audrey"
}

pub fn partner_falls_back_test() {
  let google = Voice("Google français", "fr-FR")
  let thomas = Voice("Thomas", "fr-FR")
  assert voices.partner(google, [google, thomas]) == thomas
  assert voices.partner(google, [google]) == google
}

pub fn utterances_split_sentences_test() {
  assert voices.utterances(
      "Je m'appelle Léa. J'habite à Lyon !\nM. Dupont est là.",
    )
    == [
      #(0, "Je m'appelle Léa."),
      #(0, "J'habite à Lyon !"),
      #(0, "M. Dupont est là."),
    ]
}

pub fn utterances_alternate_dialogue_test() {
  assert voices.utterances("— Bonjour !\n— Salut. Ça va ?\n— Oui.")
    == [#(0, "Bonjour !"), #(1, "Salut. Ça va ?"), #(0, "Oui.")]
}
