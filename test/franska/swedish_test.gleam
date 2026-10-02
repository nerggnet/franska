import franska/lexicon.{
  Conditionnel, Equal, FuturProche, FuturSimple, Il, Ils, Imparfait, Imperatif,
  Je, Less, More, Most, Nous, PasseCompose, Presens, Tu, Vous,
}
import franska/swedish
import gleam/list

pub fn adjective_plurals_test() {
  let cases = [
    #("stor", "stora"),
    #("ny", "nya"),
    #("kort", "korta"),
    #("lätt", "lätta"),
    #("glad", "glada"),
    #("snäll", "snälla"),
    #("fri", "fria"),
    #("kär", "kära"),
    #("ren", "rena"),
    #("grön", "gröna"),
    #("modern", "moderna"),
    #("vacker", "vackra"),
    #("säker", "säkra"),
    #("enkel", "enkla"),
    #("öppen", "öppna"),
    #("ledsen", "ledsna"),
    #("tom", "tomma"),
    #("ensam", "ensamma"),
    #("långsam", "långsamma"),
    #("varm", "varma"),
    #("förvånad", "förvånade"),
    #("likadan", "likadana"),
    #("bra", "bra"),
    #("rosa", "rosa"),
    #("nästa", "nästa"),
    #("redo", "redo"),
    #("annorlunda", "annorlunda"),
    #("fel", "fel"),
    #("blå", "blå"),
    #("liten", "små"),
    #("gammal", "gamla"),
    #("annan", "andra"),
  ]
  let wrong =
    list.filter(cases, fn(c) { swedish.adjective_plural(c.0) != c.1 })
    |> list.map(fn(c) { #(c.0, swedish.adjective_plural(c.0)) })
  assert wrong == []
}

pub fn regular_verbs_test() {
  assert swedish.conjugate("tala", Presens, Nous) == Ok("vi talar")
  assert swedish.conjugate("tala", Imparfait, Je) == Ok("jag talade")
  assert swedish.conjugate("tala", PasseCompose, Il) == Ok("han har talat")
  assert swedish.conjugate("tala", lexicon.PasseRecent, Il)
    == Ok("han har just talat")
  assert swedish.conjugate("tvätta sig", lexicon.PresentProgressif, Nous)
    == Ok("vi håller på att tvätta oss")
  assert swedish.conjugate("tala", FuturProche, Tu) == Ok("du ska tala")
  assert swedish.conjugate("tala", FuturSimple, Vous)
    == Ok("ni kommer att tala")
  assert swedish.conjugate("tala", Conditionnel, Ils) == Ok("de skulle tala")
  assert swedish.conjugate("tala", Imperatif, Tu) == Ok("tala!")
  assert swedish.conjugate("tala", Imperatif, Nous) == Ok("låt oss tala!")
}

pub fn irregular_verbs_test() {
  assert swedish.conjugate("gå", Imparfait, Je) == Ok("jag gick")
  assert swedish.conjugate("vara", Presens, Il) == Ok("han är")
  assert swedish.conjugate("äta", Imperatif, Vous) == Ok("ät!")
  assert swedish.conjugate("ringa", PasseCompose, Je) == Ok("jag har ringt")
  assert swedish.conjugate("lyckas", Imparfait, Nous) == Ok("vi lyckades")
  assert swedish.conjugate("kunna", Imperatif, Tu) == Error(Nil)
}

pub fn particles_and_reflexives_follow_the_verb_test() {
  assert swedish.conjugate("stiga upp", PasseCompose, Nous)
    == Ok("vi har stigit upp")
  assert swedish.conjugate("klä på sig", Presens, Je) == Ok("jag klär på mig")
  assert swedish.conjugate("tvätta sig", Imperatif, Tu) == Ok("tvätta dig!")
  assert swedish.conjugate("tvätta sig", Imperatif, Nous)
    == Ok("låt oss tvätta oss!")
  assert swedish.conjugate("tvätta sig", Presens, Ils) == Ok("de tvättar sig")
}

pub fn maste_is_paraphrased_test() {
  assert swedish.conjugate("måste", Presens, Je) == Ok("jag måste")
  assert swedish.conjugate("måste", Imparfait, Nous) == Ok("vi var tvungna")
  assert swedish.conjugate("måste", PasseCompose, Il)
    == Ok("han har varit tvungen")
  assert swedish.conjugate("måste", Conditionnel, Je) == Ok("jag skulle behöva")
}

pub fn comparatives_test() {
  let cases = [
    #("snabb", #("snabbare", "snabbast")),
    #("dyr", #("dyrare", "dyrast")),
    #("vacker", #("vackrare", "vackrast")),
    #("öppen", #("öppnare", "öppnast")),
    #("tom", #("tommare", "tommast")),
    #("blå", #("blåare", "blåast")),
    #("stor", #("större", "störst")),
    #("god", #("bättre", "bäst")),
    #("gammal", #("äldre", "äldst")),
    #("liten", #("mindre", "minst")),
    #("intressant", #("mer intressant", "mest intressant")),
    #("sympatisk", #("mer sympatisk", "mest sympatisk")),
    #("rosa", #("mer rosa", "mest rosa")),
    #("förvånad", #("mer förvånad", "mest förvånad")),
  ]
  let wrong =
    list.filter(cases, fn(c) { swedish.compare(c.0) != c.1 })
    |> list.map(fn(c) { #(c.0, swedish.compare(c.0)) })
  assert wrong == []
}

pub fn comparison_sentences_test() {
  assert swedish.comparison("stor", More) == "Hon är större än han."
  assert swedish.comparison("dyr", Less) == "De är inte lika dyra som vi."
  assert swedish.comparison("stor", Equal) == "Han är lika stor som du."
  assert swedish.comparison("stor", Most) == "De är störst av alla."
}

pub fn adjectives_after_bli_agree_test() {
  assert swedish.conjugate("bli frisk", Presens, Je) == Ok("jag blir frisk")
  assert swedish.conjugate("bli frisk", Presens, Nous) == Ok("vi blir friska")
}
