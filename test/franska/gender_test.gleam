import franska/gender
import franska/lexicon.{Feminine, Masculine}
import gleam/option.{None, Some}

pub fn a_noun_following_the_rule_gets_a_tip_test() {
  assert gender.hint("fromage", Masculine)
    == Some("Tips: substantiv på -age är oftast maskulina.")
  assert gender.hint("réunion", Feminine) == None
  assert gender.hint("information", Feminine)
    == Some("Tips: substantiv på -tion är nästan alltid feminina.")
}

pub fn an_exception_is_pointed_out_test() {
  assert gender.hint("plage", Feminine)
    == Some(
      "Undantag: substantiv på -age är oftast maskulina, men plage är feminint.",
    )
  assert gender.hint("eau", Feminine)
    == Some(
      "Undantag: substantiv på -eau är oftast maskulina, men eau är feminint.",
    )
}

pub fn the_longest_ending_wins_test() {
  // -ette, not -et.
  assert gender.hint("assiette", Feminine)
    == Some("Tips: substantiv på -ette är nästan alltid feminina.")
}

pub fn nouns_without_a_rule_get_no_hint_test() {
  assert gender.hint("chat", Masculine) == None
  assert gender.hint("maison", Feminine) == None
}
