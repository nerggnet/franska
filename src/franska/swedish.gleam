//// A little Swedish grammar, for showing translations in the right form.

import franska/lexicon.{
  type Degree, type Person, type Tense, Conditionnel, Equal, FuturProche,
  FuturSimple, Il, Ils, Imparfait, Imperatif, Je, Less, More, Most, Nous,
  PasseCompose, Presens, Tu, Vous,
}
import gleam/list
import gleam/result
import gleam/string

/// The plural of a Swedish adjective: stor → stora, vacker → vackra,
/// öppen → öppna, tom → tomma, förvånad → förvånade. Adjectives ending in
/// a vowel other than the long ones (bra, rosa, nästa) and fel do not
/// change, nor do blå and grå in writing; liten, gammal and annan are
/// irregular.
pub fn adjective_plural(adjective: String) -> String {
  case adjective {
    "liten" -> "små"
    "gammal" -> "gamla"
    "annan" -> "andra"
    "fel" | "blå" | "grå" -> adjective
    _ ->
      case ends_with_any(adjective, ["a", "e", "o"]) {
        True -> adjective
        False -> regular_plural(adjective)
      }
  }
}

fn regular_plural(adjective: String) -> String {
  let length = string.length(adjective)
  case adjective {
    // vacker, säker, enkel: the e drops.
    _ if length > 3 ->
      case
        ends_with_any(adjective, ["er", "el"]),
        ends_with_unstressed_en(adjective)
      {
        True, _ | _, True ->
          string.drop_end(adjective, 2)
          <> string.slice(adjective, length - 1, 1)
          <> "a"
        False, False ->
          // Past participles in -ad (förvånad), not short words like glad.
          case string.ends_with(adjective, "ad") && length > 5 {
            True -> adjective <> "e"
            False -> double_final_m(adjective) <> "a"
          }
      }
    _ -> double_final_m(adjective) <> "a"
  }
}

/// öppen, ledsen, mogen, but not ren or grön.
fn ends_with_unstressed_en(adjective: String) -> Bool {
  string.ends_with(adjective, "en")
  && !ends_with_any(string.drop_end(adjective, 2), [
    "a",
    "e",
    "i",
    "o",
    "u",
    "y",
    "å",
    "ä",
    "ö",
  ])
}

/// tom → tomm-, ensam → ensamm-, but varm stays varm-.
fn double_final_m(adjective: String) -> String {
  case
    string.ends_with(adjective, "m"),
    ends_with_any(string.drop_end(adjective, 1), [
      "a",
      "e",
      "i",
      "o",
      "u",
      "y",
      "å",
      "ä",
      "ö",
    ])
  {
    True, True -> adjective <> "m"
    _, _ -> adjective
  }
}

fn ends_with_any(text: String, endings: List(String)) -> Bool {
  case endings {
    [] -> False
    [ending, ..rest] ->
      string.ends_with(text, ending) || ends_with_any(text, rest)
  }
}

// VERBS -----------------------------------------------------------------------

/// The forms a Swedish verb needs besides its infinitive. `imperative` is
/// "" for verbs without one (kunna, vilja).
type Forms {
  Forms(present: String, past: String, supine: String, imperative: String)
}

/// A Swedish verb phrase for a French verb in a tense and person: "talar"
/// becomes "vi talar", "jag har talat", "jag skulle tala", "tala!". `verb`
/// is the Swedish infinitive, possibly with a particle or a reflexive sig
/// after it ("stiga upp", "klä på sig"). Fails for a verb whose forms are
/// unknown.
pub fn conjugate(
  verb: String,
  tense: Tense,
  person: Person,
) -> Result(String, Nil) {
  let #(head, rest) = case string.split_once(verb, " ") {
    Ok(#(head, rest)) -> #(head, string.split(rest, " "))
    Error(Nil) -> #(verb, [])
  }
  let rest = list.map(rest, fn(word) { reflexive(word, person) })
  let subject = subject(person)
  let phrase = fn(words: List(String)) {
    words |> list.filter(fn(w) { w != "" }) |> string.join(" ")
  }
  case head {
    // måste has no infinitive, so its other tenses are paraphrased.
    "måste" -> {
      // tvungen agrees: vi var tvungna.
      let forced = case person {
        Nous | Vous | Ils -> "tvungna"
        _ -> "tvungen"
      }
      case tense {
        Presens -> Ok(phrase([subject, "måste", ..rest]))
        FuturProche -> Ok(phrase([subject, "ska behöva", ..rest]))
        FuturSimple -> Ok(phrase([subject, "kommer att behöva", ..rest]))
        PasseCompose -> Ok(phrase([subject, "har varit", forced, ..rest]))
        Imparfait -> Ok(phrase([subject, "var", forced, ..rest]))
        Conditionnel -> Ok(phrase([subject, "skulle behöva", ..rest]))
        Imperatif -> Error(Nil)
      }
    }
    _ -> {
      use forms <- result.try(forms(head))
      case tense {
        Presens -> Ok(phrase([subject, forms.present, ..rest]))
        FuturProche -> Ok(phrase([subject, "ska", head, ..rest]))
        FuturSimple -> Ok(phrase([subject, "kommer att", head, ..rest]))
        PasseCompose -> Ok(phrase([subject, "har", forms.supine, ..rest]))
        Imparfait -> Ok(phrase([subject, forms.past, ..rest]))
        Conditionnel -> Ok(phrase([subject, "skulle", head, ..rest]))
        Imperatif ->
          case forms.imperative, person {
            "", _ -> Error(Nil)
            _, Nous -> Ok(phrase(["låt oss", head, ..rest]) <> "!")
            imperative, _ -> Ok(phrase([imperative, ..rest]) <> "!")
          }
      }
    }
  }
}

