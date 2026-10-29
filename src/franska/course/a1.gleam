//// The A1 lessons of the course, in order. Lesson ids are stored with the
//// learner's progress: never rename or reuse one.

import franska/course/lesson.{
  type Lesson, Lesson, conjugation, numbers, sentences, texts, verbs, words,
}
import franska/lexicon.{A1}

pub fn lessons() -> List(Lesson) {
  [
    Lesson(
      level: A1,
      id: "a1-hej",
      title: "Hej och hej då",
      topic: "Hälsningar, tu och vous, talen 0–10",
      note: [
        "Bonjour betyder god dag och passar hela dagen, till alla. På kvällen säger man bonsoir. Salut (hej, tjena) säger man bara till vänner.",
        "Franskan skiljer på tu och vous. Tu säger man till en vän, ett barn eller någon i familjen, vous till en vuxen man inte känner, och alltid till flera personer: Comment vas-tu ? men Comment allez-vous ?",
        "Konsonanter i slutet av ett ord hörs oftast inte: i vous hörs inget s, i plaît inget t och i beaucoup inget p.",
        "Accenterna (é, è, ê, à, ç …) hör till stavningen. Knapparna under svarsrutan skriver dem åt dig.",
        "Talen 0–10:\nzéro, un, deux, trois, quatre, cinq\nsix, sept, huit, neuf, dix",
      ],
      parts: [
        words([
          "bonjour", "bonsoir", "bonne-nuit", "salut", "au-revoir", "merci",
          "merci-beaucoup", "s-il-vous-plait", "excusez-moi", "oui", "non",
          "comment-ca-va", "je-m-appelle", "enchante", "bonne-journee",
          "a-demain", "a-plus-tard",
        ]),
        sentences(["et-toi"]),
        numbers(0, 10),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-vem-ar-du",
      title: "Vem är du?",
      topic: "Pronomen, être, länder och nationaliteter",
      note: [
        "Personliga pronomen: je (jag), tu (du), il (han), elle (hon), on (man, vi), nous (vi), vous (ni), ils (de, om män eller en blandad grupp), elles (de, om bara kvinnor).",
        "Être (vara) är oregelbundet och måste läras utantill:\nje suis · tu es · il/elle est\nnous sommes · vous êtes · ils/elles sont",
        "Nationaliteter skrivs med liten bokstav och böjs efter den det gäller. En kvinna får oftast ett -e: il est suédois, elle est suédoise. Några ändras mer: italien – italienne, norvégien – norvégienne.",
        "Länder har genus: la France, la Suède, le Canada. I eller till ett land heter en framför feminina länder (en France, en Suède) och au framför maskulina (au Canada).",
      ],
      parts: [
        verbs(["etre"]),
        words([
          "suede", "france", "allemagne", "espagne", "italie", "angleterre",
          "norvege", "danemark", "finlande", "canada", "belgique", "suisse",
          "suedois", "francais", "anglais", "allemand", "espagnol", "italien",
          "americain", "norvegien", "danois", "finlandais",
        ]),
        sentences(["je-suis-suedois", "presens-etes-d-ou"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-familjen",
      title: "Familjen",
      topic: "avoir, le och la, un och une, talen 11–20",
      note: [
        "Alla substantiv är maskulina eller feminina. Bestämd artikel är le framför maskulina ord och la framför feminina, l' framför vokal eller stumt h (l'enfant, l'homme) och les i plural. Obestämd artikel är un, une och des.",
        "Lär dig orden med artikel, så lär du dig genus på köpet: la mère, le père. Efter l' syns inte genus, så lär dig un ami och une amie.",
        "Avoir (ha) är oregelbundet:\nj'ai · tu as · il/elle a\nnous avons · vous avez · ils/elles ont",
        "Ålder anges med avoir: J'ai vingt ans (jag är tjugo år). Tu as quel âge ?",
        "Talen 11–20:\nonze, douze, treize, quatorze, quinze\nseize, dix-sept, dix-huit, dix-neuf, vingt",
      ],
      parts: [
        verbs(["avoir"]),
        words([
          "mere", "pere", "frere", "soeur", "fils", "fille", "enfant", "ami",
          "homme", "femme", "mari", "grand-pere", "grand-mere", "bebe",
          "parents", "famille",
        ]),
        sentences([
          "artikel-un-chat", "artikel-une-voiture", "artikel-les-enfants",
          "artikel-des-livres", "artikel-le-soleil", "artikel-la-musique",
          "artikel-l-ecole", "artikel-un-homme", "vous-avez-quel-age",
          "presens-as-age", "j-ai-vingt-ans",
        ]),
        texts(["text-lea"]),
        numbers(11, 20),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-mitt-och-ditt",
      title: "Mitt och ditt",
      topic: "mon, ma och mes, c'est, talen 21–30",
      note: [
        "Possessiva pronomen böjs efter det man äger, inte efter den som äger:\nmon frère · ma mère · mes parents (min, mitt, mina)\nton frère · ta mère · tes parents (din, ditt, dina)\nson frère · sa mère · ses parents (hans, hennes, sin)",
        "Framför vokal blir ma, ta och sa till mon, ton och son, så att det låter bättre: mon école, mon amie.",
        "C'est betyder det är eller det här är: C'est mon frère. Voilà betyder där är eller varsågod: Voilà ma maison.",
        "Talen 21–30: vingt et un, vingt-deux, vingt-trois … vingt-neuf, trente. Ettan binds med et (21, 31, 41 …), de andra med bindestreck.",
      ],
      parts: [
        words([
          "tante", "oncle", "cousin", "garcon", "voisin", "prenom", "nom",
          "adresse", "age", "dame", "monsieur", "c-est", "voila",
        ]),
        sentences([
          "possessiv-frere", "possessiv-mere", "possessiv-amis",
          "possessiv-voiture", "possessiv-ecole", "c-est-mon-frere",
          "c-est-le-livre-de-paul",
        ]),
        texts(["text-ma-famille"]),
        numbers(21, 30),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-hemma",
      title: "Hemma",
      topic: "il y a, var saker är",
      note: [
        "Il y a betyder det finns: Il y a une table dans la cuisine. Det ändras inte i plural: Il y a deux chambres.",
        "Var något är: dans (i), sur (på), sous (under), devant (framför), derrière (bakom), entre (mellan), chez (hos), à côté de (bredvid), près de (nära), loin de (långt från).",
        "De i à côté de, près de och loin de slås ihop med le och les: à côté du lit, près des fenêtres. Med la och l' ändras inget: à côté de la porte.",
      ],
      parts: [
        words([
          "maison", "appartement", "chambre", "cuisine", "salon",
          "salle-de-bain", "jardin", "table", "chaise", "lit", "porte",
          "fenetre", "livre", "il-y-a", "dans", "sur", "sous", "devant",
          "derriere", "entre", "a-cote-de", "pres-de", "loin-de", "chez",
        ]),
        sentences([
          "prep-sous", "prep-sur", "prep-dans", "prep-a-cote-de", "prep-chez",
          "prep-derriere", "il-y-a-parc", "la-maison-est-grande",
        ]),
        texts(["text-mon-appartement"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-fritid",
      title: "Fritid",
      topic: "Verb på -er i presens",
      note: [
        "De flesta franska verb slutar på -er och böjs på samma sätt. Ta bort -er och lägg till ändelserna:\nje parle · tu parles · il/elle parle\nnous parlons · vous parlez · ils/elles parlent",
        "Ändelserna -e, -es och -ent hörs inte, så je parle, tu parles, il parle och ils parlent låter likadant.",
        "Je blir j' framför vokal och stumt h: j'aime, j'habite.",
        "Efter aimer får substantivet bestämd artikel, även när svenskan saknar artikel: J'aime le sport (jag tycker om sport).",
      ],
      parts: [
        verbs(["parler", "aimer", "habiter", "jouer", "chanter", "danser"]),
        words([
          "sport", "musique", "film", "chanson", "jeu", "fete", "football",
          "photo", "velo",
        ]),
        sentences([
          "nous-habitons-a-paris", "ils-parlent-francais",
          "presens-habitent-marseille", "j-aime-le-pain",
        ]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-mat",
      title: "Mat och dryck",
      topic: "du, de la och des, boire och prendre",
      note: [
        "När man talar om en obestämd mängd av något använder franskan partitiv artikel: du (de + le), de la, de l' och des. Je mange du pain. Elle boit de l'eau. På svenska blir det ingen artikel alls: jag äter bröd.",
        "Efter en negation blir det bara de (d' framför vokal): Je ne mange pas de viande.",
        "Manger behåller e:et framför -ons, så att g:et låter mjukt: nous mangeons.",
        "Boire (dricka) och prendre (ta) är oregelbundna:\nje bois · tu bois · il boit · nous buvons · vous buvez · ils boivent\nje prends · tu prends · il prend · nous prenons · vous prenez · ils prennent",
      ],
      parts: [
        verbs(["manger", "boire", "prendre"]),
        words([
          "pain", "eau", "lait", "fromage", "beurre", "oeuf", "viande",
          "poisson", "pomme", "cafe", "the", "vin", "sucre", "sel", "riz",
          "soupe", "biere", "jus",
        ]),
        sentences([
          "partitiv-pain", "partitiv-fromage", "partitiv-soupe", "partitiv-eau",
          "partitiv-pommes", "partitiv-lait", "partitiv-negation",
          "nous-mangeons-une-pizza", "presens-boit-cafe",
          "presens-prends-sandwich",
        ]),
        texts(["text-au-cafe"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-nej",
      title: "Nej!",
      topic: "Negation med ne … pas",
      note: [
        "Negationen har två delar som ställs runt verbet: Je ne parle pas anglais. Ne blir n' framför vokal: Il n'aime pas le café.",
        "Un, une, des och du, de la blir de efter negationen: J'ai une voiture – Je n'ai pas de voiture. Bestämd artikel ändras inte: Je n'aime pas le sport.",
        "Andra negationer fungerar likadant: ne … jamais (aldrig), ne … rien (ingenting), ne … personne (ingen). Il ne mange jamais de viande.",
        "I talspråk faller ne ofta bort (je sais pas), men i skrift ska det vara med.",
      ],
      parts: [
        sentences([
          "neg-je-parle", "neg-il-aime", "neg-nous-habitons", "neg-elle-est",
          "neg-tu-as", "neg-ils-mangent", "neg-c-est", "neg-je-comprends",
          "neg-suis-fatigue", "neg-parle-anglais", "neg-avons-voiture",
          "neg-aime-sport", "neg-habites-ici", "neg-boivent-cafe",
          "neg-mon-livre", "neg-veux-chien",
        ]),
        words([
          "et", "ou", "mais", "aussi", "tres", "beaucoup", "bien", "un-peu",
          "trop", "jamais", "rien", "personne",
        ]),
        verbs(["chercher", "trouver"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-staden",
      title: "I staden",
      topic: "aller, au och à la",
      note: [
        "Aller (gå, åka) är oregelbundet:\nje vais · tu vas · il/elle va\nnous allons · vous allez · ils/elles vont",
        "À (till, i, på) slås ihop med le och les:\nà + le = au: Je vais au cinéma.\nà + les = aux: Il parle aux enfants.\nMed la och l' ändras inget: à la gare, à l'école.",
        "Samma sak med de (från, av): de + le = du och de + les = des. Le livre du professeur.",
        "Med fordon säger man oftast en: en bus, en voiture, en métro. Men till fots heter à pied.",
      ],
      parts: [
        verbs(["aller"]),
        words([
          "ville", "rue", "ecole", "gare", "voiture", "magasin", "eglise",
          "banque", "poste", "marche", "musee", "parc", "pharmacie", "hopital",
          "boulangerie", "restaurant", "cinema", "bus", "metro", "taxi",
        ]),
        sentences([
          "il-va-au-cinema", "elles-vont-au-restaurant", "presens-vais-travail",
          "a-de-au-cinema", "a-de-a-la-piscine", "a-de-aux-enfants",
          "a-de-du-professeur", "a-de-de-l-ecole",
        ]),
        texts(["text-a-la-gare"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-fragor",
      title: "Frågor",
      topic: "Frågeord, tre sätt att fråga, talen 31–50",
      note: [
        "En fråga kan ställas på tre sätt:\nTu habites où ? (talspråk, bara tonfallet)\nOù est-ce que tu habites ? (vardagligt)\nOù habites-tu ? (omvänd ordföljd, lite finare)",
        "Frågeord: qui (vem), quoi (vad), où (var), quand (när), comment (hur), pourquoi (varför), combien (hur mycket, hur många), quel (vilken).",
        "Quel böjs efter substantivet: quel âge, quelle heure, quels livres, quelles villes. Alla fyra uttalas likadant.",
        "Tiotalen: trente (30), quarante (40), cinquante (50). Trente et un, trente-deux …",
      ],
      parts: [
        words([
          "qui", "quoi", "ou-question", "quand", "comment", "pourquoi",
          "combien", "quel", "aeroport", "place", "pont", "supermarche",
          "piscine", "bibliotheque", "police", "quartier", "centre-ville",
        ]),
        verbs(["demander", "repondre"]),
        sentences([
          "fraga-comment", "fraga-ou", "fraga-qui", "fraga-combien",
          "fraga-quand", "fraga-pourquoi", "fraga-quel-age",
          "fraga-quelle-heure",
        ]),
        numbers(31, 50),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-tid-och-vader",
      title: "Tid och väder",
      topic: "faire, veckodagar, månader och årstider",
      note: [
        "Faire (göra) är oregelbundet:\nje fais · tu fais · il/elle fait\nnous faisons · vous faites · ils/elles font",
        "Vädret beskrivs ofta med il fait: Il fait beau (det är fint väder). Il fait froid. Il fait chaud.",
        "Veckodagar och månader skrivs med liten bokstav. Lundi betyder på måndag, le lundi på måndagar. I en månad: en janvier.",
        "Årstiderna: en été, en automne, en hiver, men au printemps.",
      ],
      parts: [
        verbs(["faire"]),
        words([
          "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi",
          "dimanche", "janvier", "fevrier", "mars", "avril", "mai", "juin",
          "juillet", "aout", "septembre", "octobre", "novembre", "decembre",
          "printemps", "ete", "automne", "hiver", "week-end", "apres-midi",
          "nuit", "date", "midi", "minuit", "chaud", "froid",
        ]),
        sentences([
          "il-fait-beau-aujourd-hui", "je-fais-mes-devoirs",
          "presens-font-sport",
        ]),
        texts(["text-le-temps-en-suede"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-farger-och-klader",
      title: "Färger och kläder",
      topic: "Adjektivens böjning, ce och cette",
      note: [
        "Adjektiv böjs efter substantivet i genus och numerus. Oftast får femininum ett -e och plural ett -s: vert, verte, verts, vertes.",
        "Slutar adjektivet redan på -e ändras det inte i femininum: rouge, rouge. Några böjs oregelbundet: blanc – blanche. Marron och orange böjs inte alls.",
        "Färger står efter substantivet: une voiture rouge, des chaussettes noires.",
        "Ce (den här, det här) böjs också: ce livre, cet homme (maskulinum framför vokal), cette maison, ces fleurs.",
        "Porter (ha på sig, bära) är ett vanligt verb på -er.",
      ],
      parts: [
        words([
          "rouge", "bleu", "vert", "jaune", "noir", "blanc", "gris", "rose",
          "marron", "orange", "pull", "tee-shirt", "jean", "chaussette",
          "casquette", "echarpe", "sac", "ceinture", "maillot-de-bain",
          "lunettes",
        ]),
        verbs(["porter"]),
        sentences([
          "kongruens-grande", "kongruens-noires", "kongruens-bonne",
          "kongruens-blanche", "kongruens-gentils", "kongruens-chaude",
          "kongruens-belle", "kongruens-contentes", "demonstrativ-livre",
          "demonstrativ-maison", "demonstrativ-homme", "demonstrativ-fleurs",
        ]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-hur-ser-de-ut",
      title: "Hur ser de ut?",
      topic: "Adjektiv före substantivet, talen 51–69",
      note: [
        "De flesta adjektiv står efter substantivet: un ami intelligent. Några korta och vanliga står före: grand, petit, jeune, vieux, beau, joli, bon, mauvais, nouveau. Une jolie maison, un bon film.",
        "Beau, nouveau och vieux har en egen form framför vokal: un bel homme, un nouvel ami, un vieil ami. I femininum heter de belle, nouvelle och vieille.",
        "Talen 51–69: cinquante et un, cinquante-deux … soixante (60), soixante et un … soixante-neuf.",
      ],
      parts: [
        words([
          "grand", "petit", "jeune", "vieux", "beau", "joli", "nouveau", "bon",
          "mauvais", "gentil", "content", "fatigue", "intelligent",
          "sympathique", "drole",
        ]),
        texts(["text-mon-ami-lucas"]),
        numbers(51, 69),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-min-dag",
      title: "Min dag",
      topic: "Reflexiva verb, kroppen",
      note: [
        "Reflexiva verb har ett extra pronomen som syftar tillbaka på subjektet, som sig i tvätta sig:\nje me lève · tu te lèves · il/elle se lève\nnous nous levons · vous vous levez · ils/elles se lèvent",
        "Me, te och se blir m', t' och s' framför vokal: je m'appelle, il s'habille.",
        "Lever får accent grave när ändelsen inte hörs: je me lève, men nous nous levons.",
        "Om kroppsdelar använder franskan bestämd artikel, inte possessiv: Je me lave les cheveux (jag tvättar håret).",
      ],
      parts: [
        verbs([
          "se-lever", "se-reveiller", "s-habiller", "se-laver", "se-coucher",
          "s-appeler",
        ]),
        words([
          "nez", "oreille", "dent", "ventre", "doigt", "genou", "epaule", "cou",
          "visage", "cheveux", "minute", "seconde", "tot", "tard",
        ]),
        texts(["text-ma-journee"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-skolan",
      title: "I skolan",
      topic: "vouloir, pouvoir och apprendre",
      note: [
        "Vouloir (vilja) och pouvoir (kunna) följs av ett verb i infinitiv: Je veux apprendre le français. Tu peux venir ?",
        "je veux · tu veux · il veut · nous voulons · vous voulez · ils veulent\nje peux · tu peux · il peut · nous pouvons · vous pouvez · ils peuvent",
        "Je voudrais (jag skulle vilja) är artigare än je veux när man ber om något: Je voudrais un café, s'il vous plaît.",
        "Apprendre (lära sig) böjs som prendre: j'apprends, nous apprenons, ils apprennent.",
      ],
      parts: [
        verbs(["vouloir", "pouvoir", "apprendre"]),
        words([
          "classe", "eleve", "cahier", "stylo", "crayon", "lecon", "reponse",
          "mot", "phrase", "tableau", "examen", "langue", "universite",
          "etudiant",
        ]),
        sentences([
          "tu-veux-du-cafe",
          "presens-veux-venir",
          "presens-pouvez-parler",
        ]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-marknaden",
      title: "På marknaden",
      topic: "Talen 70–100, priser",
      note: [
        "Från 70 räknar franskan i tjugotal:\n70 soixante-dix (60 + 10), 71 soixante et onze, 72 soixante-douze\n80 quatre-vingts (4 × 20), 81 quatre-vingt-un\n90 quatre-vingt-dix, 99 quatre-vingt-dix-neuf, 100 cent",
        "Quatre-vingts får -s bara när inget tal följer: quatre-vingts, men quatre-vingt-deux.",
        "I Belgien och Schweiz säger man septante (70) och nonante (90).",
        "Fråga om priset: C'est combien ? Combien coûtent les fraises ? Det är för dyrt: C'est trop cher.",
      ],
      parts: [
        words([
          "fruit", "legume", "tomate", "carotte", "pomme-de-terre", "oignon",
          "salade", "banane", "orange-fruit", "fraise", "citron", "poulet",
          "jambon", "saucisse", "yaourt", "confiture", "chocolat", "glace",
          "cher", "assez", "seulement",
        ]),
        texts(["text-au-marche", "text-boulangerie"]),
        numbers(70, 100),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-restaurangen",
      title: "På restaurangen",
      topic: "Måltider, beställa, mängdord",
      note: [
        "Måltiderna: le petit-déjeuner (frukost), le déjeuner (lunch), le dîner (middag).",
        "Beställ artigt med je voudrais eller je vais prendre: Je voudrais une crêpe, s'il vous plaît.",
        "Efter mängdord kommer bara de: un verre de vin, une tasse de thé, une bouteille d'eau.",
        "Cuisiner (laga mat) är ett verb på -er. Délicieux (läcker) heter délicieuse i femininum.",
      ],
      parts: [
        words([
          "petit-dejeuner", "dejeuner", "diner", "gateau", "pizza", "sandwich",
          "crepe", "croissant", "baguette", "pates", "bouteille", "verre",
          "tasse", "assiette", "couteau", "fourchette", "cuillere", "delicieux",
        ]),
        verbs(["cuisiner"]),
        texts(["text-au-restaurant"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-i-huset",
      title: "I huset",
      topic: "ouvrir och fermer, öppen och stängd",
      note: [
        "Ouvrir (öppna) slutar på -ir men böjs som ett verb på -er i presens:\nj'ouvre · tu ouvres · il/elle ouvre\nnous ouvrons · vous ouvrez · ils/elles ouvrent",
        "Fermer (stänga) är ett vanligt verb på -er. Adjektiven ouvert (öppen) och fermé (stängd) böjs som andra adjektiv: La porte est ouverte. La fenêtre est fermée.",
        "Les toilettes står i plural, även om det bara finns en toalett.",
      ],
      parts: [
        words([
          "escalier", "mur", "toit", "sol", "canape", "lampe", "armoire",
          "placard", "miroir", "tapis", "douche", "toilettes", "frigo",
          "telephone", "television", "radio", "ouvert", "ferme-adj",
        ]),
        verbs(["ouvrir", "fermer"]),
        sentences(["presens-regardons-tele"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-djur",
      title: "Djur",
      topic: "Substantivens plural, storlek och form",
      note: [
        "Substantiv får oftast -s i plural, och det hörs inte: un chat, des chats. Ord på -eau och -eu får -x: des oiseaux. Ord på -al får -aux: un cheval, des chevaux.",
        "Ord som slutar på -s, -x eller -z ändras inte: une souris, des souris.",
        "Large betyder bred, inte stor, och étroit betyder smal. Lägg märke till long – longue och bas – basse.",
      ],
      parts: [
        words([
          "chat", "chien", "oiseau", "cheval", "lapin", "vache", "cochon",
          "mouton", "souris", "ours", "lion", "loup", "canard", "poule",
          "serpent", "elephant", "singe", "long", "court", "lourd", "large",
          "etroit", "haut", "bas",
        ]),
        sentences(["elle-a-un-chat"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-sport",
      title: "Sport och rörelse",
      topic: "jouer à och jouer de, courir",
      note: [
        "Sporter och spel tar jouer à: je joue au football, au tennis. Instrument tar jouer de: elle joue du piano, de la guitare.",
        "Faire de används om många aktiviteter: faire du sport, faire de la natation.",
        "Courir (springa) är oregelbundet:\nje cours · tu cours · il/elle court\nnous courons · vous courez · ils/elles courent",
        "Nager behåller e:et framför -ons, som manger: nous nageons.",
      ],
      parts: [
        verbs(["nager", "marcher", "courir"]),
        words([
          "piano", "guitare", "dessin", "peinture", "tennis", "natation",
          "promenade", "concert", "theatre", "vacances", "vite", "bon-week-end",
        ]),
        sentences(["a-de-au-football", "a-de-du-piano"]),
        texts(["text-le-week-end"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-tycka-och-tro",
      title: "Tycka och tro",
      topic: "penser, croire och parce que",
      note: [
        "Med penser (tänka, tro) och croire (tro) säger man vad man tycker: Je pense que c'est vrai. Je crois que oui.",
        "Que blir qu' framför vokal: Je pense qu'il est gentil.",
        "Croire är oregelbundet:\nje crois · tu crois · il/elle croit\nnous croyons · vous croyez · ils/elles croient",
        "Pourquoi ? – Parce que …: Pourquoi tu apprends le français ? – Parce que j'aime la France.",
      ],
      parts: [
        verbs(["penser", "croire"]),
        words([
          "facile", "difficile", "interessant", "ennuyeux", "vrai", "faux",
          "celebre", "calme", "riche", "pauvre", "seul", "meme", "autre",
          "sur-adj", "parce-que", "si", "alors", "peut-etre", "vraiment",
        ]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-komma-och-ga",
      title: "Komma och gå",
      topic: "Rörelseverb, här och där",
      note: [
        "Många rörelseverb är vanliga verb på -er: arriver, entrer, monter, tomber, rester. Descendre slutar på -re:\nje descends · tu descends · il/elle descend\nnous descendons · vous descendez · ils/elles descendent",
        "Rester betyder stanna kvar, inte resa: Je reste à la maison.",
        "Visiter används om platser, inte om personer: visiter un musée.",
        "Ici betyder här, là och là-bas där.",
      ],
      parts: [
        verbs([
          "arriver", "rester", "entrer", "monter", "descendre", "tomber",
          "visiter",
        ]),
        words(["ici", "la", "la-bas", "avant", "apres"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-hjalpa-till",
      title: "Hjälpa till",
      topic: "donner à, aider och téléphoner à",
      note: [
        "Donner och téléphoner tar à framför personen: Je donne un livre à Marie. Je téléphone à ma mère. Aider tar ingen preposition: J'aide mon frère.",
        "Commencer får ç framför -ons, så att c:et låter som s: nous commençons.",
        "Quelqu'un (någon) och quelque chose (något) har negationerna personne och rien: Il y a quelqu'un ? – Non, il n'y a personne.",
      ],
      parts: [
        verbs(["donner", "aider", "oublier", "telephoner", "commencer"]),
        words([
          "avec", "sans", "pour", "ensemble", "quelque-chose", "quelqu-un",
          "tout", "pas-de-probleme", "bien-sur", "je-suis-desole",
        ]),
        sentences(["prep-sans"]),
      ],
    ),
    Lesson(
      level: A1,
      id: "a1-snart",
      title: "Snart",
      topic: "Futur proche: aller + infinitiv",
      note: [
        "Det som ska hända snart uttrycks med aller och ett verb i infinitiv, som svenskans ska: Je vais manger. Nous allons partir.",
        "Bara aller böjs:\nje vais parler · tu vas parler · il/elle va parler\nnous allons parler · vous allez parler · ils/elles vont parler",
        "Negationen ställs runt aller: Je ne vais pas travailler demain.",
        "Premier, dernier och prochain säger när: la semaine prochaine (nästa vecka), le dernier jour (den sista dagen).",
      ],
      parts: [
        conjugation(lexicon.FuturProche, [
          "aller", "faire", "parler", "manger", "prendre", "jouer",
        ]),
        sentences([
          "futur-allons-manger", "futur-vas-venir", "futur-prendre-train",
          "futur-faire-devoirs",
        ]),
        words([
          "bientot", "deja", "encore", "ensuite", "parfois", "premier",
          "dernier", "prochain", "felicitations", "bon-anniversaire",
          "bonne-chance",
        ]),
        texts(["text-carte-postale"]),
      ],
    ),
  ]
}
