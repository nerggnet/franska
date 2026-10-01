//// A1 vocabulary. Ids are stored with the learner's progress: never rename
//// or reuse one. Put the canonical translation first in `sv`.

import franska/lexicon.{
  type Entry, type Word, A1, Entry, Expression, Feminine, Masculine, Present,
  Verb,
}

pub fn entries() -> List(Entry) {
  [
    // Hälsningar och fraser
    phrase("bonjour", "hälsningar", ["god dag", "goddag", "hej"], ["bonjour"]),
    phrase("bonsoir", "hälsningar", ["god kväll", "godkväll"], ["bonsoir"]),
    phrase("bonne-nuit", "hälsningar", ["god natt", "godnatt"], ["bonne nuit"]),
    phrase("salut", "hälsningar", ["hej", "tjena"], ["salut", "coucou"]),
    phrase("au-revoir", "hälsningar", ["hej då", "adjö"], ["au revoir"]),
    phrase("merci", "hälsningar", ["tack"], ["merci"]),
    phrase("merci-beaucoup", "hälsningar", ["tack så mycket"], [
      "merci beaucoup",
    ]),
    phrase("s-il-vous-plait", "hälsningar", ["snälla", "var snäll"], [
      "s'il vous plaît", "s'il te plaît",
    ]),
    phrase("excusez-moi", "hälsningar", ["ursäkta", "förlåt"], [
      "excusez-moi", "excuse-moi", "pardon",
    ]),
    phrase("oui", "hälsningar", ["ja"], ["oui"]),
    phrase("non", "hälsningar", ["nej"], ["non"]),
    phrase("comment-ca-va", "hälsningar", ["hur mår du?", "hur är det?"], [
      "comment ça va ?", "ça va ?", "comment vas-tu ?", "comment allez-vous ?",
    ]),
    phrase("je-m-appelle", "hälsningar", ["jag heter"], ["je m'appelle"]),
    // Familj och människor
    noun("mere", "familj", "mère", Feminine, ["mor", "mamma"]),
    noun("pere", "familj", "père", Masculine, ["far", "pappa"]),
    noun("frere", "familj", "frère", Masculine, ["bror", "brorsa"]),
    noun("soeur", "familj", "sœur", Feminine, ["syster"]),
    noun("fils", "familj", "fils", Masculine, ["son"]),
    noun("fille", "familj", "fille", Feminine, ["dotter", "flicka", "tjej"]),
    noun("enfant", "familj", "enfant", Masculine, ["barn"]),
    noun("ami", "familj", "ami", Masculine, ["vän", "kompis"]),
    noun("homme", "familj", "homme", Masculine, ["man"]),
    noun("femme", "familj", "femme", Feminine, ["kvinna", "fru", "hustru"]),
    // Mat och dryck
    noun("pain", "mat", "pain", Masculine, ["bröd"]),
    noun("eau", "mat", "eau", Feminine, ["vatten"]),
    noun("lait", "mat", "lait", Masculine, ["mjölk"]),
    noun("fromage", "mat", "fromage", Masculine, ["ost"]),
    noun("beurre", "mat", "beurre", Masculine, ["smör"]),
    noun("oeuf", "mat", "œuf", Masculine, ["ägg"]),
    noun("viande", "mat", "viande", Feminine, ["kött"]),
    noun("poisson", "mat", "poisson", Masculine, ["fisk"]),
    noun("pomme", "mat", "pomme", Feminine, ["äpple"]),
    noun("cafe", "mat", "café", Masculine, ["kaffe", "kafé"]),
    noun("the", "mat", "thé", Masculine, ["te"]),
    noun("vin", "mat", "vin", Masculine, ["vin"]),
    // Hemmet
    noun("maison", "hemmet", "maison", Feminine, ["hus", "hem"]),
    noun("chambre", "hemmet", "chambre", Feminine, ["sovrum", "rum"]),
    noun("cuisine", "hemmet", "cuisine", Feminine, ["kök"]),
    noun("table", "hemmet", "table", Feminine, ["bord"]),
    noun("chaise", "hemmet", "chaise", Feminine, ["stol"]),
    noun("lit", "hemmet", "lit", Masculine, ["säng"]),
    noun("porte", "hemmet", "porte", Feminine, ["dörr"]),
    noun("fenetre", "hemmet", "fenêtre", Feminine, ["fönster"]),
    noun("livre", "hemmet", "livre", Masculine, ["bok"]),
    // Djur
    noun("chat", "djur", "chat", Masculine, ["katt"]),
    noun("chien", "djur", "chien", Masculine, ["hund"]),
    noun("oiseau", "djur", "oiseau", Masculine, ["fågel"]),
    noun("cheval", "djur", "cheval", Masculine, ["häst"]),
    // Staden
    noun("ville", "staden", "ville", Feminine, ["stad"]),
    noun("rue", "staden", "rue", Feminine, ["gata"]),
    noun("ecole", "staden", "école", Feminine, ["skola"]),
    noun("gare", "staden", "gare", Feminine, [
      "järnvägsstation", "tågstation", "station",
    ]),
    noun("voiture", "staden", "voiture", Feminine, ["bil"]),
    noun("magasin", "staden", "magasin", Masculine, ["affär", "butik"]),
    noun("eglise", "staden", "église", Feminine, ["kyrka"]),
    // Vanliga verb
    verb("etre", ["vara"], "être", #(
      "suis",
      "es",
      "est",
      "sommes",
      "êtes",
      "sont",
    )),
    verb("avoir", ["ha"], "avoir", #("ai", "as", "a", "avons", "avez", "ont")),
    verb("aller", ["gå", "åka", "fara"], "aller", #(
      "vais",
      "vas",
      "va",
      "allons",
      "allez",
      "vont",
    )),
    verb("faire", ["göra"], "faire", #(
      "fais",
      "fais",
      "fait",
      "faisons",
      "faites",
      "font",
    )),
    verb("parler", ["tala", "prata"], "parler", #(
      "parle",
      "parles",
      "parle",
      "parlons",
      "parlez",
      "parlent",
    )),
    verb("aimer", ["älska", "tycka om", "gilla"], "aimer", #(
      "aime",
      "aimes",
      "aime",
      "aimons",
      "aimez",
      "aiment",
    )),
    verb("manger", ["äta"], "manger", #(
      "mange",
      "manges",
      "mange",
      "mangeons",
      "mangez",
      "mangent",
    )),
    verb("habiter", ["bo"], "habiter", #(
      "habite",
      "habites",
      "habite",
      "habitons",
      "habitez",
      "habitent",
    )),
    verb("vouloir", ["vilja"], "vouloir", #(
      "veux",
      "veux",
      "veut",
      "voulons",
      "voulez",
      "veulent",
    )),
    verb("pouvoir", ["kunna"], "pouvoir", #(
      "peux",
      "peux",
      "peut",
      "pouvons",
      "pouvez",
      "peuvent",
    )),
    verb("prendre", ["ta"], "prendre", #(
      "prends",
      "prends",
      "prend",
      "prenons",
      "prenez",
      "prennent",
    )),
    verb("boire", ["dricka"], "boire", #(
      "bois",
      "bois",
      "boit",
      "buvons",
      "buvez",
      "boivent",
    )),
  ]
}

fn entry(id: String, theme: String, sv: List(String), word: Word) -> Entry {
  Entry(id:, level: A1, theme:, sv:, word:)
}

fn phrase(id, theme, sv, fr) -> Entry {
  entry(id, theme, sv, Expression(fr))
}

fn noun(id, theme, fr, gender, sv) -> Entry {
  entry(id, theme, sv, lexicon.noun(fr, gender))
}

fn verb(id, sv, infinitive, forms) -> Entry {
  let #(je, tu, il, nous, vous, ils) = forms
  entry(
    id,
    "verb",
    sv,
    Verb(infinitive, Present(je:, tu:, il:, nous:, vous:, ils:)),
  )
}