fn subject(person: Person) -> String {
  case person {
    Je -> "jag"
    Tu -> "du"
    Il -> "han"
    Nous -> "vi"
    Vous -> "ni"
    Ils -> "de"
  }
}

/// sig in a reflexive verb follows the person: jag tvättar mig.
fn reflexive(word: String, person: Person) -> String {
  case word, person {
    "sig", Je -> "mig"
    "sig", Tu -> "dig"
    "sig", Nous -> "oss"
    "sig", Vous -> "er"
    _, _ -> word
  }
}

/// Verbs that do not follow the -ar pattern of tala, talar, talade, talat.
fn forms(verb: String) -> Result(Forms, Nil) {
  case verb {
    "vara" -> Ok(Forms("är", "var", "varit", "var"))
    "ha" -> Ok(Forms("har", "hade", "haft", "ha"))
    "gå" -> Ok(Forms("går", "gick", "gått", "gå"))
    "göra" -> Ok(Forms("gör", "gjorde", "gjort", "gör"))
    "äta" -> Ok(Forms("äter", "åt", "ätit", "ät"))
    "bo" -> Ok(Forms("bor", "bodde", "bott", "bo"))
    "vilja" -> Ok(Forms("vill", "ville", "velat", ""))
    "kunna" -> Ok(Forms("kan", "kunde", "kunnat", ""))
    "ta" -> Ok(Forms("tar", "tog", "tagit", "ta"))
    "dricka" -> Ok(Forms("dricker", "drack", "druckit", "drick"))
    "ge" -> Ok(Forms("ger", "gav", "gett", "ge"))
    "komma" -> Ok(Forms("kommer", "kom", "kommit", "kom"))
    "stänga" -> Ok(Forms("stänger", "stängde", "stängt", "stäng"))
    "stiga" -> Ok(Forms("stiger", "steg", "stigit", "stig"))
    "heta" -> Ok(Forms("heter", "hette", "hetat", "het"))
    "lägga" -> Ok(Forms("lägger", "lade", "lagt", "lägg"))
    "klä" -> Ok(Forms("klär", "klädde", "klätt", "klä"))
    "sjunga" -> Ok(Forms("sjunger", "sjöng", "sjungit", "sjung"))
    "hjälpa" -> Ok(Forms("hjälper", "hjälpte", "hjälpt", "hjälp"))
    "lära" -> Ok(Forms("lär", "lärde", "lärt", "lär"))
    "glömma" -> Ok(Forms("glömmer", "glömde", "glömt", "glöm"))
    "tänka" -> Ok(Forms("tänker", "tänkte", "tänkt", "tänk"))
    "bära" -> Ok(Forms("bär", "bar", "burit", "bär"))
    "besöka" -> Ok(Forms("besöker", "besökte", "besökt", "besök"))
    "falla" -> Ok(Forms("faller", "föll", "fallit", "fall"))
    "springa" -> Ok(Forms("springer", "sprang", "sprungit", "spring"))
    "tro" -> Ok(Forms("tror", "trodde", "trott", "tro"))
    "se" -> Ok(Forms("ser", "såg", "sett", "se"))
    "veta" -> Ok(Forms("vet", "visste", "vetat", "vet"))
    "säga" -> Ok(Forms("säger", "sa", "sagt", "säg"))
    "sätta" -> Ok(Forms("sätter", "satte", "satt", "sätt"))
    "åka" -> Ok(Forms("åker", "åkte", "åkt", "åk"))
    "sova" -> Ok(Forms("sover", "sov", "sovit", "sov"))
    "läsa" -> Ok(Forms("läser", "läste", "läst", "läs"))
    "skriva" -> Ok(Forms("skriver", "skrev", "skrivit", "skriv"))
    "köpa" -> Ok(Forms("köper", "köpte", "köpt", "köp"))
    "ringa" -> Ok(Forms("ringer", "ringde", "ringt", "ring"))
    "förstå" -> Ok(Forms("förstår", "förstod", "förstått", "förstå"))
    "känna" -> Ok(Forms("känner", "kände", "känt", "känn"))
    "sälja" -> Ok(Forms("säljer", "sålde", "sålt", "sälj"))
    "föredra" -> Ok(Forms("föredrar", "föredrog", "föredragit", "föredra"))
    "bli" -> Ok(Forms("blir", "blev", "blivit", "bli"))
    "få" -> Ok(Forms("får", "fick", "fått", "få"))
    "försöka" -> Ok(Forms("försöker", "försökte", "försökt", "försök"))
    "bestämma" -> Ok(Forms("bestämmer", "bestämde", "bestämt", "bestäm"))
    "välja" -> Ok(Forms("väljer", "valde", "valt", "välj"))
    "vinna" -> Ok(Forms("vinner", "vann", "vunnit", "vinn"))
    "köra" -> Ok(Forms("kör", "körde", "kört", "kör"))
    "leva" -> Ok(Forms("lever", "levde", "levt", "lev"))
    "låta" -> Ok(Forms("låter", "lät", "låtit", "låt"))
    "använda" -> Ok(Forms("använder", "använde", "använt", "använd"))
    "förbereda" ->
      Ok(Forms("förbereder", "förberedde", "förberett", "förbered"))
    "gråta" -> Ok(Forms("gråter", "grät", "gråtit", "gråt"))
    "byta" -> Ok(Forms("byter", "bytte", "bytt", "byt"))
    "fortsätta" -> Ok(Forms("fortsätter", "fortsatte", "fortsatt", "fortsätt"))
    "må" -> Ok(Forms("mår", "mådde", "mått", "må"))
    // Deponent verbs end in -s in every form and have no imperative.
    "lyckas" | "hoppas" -> {
      let stem = string.drop_end(verb, 2)
      Ok(Forms(verb, stem <> "ades", stem <> "ats", ""))
    }
    _ ->
      case string.ends_with(verb, "a") {
        True -> Ok(Forms(verb <> "r", verb <> "de", verb <> "t", verb))
        False -> Error(Nil)
      }
  }
}

