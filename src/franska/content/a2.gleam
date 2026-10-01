//// A2 vocabulary. Ids are stored with the learner's progress: never rename
//// or reuse one. Put the canonical translation first in `sv`.

import franska/lexicon.{
  type Entry, type Word, A2, Avoir, Entry, Etre, Expression, Feminine, Masculine,
  Present, Sentence, Verb,
}

pub fn entries() -> List(Entry) {
  [
    // Vardagsfraser
    phrase("je-ne-sais-pas", "vardagsfraser", ["jag vet inte"], [
      "je ne sais pas", "je sais pas",
    ]),
    phrase("je-ne-comprends-pas", "vardagsfraser", ["jag förstår inte"], [
      "je ne comprends pas", "je comprends pas",
    ]),
    phrase(
      "pouvez-vous-repeter",
      "vardagsfraser",
      ["kan du upprepa?", "kan ni upprepa?"],
      ["pouvez-vous répéter ?", "vous pouvez répéter ?", "tu peux répéter ?"],
    ),
    phrase("combien-ca-coute", "vardagsfraser", ["vad kostar det?"], [
      "combien ça coûte ?", "ça coûte combien ?", "c'est combien ?",
    ]),
    phrase("quelle-heure-est-il", "vardagsfraser", ["vad är klockan?"], [
      "quelle heure est-il ?", "il est quelle heure ?",
    ]),
    phrase("j-ai-faim", "vardagsfraser", ["jag är hungrig"], ["j'ai faim"]),
    phrase("j-ai-soif", "vardagsfraser", ["jag är törstig"], ["j'ai soif"]),
    phrase("j-ai-froid", "vardagsfraser", ["jag fryser"], ["j'ai froid"]),
    phrase("d-accord", "vardagsfraser", ["okej", "ok", "visst"], ["d'accord"]),
    phrase("de-rien", "vardagsfraser", ["ingen orsak", "varsågod"], [
      "de rien",
    ]),
    phrase("bon-appetit", "vardagsfraser", ["smaklig måltid"], [
      "bon appétit",
    ]),
    phrase("a-bientot", "vardagsfraser", ["vi ses snart", "på återseende"], [
      "à bientôt",
    ]),
    // Tid
    phrase("aujourd-hui", "tid", ["i dag", "idag"], ["aujourd'hui"]),
    phrase("demain", "tid", ["i morgon", "imorgon"], ["demain"]),
    phrase("hier", "tid", ["i går", "igår"], ["hier"]),
    phrase("maintenant", "tid", ["nu"], ["maintenant"]),
    phrase("toujours", "tid", ["alltid", "fortfarande"], ["toujours"]),
    phrase("souvent", "tid", ["ofta"], ["souvent"]),
    noun("jour", "tid", "jour", Masculine, ["dag"]),
    noun("semaine", "tid", "semaine", Feminine, ["vecka"]),
    noun("mois", "tid", "mois", Masculine, ["månad"]),
    noun("annee", "tid", "année", Feminine, ["år"]),
    noun("heure", "tid", "heure", Feminine, ["timme"]),
    noun("matin", "tid", "matin", Masculine, ["morgon", "förmiddag"]),
    noun("soir", "tid", "soir", Masculine, ["kväll"]),
    // Väder och natur
    phrase(
      "il-fait-beau",
      "väder",
      ["det är fint väder", "det är vackert väder"],
      ["il fait beau"],
    ),
    phrase("il-pleut", "väder", ["det regnar"], ["il pleut"]),
    phrase("il-fait-froid", "väder", ["det är kallt"], ["il fait froid"]),
    phrase("il-fait-chaud", "väder", ["det är varmt"], ["il fait chaud"]),
    noun("soleil", "väder", "soleil", Masculine, ["sol"]),
    noun("pluie", "väder", "pluie", Feminine, ["regn"]),
    noun("neige", "väder", "neige", Feminine, ["snö"]),
    noun("vent", "väder", "vent", Masculine, ["vind", "blåst"]),
    noun("nuage", "väder", "nuage", Masculine, ["moln"]),
    noun("mer", "väder", "mer", Feminine, ["hav"]),
    noun("montagne", "väder", "montagne", Feminine, ["berg"]),
    noun("arbre", "väder", "arbre", Masculine, ["träd"]),
    noun("fleur", "väder", "fleur", Feminine, ["blomma"]),
    // Kläder
    noun("chemise", "kläder", "chemise", Feminine, ["skjorta"]),
    noun("pantalon", "kläder", "pantalon", Masculine, ["byxor", "byxa"]),
    noun("robe", "kläder", "robe", Feminine, ["klänning"]),
    noun("jupe", "kläder", "jupe", Feminine, ["kjol"]),
    noun("chaussure", "kläder", "chaussure", Feminine, ["sko"]),
    noun("manteau", "kläder", "manteau", Masculine, ["kappa", "rock"]),
    noun("veste", "kläder", "veste", Feminine, ["jacka", "kavaj"]),
    noun("chapeau", "kläder", "chapeau", Masculine, ["hatt"]),
    // Kroppen
    noun("tete", "kroppen", "tête", Feminine, ["huvud"]),
    noun("main", "kroppen", "main", Feminine, ["hand"]),
    noun("bras", "kroppen", "bras", Masculine, ["arm"]),
    noun("jambe", "kroppen", "jambe", Feminine, ["ben"]),
    noun("pied", "kroppen", "pied", Masculine, ["fot"]),
    noun("oeil", "kroppen", "œil", Masculine, ["öga"]),
    noun("bouche", "kroppen", "bouche", Feminine, ["mun"]),
    noun("dos", "kroppen", "dos", Masculine, ["rygg"]),
    noun("coeur", "kroppen", "cœur", Masculine, ["hjärta"]),
    // Resor
    noun("voyage", "resor", "voyage", Masculine, ["resa"]),
    noun("avion", "resor", "avion", Masculine, ["flygplan", "plan"]),
    noun("train", "resor", "train", Masculine, ["tåg"]),
    noun("billet", "resor", "billet", Masculine, ["biljett"]),
    noun("valise", "resor", "valise", Feminine, ["resväska", "väska"]),
    noun("hotel", "resor", "hôtel", Masculine, ["hotell"]),
    noun("plage", "resor", "plage", Feminine, ["strand"]),
    noun("pays", "resor", "pays", Masculine, ["land"]),
    noun("cle", "resor", "clé", Feminine, ["nyckel"]),
    // Arbete
    noun("travail", "arbete", "travail", Masculine, ["arbete", "jobb"]),
    noun("bureau", "arbete", "bureau", Masculine, ["kontor", "skrivbord"]),
    noun("argent", "arbete", "argent", Masculine, ["pengar"]),
    noun("medecin", "arbete", "médecin", Masculine, ["läkare"]),
    noun("professeur", "arbete", "professeur", Masculine, ["lärare"]),
    noun("ordinateur", "arbete", "ordinateur", Masculine, ["dator"]),
    noun("reunion", "arbete", "réunion", Feminine, ["möte"]),
    // Fler verb
    verb(
      "venir",
      ["komma"],
      "venir",
      #("viens", "viens", "vient", "venons", "venez", "viennent"),
      "venu",
      Etre,
    ),
    verb(
      "voir",
      ["se"],
      "voir",
      #("vois", "vois", "voit", "voyons", "voyez", "voient"),
      "vu",
      Avoir,
    ),
    verb(
      "savoir",
      ["veta", "kunna"],
      "savoir",
      #("sais", "sais", "sait", "savons", "savez", "savent"),
      "su",
      Avoir,
    ),
    verb(
      "dire",
      ["säga"],
      "dire",
      #("dis", "dis", "dit", "disons", "dites", "disent"),
      "dit",
      Avoir,
    ),
    verb(
      "mettre",
      ["sätta", "lägga", "ställa", "ta på sig"],
      "mettre",
      #("mets", "mets", "met", "mettons", "mettez", "mettent"),
      "mis",
      Avoir,
    ),
    verb(
      "partir",
      ["åka iväg", "ge sig av", "gå"],
      "partir",
      #("pars", "pars", "part", "partons", "partez", "partent"),
      "parti",
      Etre,
    ),
    verb(
      "sortir",
      ["gå ut"],
      "sortir",
      #("sors", "sors", "sort", "sortons", "sortez", "sortent"),
      "sorti",
      Etre,
    ),
    verb(
      "dormir",
      ["sova"],
      "dormir",
      #("dors", "dors", "dort", "dormons", "dormez", "dorment"),
      "dormi",
      Avoir,
    ),
    verb(
      "lire",
      ["läsa"],
      "lire",
      #("lis", "lis", "lit", "lisons", "lisez", "lisent"),
      "lu",
      Avoir,
    ),
    verb(
      "ecrire",
      ["skriva"],
      "écrire",
      #("écris", "écris", "écrit", "écrivons", "écrivez", "écrivent"),
      "écrit",
      Avoir,
    ),
    verb(
      "finir",
      ["avsluta", "bli klar", "sluta"],
      "finir",
      #("finis", "finis", "finit", "finissons", "finissez", "finissent"),
      "fini",
      Avoir,
    ),
    verb(
      "acheter",
      ["köpa"],
      "acheter",
      #("achète", "achètes", "achète", "achetons", "achetez", "achètent"),
      "acheté",
      Avoir,
    ),
    verb(
      "appeler",
      ["ringa", "kalla"],
      "appeler",
      #("appelle", "appelles", "appelle", "appelons", "appelez", "appellent"),
      "appelé",
      Avoir,
    ),
    verb(
      "attendre",
      ["vänta", "vänta på"],
      "attendre",
      #("attends", "attends", "attend", "attendons", "attendez", "attendent"),
      "attendu",
      Avoir,
    ),
    verb(
      "comprendre",
      ["förstå"],
      "comprendre",
      #(
        "comprends",
        "comprends",
        "comprend",
        "comprenons",
        "comprenez",
        "comprennent",
      ),
      "compris",
      Avoir,
    ),
    verb(
      "connaitre",
      ["känna", "känna till"],
      "connaître",
      #(
        "connais",
        "connais",
        "connaît",
        "connaissons",
        "connaissez",
        "connaissent",
      ),
      "connu",
      Avoir,
    ),
    verb(
      "devoir",
      ["måste", "vara tvungen"],
      "devoir",
      #("dois", "dois", "doit", "devons", "devez", "doivent"),
      "dû",
      Avoir,
    ),
    verb(
      "travailler",
      ["arbeta", "jobba"],
      "travailler",
      #(
        "travaille",
        "travailles",
        "travaille",
        "travaillons",
        "travaillez",
        "travaillent",
      ),
      "travaillé",
      Avoir,
    ),
    verb(
      "regarder",
      ["titta på", "titta", "se på"],
      "regarder",
      #("regarde", "regardes", "regarde", "regardons", "regardez", "regardent"),
      "regardé",
      Avoir,
    ),
    verb(
      "ecouter",
      ["lyssna", "lyssna på"],
      "écouter",
      #("écoute", "écoutes", "écoute", "écoutons", "écoutez", "écoutent"),
      "écouté",
      Avoir,
    ),
    // Adjektiv
    adjective("heureux", "egenskaper", ["lycklig"], "heureux", "heureuse"),
    adjective("triste", "egenskaper", ["ledsen"], "triste", "triste"),
    adjective("important", "egenskaper", ["viktig"], "important", "importante"),
    adjective("libre", "egenskaper", ["fri", "ledig"], "libre", "libre"),
    adjective("plein", "egenskaper", ["full"], "plein", "pleine"),
    adjective("vide", "egenskaper", ["tom"], "vide", "vide"),
    adjective("rapide", "egenskaper", ["snabb"], "rapide", "rapide"),
    adjective("lent", "egenskaper", ["långsam"], "lent", "lente"),
    adjective("propre", "egenskaper", ["ren"], "propre", "propre"),
    adjective("sale", "egenskaper", ["smutsig"], "sale", "sale"),
    adjective("fort", "egenskaper", ["stark"], "fort", "forte"),
    adjective("malade", "egenskaper", ["sjuk"], "malade", "malade"),
    adjective("pret", "egenskaper", ["redo", "klar"], "prêt", "prête"),
    adjective("gros", "egenskaper", ["tjock"], "gros", "grosse"),
    // Meningar
    sentence(
      "demain-je-vais-partir",
      "I morgon ska jag åka.",
      "Demain, je ___ partir.",
      ["vais"],
      "aller",
    ),
    sentence(
      "hier-nous-sommes-alles",
      "I går åkte vi till stranden.",
      "Hier, nous ___ allés à la plage.",
      ["sommes"],
      "être",
    ),
    sentence(
      "j-ai-mange-une-pomme",
      "Jag åt ett äpple.",
      "J'___ mangé une pomme.",
      ["ai"],
      "avoir",
    ),
    sentence(
      "elle-est-partie-hier-soir",
      "Hon åkte i går kväll.",
      "Elle est ___ hier soir.",
      ["partie"],
      "partir",
    ),
    sentence(
      "ils-sont-sortis",
      "De gick ut ur huset.",
      "Ils sont ___ de la maison.",
      ["sortis"],
      "sortir",
    ),
    sentence(
      "ils-ont-regarde-un-film",
      "De tittade på en film.",
      "Ils ont ___ un film.",
      ["regardé"],
      "regarder",
    ),
    sentence(
      "je-lisais-beaucoup",
      "När jag var liten läste jag mycket.",
      "Quand j'étais petit, je ___ beaucoup.",
      ["lisais"],
      "lire",
    ),
    sentence(
      "il-faisait-beau-hier",
      "Det var fint väder i går.",
      "Il ___ beau hier.",
      ["faisait"],
      "faire",
    ),
    sentence(
      "nous-etions-a-la-maison",
      "Vi var hemma.",
      "Nous ___ à la maison.",
      ["étions"],
      "être, imparfait",
    ),
    sentence(
      "je-ne-sais-pas-ou",
      "Jag vet inte var han är.",
      "Je ne ___ pas où il est.",
      ["sais"],
      "savoir",
    ),
    sentence(
      "nous-attendons-le-train",
      "Vi väntar på tåget.",
      "Nous ___ le train.",
      ["attendons"],
      "attendre",
    ),
    sentence(
      "tu-dois-mettre-ton-manteau",
      "Du måste ta på dig kappan.",
      "Tu ___ mettre ton manteau.",
      ["dois"],
      "devoir",
    ),
    sentence(
      "je-vais-voir-mes-amis",
      "Jag ska träffa mina vänner i kväll.",
      "Je vais ___ mes amis ce soir.",
      ["voir"],
      "voir",
    ),
    sentence(
      "elle-travaille-au-bureau",
      "Hon arbetar på kontoret.",
      "Elle ___ au bureau.",
      ["travaille"],
      "travailler",
    ),
    sentence(
      "j-achete-un-billet",
      "Jag köper en biljett till Lyon.",
      "J'___ un billet pour Lyon.",
      ["achète"],
      "acheter",
    ),
    sentence(
      "on-part-a-quelle-heure",
      "Vilken tid åker vi?",
      "On ___ à quelle heure ?",
      ["part"],
      "partir",
    ),
  ]
}

fn entry(id: String, theme: String, sv: List(String), word: Word) -> Entry {
  Entry(id:, level: A2, theme:, sv:, word:)
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

fn adjective(id, theme, sv, masculine, feminine) -> Entry {
  entry(id, theme, sv, lexicon.adjective(masculine, feminine))
}
