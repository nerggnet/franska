//// A2 vocabulary. Ids are stored with the learner's progress: never rename
//// or reuse one. Put the canonical translation first in `sv`.

import franska/lexicon.{
  type Entry, type Word, A2, Avoir, Entry, Etre, Expression, Feminine, Masculine,
  Negate, Present, Rewrite, Sentence, UsePronoun, Verb,
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
    phrase(
      "je-voudrais",
      "vardagsfraser",
      ["jag skulle vilja", "jag vill gärna"],
      [
        "je voudrais",
      ],
    ),
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
    // Fler verb
    verb(
      "vendre",
      ["sälja"],
      "vendre",
      #("vends", "vends", "vend", "vendons", "vendez", "vendent"),
      "vendu",
      Avoir,
    ),
    verb(
      "preferer",
      ["föredra"],
      "préférer",
      #("préfère", "préfères", "préfère", "préférons", "préférez", "préfèrent"),
      "préféré",
      Avoir,
    ),
    verb(
      "rentrer",
      ["komma hem", "gå hem", "åka hem"],
      "rentrer",
      #("rentre", "rentres", "rentre", "rentrons", "rentrez", "rentrent"),
      "rentré",
      Etre,
    ),
    // Reflexiva verb
    reflexive(
      "se-promener",
      ["promenera", "gå på promenad"],
      "promener",
      #("promène", "promènes", "promène", "promenons", "promenez", "promènent"),
      "promené",
    ),
    reflexive(
      "se-depecher",
      ["skynda sig"],
      "dépêcher",
      #("dépêche", "dépêches", "dépêche", "dépêchons", "dépêchez", "dépêchent"),
      "dépêché",
    ),
    reflexive(
      "s-amuser",
      ["ha roligt"],
      "amuser",
      #("amuse", "amuses", "amuse", "amusons", "amusez", "amusent"),
      "amusé",
    ),
    reflexive(
      "se-reposer",
      ["vila sig", "vila"],
      "reposer",
      #("repose", "reposes", "repose", "reposons", "reposez", "reposent"),
      "reposé",
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
      "blandat",
      "I morgon ska jag åka.",
      "Demain, je ___ partir.",
      ["vais"],
      "aller",
    ),
    sentence(
      "hier-nous-sommes-alles",
      "blandat",
      "I går åkte vi till stranden.",
      "Hier, nous ___ allés à la plage.",
      ["sommes"],
      "être",
    ),
    sentence(
      "j-ai-mange-une-pomme",
      "blandat",
      "Jag åt ett äpple.",
      "J'___ mangé une pomme.",
      ["ai"],
      "avoir",
    ),
    sentence(
      "elle-est-partie-hier-soir",
      "blandat",
      "Hon åkte i går kväll.",
      "Elle est ___ hier soir.",
      ["partie"],
      "partir",
    ),
    sentence(
      "ils-sont-sortis",
      "blandat",
      "De gick ut ur huset.",
      "Ils sont ___ de la maison.",
      ["sortis"],
      "sortir",
    ),
    sentence(
      "ils-ont-regarde-un-film",
      "blandat",
      "De tittade på en film.",
      "Ils ont ___ un film.",
      ["regardé"],
      "regarder",
    ),
    sentence(
      "je-lisais-beaucoup",
      "blandat",
      "När jag var liten läste jag mycket.",
      "Quand j'étais petit, je ___ beaucoup.",
      ["lisais"],
      "lire",
    ),
    sentence(
      "il-faisait-beau-hier",
      "blandat",
      "Det var fint väder i går.",
      "Il ___ beau hier.",
      ["faisait"],
      "faire",
    ),
    sentence(
      "nous-etions-a-la-maison",
      "blandat",
      "Vi var hemma.",
      "Nous ___ à la maison.",
      ["étions"],
      "être, imparfait",
    ),
    sentence(
      "je-ne-sais-pas-ou",
      "blandat",
      "Jag vet inte var han är.",
      "Je ne ___ pas où il est.",
      ["sais"],
      "savoir",
    ),
    sentence(
      "nous-attendons-le-train",
      "blandat",
      "Vi väntar på tåget.",
      "Nous ___ le train.",
      ["attendons"],
      "attendre",
    ),
    sentence(
      "tu-dois-mettre-ton-manteau",
      "blandat",
      "Du måste ta på dig kappan.",
      "Tu ___ mettre ton manteau.",
      ["dois"],
      "devoir",
    ),
    sentence(
      "je-vais-voir-mes-amis",
      "blandat",
      "Jag ska träffa mina vänner i kväll.",
      "Je vais ___ mes amis ce soir.",
      ["voir"],
      "voir",
    ),
    sentence(
      "elle-travaille-au-bureau",
      "blandat",
      "Hon arbetar på kontoret.",
      "Elle ___ au bureau.",
      ["travaille"],
      "travailler",
    ),
    sentence(
      "j-achete-un-billet",
      "blandat",
      "Jag köper en biljett till Lyon.",
      "J'___ un billet pour Lyon.",
      ["achète"],
      "acheter",
    ),
    sentence(
      "on-part-a-quelle-heure",
      "blandat",
      "Vilken tid åker vi?",
      "On ___ à quelle heure ?",
      ["part"],
      "partir",
    ),
    sentence(
      "partitiv-sucre",
      "partitiv",
      "Det finns inget socker kvar.",
      "Il n'y a plus ___ sucre.",
      ["de"],
      "du/de la/des/de",
    ),
    sentence(
      "possessiv-maison",
      "possessiv",
      "De tycker om sitt hus.",
      "Ils aiment ___ maison.",
      ["leur"],
      "deras",
    ),
    sentence(
      "possessiv-parents",
      "possessiv",
      "Vi träffar våra föräldrar.",
      "Nous voyons ___ parents.",
      ["nos"],
      "våra",
    ),
    sentence(
      "possessiv-cle",
      "possessiv",
      "Var är hans nyckel?",
      "Où est ___ clé ?",
      ["sa"],
      "hans",
    ),
    sentence(
      "possessiv-billets",
      "possessiv",
      "Har ni era biljetter?",
      "Vous avez ___ billets ?",
      ["vos"],
      "era",
    ),
    sentence(
      "negation-jamais",
      "negation",
      "Jag äter aldrig kött.",
      "Je ne mange ___ de viande.",
      ["jamais"],
      "aldrig",
    ),
    sentence(
      "negation-plus",
      "negation",
      "Han bor inte här längre.",
      "Il n'habite ___ ici.",
      ["plus"],
      "inte längre",
    ),
    sentence(
      "negation-rien",
      "negation",
      "Vi ser ingenting.",
      "Nous ne voyons ___.",
      ["rien"],
      "ingenting",
    ),
    sentence(
      "negation-personne",
      "negation",
      "Hon känner ingen.",
      "Elle ne connaît ___.",
      ["personne"],
      "ingen",
    ),
    // Negation
    negate(
      "neg-je-suis-alle",
      "Jag gick inte på bio.",
      "Je suis allé au cinéma.",
      ["Je ne suis pas allé au cinéma."],
    ),
    negate("neg-elle-a-mange", "Hon har inte ätit.", "Elle a mangé.", [
      "Elle n'a pas mangé.",
    ]),
    negate("neg-je-vais-partir", "Jag ska inte åka.", "Je vais partir.", [
      "Je ne vais pas partir.",
    ]),
    negate("neg-il-se-leve", "Han går inte upp tidigt.", "Il se lève tôt.", [
      "Il ne se lève pas tôt.",
    ]),
    negate("neg-nous-avons", "Vi har inga barn.", "Nous avons des enfants.", [
      "Nous n'avons pas d'enfants.",
    ]),
    negate("neg-vous-voulez", "Vill ni inte ha te?", "Vous voulez du thé ?", [
      "Vous ne voulez pas de thé ?",
    ]),
    sentence(
      "pronomen-le",
      "pronomen",
      "Känner du Paul? Ja, jag känner honom.",
      "Tu connais Paul ? Oui, je ___ connais.",
      ["le"],
      "honom",
    ),
    sentence(
      "pronomen-y",
      "pronomen",
      "Ska du till marknaden? Ja, jag ska dit.",
      "Tu vas au marché ? Oui, j'___ vais.",
      ["y"],
      "dit",
    ),
    sentence(
      "pronomen-en",
      "pronomen",
      "Har du bröder? Ja, jag har två.",
      "Tu as des frères ? Oui, j'___ ai deux.",
      ["en"],
      "",
    ),
    sentence(
      "pronomen-lui",
      "pronomen",
      "Pratar du med din mamma? Ja, jag pratar med henne.",
      "Tu parles à ta mère ? Oui, je ___ parle.",
      ["lui"],
      "med henne",
    ),
    sentence(
      "pronomen-les",
      "pronomen",
      "Träffar ni era vänner? Ja, vi träffar dem.",
      "Vous voyez vos amis ? Oui, nous ___ voyons.",
      ["les"],
      "dem",
    ),
    sentence(
      "pronomen-leur",
      "pronomen",
      "Skriver du till dina föräldrar? Ja, jag skriver till dem.",
      "Tu écris à tes parents ? Oui, je ___ écris.",
      ["leur"],
      "till dem",
    ),
    sentence(
      "jamforelse-mieux-chante",
      "jämförelse",
      "Hon sjunger bättre än jag.",
      "Elle chante ___ que moi.",
      ["mieux"],
      "bien, mer",
    ),
    sentence(
      "jamforelse-mieux-parle",
      "jämförelse",
      "Han talar franska bättre än sin bror.",
      "Il parle français ___ que son frère.",
      ["mieux"],
      "bien, mer",
    ),
    sentence(
      "jamforelse-ville",
      "jämförelse",
      "Det är den vackraste staden i Frankrike.",
      "C'est la ville la ___ belle de France.",
      ["plus"],
      "mest",
    ),
    sentence(
      "jamforelse-film",
      "jämförelse",
      "Det är årets bästa film.",
      "C'est ___ film de l'année.",
      ["le meilleur"],
      "bon, mest",
    ),
    sentence(
      "jamforelse-que",
      "jämförelse",
      "Paris är större än Lyon.",
      "Paris est plus grand ___ Lyon.",
      ["que"],
      "",
    ),
    sentence(
      "jamforelse-aussi-que",
      "jämförelse",
      "Marie är lika lång som sin syster.",
      "Marie est aussi grande ___ sa sœur.",
      ["que"],
      "",
    ),
    sentence(
      "futur-il-fera-beau",
      "futur",
      "I morgon blir det fint väder.",
      "Demain, il ___ beau.",
      ["fera"],
      "faire",
    ),
    sentence(
      "futur-nous-irons",
      "futur",
      "Nästa år åker vi till Frankrike.",
      "L'année prochaine, nous ___ en France.",
      ["irons"],
      "aller",
    ),
    sentence(
      "futur-je-t-appellerai",
      "futur",
      "Jag ringer dig i morgon.",
      "Je t'___ demain.",
      ["appellerai"],
      "appeler",
    ),
    sentence(
      "futur-tu-seras",
      "futur",
      "När du blir stor kommer du att förstå.",
      "Quand tu ___ grand, tu comprendras.",
      ["seras"],
      "être",
    ),
    sentence(
      "konditionalis-cafe",
      "konditionalis",
      "Jag skulle vilja ha en kaffe, tack.",
      "Je ___ un café, s'il vous plaît.",
      ["voudrais"],
      "vouloir",
    ),
    sentence(
      "konditionalis-pourriez",
      "konditionalis",
      "Skulle ni kunna hjälpa mig?",
      "Vous ___ m'aider ?",
      ["pourriez"],
      "pouvoir",
    ),
    sentence(
      "konditionalis-pourrais",
      "konditionalis",
      "Skulle du kunna följa med oss?",
      "Tu ___ venir avec nous ?",
      ["pourrais"],
      "pouvoir",
    ),
    sentence(
      "konditionalis-si-argent",
      "konditionalis",
      "Om jag hade pengar skulle jag köpa ett hus.",
      "Si j'avais de l'argent, j'___ une maison.",
      ["achèterais"],
      "acheter",
    ),
    sentence(
      "konditionalis-a-ta-place",
      "konditionalis",
      "I ditt ställe skulle jag ta tåget.",
      "À ta place, je ___ le train.",
      ["prendrais"],
      "prendre",
    ),
    // Pronomen
    pronoun("pron-je-vois-marie", "Jag ser henne.", "Je vois [Marie].", [
      "Je la vois.",
    ]),
    pronoun("pron-il-mange-gateau", "Han äter den.", "Il mange [le gâteau].", [
      "Il le mange.",
    ]),
    pronoun(
      "pron-nous-regardons-photos",
      "Vi tittar på dem.",
      "Nous regardons [les photos].",
      ["Nous les regardons."],
    ),
    pronoun("pron-tu-aimes-film", "Tycker du om den?", "Tu aimes [ce film] ?", [
      "Tu l'aimes ?",
    ]),
    pronoun(
      "pron-j-attends-train",
      "Jag väntar på det.",
      "J'attends [le train].",
      ["Je l'attends."],
    ),
    pronoun(
      "pron-elle-cherche-cles",
      "Hon letar efter dem.",
      "Elle cherche [ses clés].",
      ["Elle les cherche."],
    ),
    pronoun(
      "pron-je-parle-paul",
      "Jag pratar med honom.",
      "Je parle [à Paul].",
      ["Je lui parle."],
    ),
    pronoun(
      "pron-elle-telephone-mere",
      "Hon ringer till henne.",
      "Elle téléphone [à sa mère].",
      ["Elle lui téléphone."],
    ),
    pronoun(
      "pron-nous-donnons-amis",
      "Vi ger dem en present.",
      "Nous donnons un cadeau [à nos amis].",
      ["Nous leur donnons un cadeau."],
    ),
    pronoun(
      "pron-tu-reponds-professeur",
      "Svarar du honom?",
      "Tu réponds [au professeur] ?",
      ["Tu lui réponds ?"],
    ),
    pronoun("pron-je-vais-paris", "Jag åker dit.", "Je vais [à Paris].", [
      "J'y vais.",
    ]),
    pronoun(
      "pron-elle-habite-france",
      "Hon bor där.",
      "Elle habite [en France].",
      ["Elle y habite."],
    ),
    pronoun(
      "pron-je-mange-soupe",
      "Jag äter av den.",
      "Je mange [de la soupe].",
      ["J'en mange."],
    ),
    pronoun("pron-il-a-enfants", "Han har tre.", "Il a [trois enfants].", [
      "Il en a trois.",
    ]),
    pronoun(
      "pron-nous-voulons-cafe",
      "Vi vill ha lite.",
      "Nous voulons [du café].",
      ["Nous en voulons."],
    ),
    pronoun(
      "pron-je-ne-vois-pas-marie",
      "Jag ser henne inte.",
      "Je ne vois pas [Marie].",
      ["Je ne la vois pas."],
    ),
    pronoun("pron-j-ai-vu-film", "Jag har sett den.", "J'ai vu [le film].", [
      "Je l'ai vu.",
    ]),
    pronoun(
      "pron-je-vais-acheter-pain",
      "Jag ska köpa det.",
      "Je vais acheter [le pain].",
      ["Je vais l'acheter."],
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
      reflexive: False,
    ),
  )
}

