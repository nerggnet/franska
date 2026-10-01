//// Rules of thumb for the gender of a noun from its ending, shown as hints
//// after article mistakes. They describe tendencies, so a hint also says
//// when a noun is an exception.

import franska/lexicon.{type Gender, Feminine, Masculine}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

type Rule {
  /// `reliable` rules have very few exceptions.
  Rule(ending: String, gender: Gender, reliable: Bool)
}

/// Longer endings come first, so the most specific rule wins.
const rules = [
  Rule("isme", Masculine, True),
  Rule("tion", Feminine, True),
  Rule("sion", Feminine, True),
  Rule("ment", Masculine, True),
  Rule("ette", Feminine, True),
  Rule("ance", Feminine, True),
  Rule("ence", Feminine, True),
  Rule("age", Masculine, False),
  Rule("eau", Masculine, False),
  Rule("ure", Feminine, False),
  Rule("ude", Feminine, False),
  Rule("ade", Feminine, False),
  Rule("oir", Masculine, False),
  Rule("ier", Masculine, False),
  Rule("ail", Masculine, True),
  Rule("eil", Masculine, True),
  Rule("té", Feminine, False),
  Rule("ée", Feminine, False),
  Rule("ie", Feminine, False),
  Rule("et", Masculine, False),
]

/// A Swedish hint for a noun's gender, if its ending follows a rule.
pub fn hint(noun: String, gender: Gender) -> Option(String) {
  let noun = string.lowercase(noun)
  case list.find(rules, fn(rule) { string.ends_with(noun, rule.ending) }) {
    Error(Nil) -> None
    Ok(rule) -> {
      let tendency =
        "substantiv på -"
        <> rule.ending
        <> " är "
        <> case rule.reliable {
          True -> "nästan alltid "
          False -> "oftast "
        }
        <> plural_name(rule.gender)
      case rule.gender == gender {
        True -> Some("Tips: " <> tendency <> ".")
        False ->
          Some(
            "Undantag: "
            <> tendency
            <> ", men "
            <> noun
            <> " är "
            <> singular_name(gender)
            <> ".",
          )
      }
    }
  }
}

fn plural_name(gender: Gender) -> String {
  case gender {
    Masculine -> "maskulina"
    Feminine -> "feminina"
  }
}

fn singular_name(gender: Gender) -> String {
  case gender {
    Masculine -> "maskulint"
    Feminine -> "feminint"
  }
}