// COMPARISON ------------------------------------------------------------------

/// The Swedish of the sentences in `lexicon.comparison_frame`, with the
/// adjective compared: "Hon är större än han.", "De är inte lika dyra som
/// vi." (more natural than mindre dyra än), "Han är lika stor som du.",
/// "De är störst av alla."
pub fn comparison(adjective: String, degree: Degree) -> String {
  let #(comparative, superlative) = compare(adjective)
  case degree {
    More -> "Hon är " <> comparative <> " än han."
    Less -> "De är inte lika " <> adjective_plural(adjective) <> " som vi."
    Equal -> "Han är lika " <> adjective <> " som du."
    Most -> "De är " <> superlative <> " av alla."
  }
}

/// The comparative and superlative: snabb, snabbare, snabbast. A few are
/// irregular (stor, större, störst), and some take mer and mest (mer
/// intressant, mer rosa).
pub fn compare(adjective: String) -> #(String, String) {
  case adjective {
    "bra" | "god" -> #("bättre", "bäst")
    "dålig" -> #("sämre", "sämst")
    "stor" -> #("större", "störst")
    "liten" -> #("mindre", "minst")
    "gammal" -> #("äldre", "äldst")
    "ung" -> #("yngre", "yngst")
    "lång" -> #("längre", "längst")
    "hög" -> #("högre", "högst")
    "låg" -> #("lägre", "lägst")
    "tung" -> #("tyngre", "tyngst")
    "trång" -> #("trängre", "trängst")
    // ancien means "före detta", but plus ancien is older.
    "före detta" -> #("äldre", "äldst")
    "blå" | "grå" -> #(adjective <> "are", adjective <> "ast")
    _ ->
      case takes_mer(adjective) {
        True -> #("mer " <> adjective, "mest " <> adjective)
        False -> {
          // The stem of the plural: vackra gives vackr-, tomma tomm-.
          let stem = string.drop_end(adjective_plural(adjective), 1)
          #(stem <> "are", stem <> "ast")
        }
      }
  }
}

fn takes_mer(adjective: String) -> Bool {
  ends_with_any(adjective, ["a", "e", "o", "isk"])
  || { string.ends_with(adjective, "ad") && string.length(adjective) > 5 }
  || list.contains(
    [
      "intelligent", "intressant", "utsökt", "känd", "modern", "svartsjuk",
      "likadan", "stängd", "möjlig", "omöjlig", "fel",
    ],
    adjective,
  )
}
