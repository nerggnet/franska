//// A1 vocabulary. Ids are stored with the learner's progress: never rename
//// or reuse one. Put the canonical translation first in `sv`.

import franska/lexicon.{
  type Entry, type Word, A1, Avoir, Entry, Etre, Expression, Feminine, Masculine,
  Present, Sentence, Verb,
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
    verb(
      "etre",
      ["vara"],
      "être",
      #("suis", "es", "est", "sommes", "êtes", "sont"),
      "été",
      Avoir,
    ),
    verb(
      "avoir",
      ["ha"],
      "avoir",
      #("ai", "as", "a", "avons", "avez", "ont"),
      "eu",
      Avoir,
    ),
    verb(
      "aller",
      ["gå", "åka", "fara"],
      "aller",
      #("vais", "vas", "va", "allons", "allez", "vont"),
      "allé",
      Etre,
    ),
    verb(
      "faire",
      ["göra"],
      "faire",
      #("fais", "fais", "fait", "faisons", "faites", "font"),
      "fait",
      Avoir,
    ),
    verb(
      "parler",
      ["tala", "prata"],
      "parler",
      #("parle", "parles", "parle", "parlons", "parlez", "parlent"),
      "parlé",
      Avoir,
    ),
    verb(
      "aimer",
      ["älska", "tycka om", "gilla"],
      "aimer",
      #("aime", "aimes", "aime", "aimons", "aimez", "aiment"),
      "aimé",
      Avoir,
    ),
    verb(
      "manger",
      ["äta"],
      "manger",
      #("mange", "manges", "mange", "mangeons", "mangez", "mangent"),
      "mangé",
      Avoir,
    ),
    verb(
      "habiter",
      ["bo"],
      "habiter",
      #("habite", "habites", "habite", "habitons", "habitez", "habitent"),
      "habité",
      Avoir,
    ),
    verb(
      "vouloir",
      ["vilja"],
      "vouloir",
      #("veux", "veux", "veut", "voulons", "voulez", "veulent"),
      "voulu",
      Avoir,
    ),
    verb(
      "pouvoir",
      ["kunna"],
      "pouvoir",
      #("peux", "peux", "peut", "pouvons", "pouvez", "peuvent"),
      "pu",
      Avoir,
    ),
    verb(
      "prendre",
      ["ta"],
      "prendre",
      #("prends", "prends", "prend", "prenons", "prenez", "prennent"),
      "pris",
      Avoir,
    ),
    verb(
      "boire",
      ["dricka"],
      "boire",
      #("bois", "bois", "boit", "buvons", "buvez", "boivent"),
      "bu",
      Avoir,
    ),
    // Meningar
    sentence(
      "je-suis-suedois",
      "Jag är svensk.",
      "Je ___ suédois.",
      ["suis"],
      "être",
    ),
    sentence(
      "nous-habitons-a-paris",
      "Vi bor i Paris.",
      "Nous ___ à Paris.",
      ["habitons"],
      "habiter",
    ),
    sentence(
      "elle-a-un-chat",
      "Hon har en katt.",
      "Elle ___ un chat.",
      ["a"],
      "avoir",
    ),
    sentence(
      "tu-veux-du-cafe",
      "Vill du ha kaffe?",
      "Tu ___ du café ?",
      ["veux"],
      "vouloir",
    ),
    sentence(
      "ils-parlent-francais",
      "De talar franska.",
      "Ils ___ français.",
      ["parlent"],
      "parler",
    ),
    sentence(
      "il-va-au-cinema",
      "Han går på bio.",
      "Il ___ au cinéma.",
      ["va"],
      "aller",
    ),
    sentence(
      "vous-avez-quel-age",
      "Hur gammal är ni?",
      "Vous ___ quel âge ?",
      ["avez"],
      "avoir",
    ),
    sentence(
      "nous-mangeons-une-pizza",
      "Vi äter en pizza.",
      "Nous ___ une pizza.",
      ["mangeons"],
      "manger",
    ),
    sentence(
      "elles-vont-au-restaurant",
      "De går på restaurang.",
      "Elles ___ au restaurant.",
      ["vont"],
      "aller",
    ),
    sentence(
      "je-fais-mes-devoirs",
      "Jag gör mina läxor.",
      "Je ___ mes devoirs.",
      ["fais"],
      "faire",
    ),
    sentence(
      "j-aime-le-pain",
      "Jag tycker om bröd.",
      "J'aime ___ pain.",
      ["le"],
      "le/la",
    ),
    sentence(
      "la-maison-est-grande",
      "Huset är stort.",
      "___ maison est grande.",
      ["la"],
      "le/la",
    ),
    sentence(
      "c-est-le-livre-de-paul",
      "Det är Pauls bok.",
      "C'est ___ livre de Paul.",
      ["le"],
      "le/la",
    ),
    sentence(
      "et-toi",
      "Jag heter Anna, och du?",
      "Je m'appelle Anna, et ___ ?",
      ["toi", "vous"],
      "",
    ),
    sentence(
      "j-ai-vingt-ans",
      "Jag är tjugo år.",
      "J'ai ___ ans.",
      ["vingt"],
      "20",
    ),
    sentence(
      "il-fait-beau-aujourd-hui",
      "Det är fint väder i dag.",
      "Il fait ___ aujourd'hui.",
      ["beau"],
      "",
    ),
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

/// `forms` are the présent forms; `participle` and `auxiliary` give the
/// passé composé.
fn verb(id, sv, infinitive, forms, participle, auxiliary) -> Entry {
  let #(je, tu, il, nous, vous, ils) = forms
  entry(
    id,
    "verb",
    sv,
    Verb(
      infinitive:,
      present: Present(je:, tu:, il:, nous:, vous:, ils:),
      participle:,
      auxiliary:,
    ),
  )
}

/// A sentence with a `___` gap, its Swedish translation, the accepted
/// answers for the gap and a hint ("" for none).
fn sentence(id, sv, text, answers, hint) -> Entry {
  entry(id, "meningar", [sv], Sentence(text:, answers:, hint:))
}
