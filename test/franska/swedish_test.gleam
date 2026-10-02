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