/// A sentence with a `___` gap, its Swedish translation, the accepted
/// answers for the gap and a hint ("" for none).
fn sentence(id, theme, sv, text, answers, hint) -> Entry {
  entry(id, theme, [sv], Sentence(text:, answers:, hint:))
}

fn adjective(id, theme, sv, masculine, feminine) -> Entry {
  entry(id, theme, sv, lexicon.adjective(masculine, feminine))
}

/// A reflexive verb, given without its pronoun ("lever" for se lever). It
/// takes être in the passé composé.
fn reflexive(id, sv, infinitive, forms, participle) -> Entry {
  let #(je, tu, il, nous, vous, ils) = forms
  entry(
    id,
    "verb",
    sv,
    Verb(
      infinitive:,
      present: Present(je:, tu:, il:, nous:, vous:, ils:),
      participle:,
      auxiliary: Etre,
      reflexive: True,
    ),
  )
}

/// A sentence to make negative, the Swedish meaning of the negative one and
/// the accepted negative sentences.
fn negate(id, sv, source, answers) -> Entry {
  entry(id, "negation", [sv], Rewrite(task: Negate, source:, answers:))
}

/// A sentence whose [marked] part is to be replaced by a pronoun, the
/// Swedish meaning of the answer and the accepted answers.
fn pronoun(id, sv, source, answers) -> Entry {
  entry(id, "pronomen", [sv], Rewrite(task: UsePronoun, source:, answers:))
}
