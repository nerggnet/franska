# Contributing to franska

Thanks for your interest! franska is a small personal tool for practising
French from Swedish, but corrections and improvements are welcome. The most
useful contributions are usually fixes to the content: a wrong translation,
a missing accepted answer, or a typo.

## Reporting problems

Open an issue at <https://github.com/nerggnet/franska/issues>. For content
problems, include the French and Swedish words, what the app said, and what
you expected. Issues may be written in Swedish or English.

## Getting started

You need:

- [Gleam](https://gleam.run/getting-started/installing/) 1.18 or later
- Erlang/OTP (the Lustre dev tools run on it)
- Node.js 22 or later (to run the tests on the JavaScript target)

```sh
git clone https://github.com/nerggnet/franska.git
cd franska
gleam run -m lustre/dev start   # http://localhost:1234, reloads on save
```

Before opening a pull request, make sure all of these pass. CI runs the
same checks.

```sh
gleam test --target javascript
gleam test --target erlang
gleam format --check src test
```

## Adding or fixing content

The vocabulary lives in `src/franska/content/`, one module per CEFR level.
Each word or phrase is an `Entry`, and every exercise is generated from the
entries automatically, so you never write exercises by hand.

```gleam
noun("maison", "hemmet", "maison", Feminine, ["hus", "hem"]),
verb("parler", ["tala", "prata"], "parler", #(
  "parle", "parles", "parle", "parlons", "parlez", "parlent",
), "parlé", Avoir),
adjective("grand", "egenskaper", ["stor"], "grand", "grande"),
phrase("merci", "hälsningar", ["tack"], ["merci"]),
sentence("je-suis-suedois", "Jag är svensk.", "Je ___ suédois.", ["suis"], "être"),
```

- **Ids are permanent.** The first argument is the entry's id, which is
  what learners' saved progress is stored against. Never rename or reuse an
  existing id. To fix a word, change its other fields. Ids are lowercase
  ASCII with hyphens (`s-il-vous-plait`).
- **Put the main translation first.** The first item in each list is the
  one shown as the prompt and the expected answer; the rest are also
  accepted.
- **Nouns get their article automatically.** `lexicon.noun` adds le, la or
  l'. Use `lexicon.noun_aspirated_h` for words like *héros* that keep le/la
  before an h.
- **Verbs** list their présent forms, then the past participle and the
  auxiliary for the passé composé (`Avoir`, or `Etre` for verbs like
  *aller*, *venir* and *partir*). Other tenses are generated from these.
- **Adjectives** give the masculine and feminine singular; the plurals
  follow the usual rules (beau → beaux, gris → gris). Use `invariable` for
  adjectives like *marron* that never change.
- **Reflexive verbs** use `reflexive(...)` with the verb without its
  pronoun (`"lever"` for *se lever*); they take être in the passé composé.
- **Negation exercises** use `negate(id, swedish, sentence, answers)` with
  the negative sentence as the answer.
- **Sentences** take a theme (such as `"partitiv"`) and have exactly one gap, written `___`, then the answers for
  the gap and a hint shown in brackets (use `""` for none). They only make
  a gap-fill exercise, so keep the Swedish translation natural.
- **Spell French correctly,** with accents and the œ ligature. The grading
  is lenient about learners' accents, not about the content's.

The tests in `test/franska/content_test.gleam` check that ids are unique and
well formed, and that every accepted answer is graded as correct.

## Code

- The learning logic in `src/franska/` is pure Gleam with no browser access,
  so it can be tested on both targets. Browser code (storage, speech,
  focus) lives in `src/franska.gleam` and `src/franska.ffi.mjs`.
- Write code, identifiers and comments in English. Write everything a
  learner sees in Swedish.
- Add tests for logic changes in `test/franska/<module>_test.gleam`.
- If you change the stored progress format incompatibly, bump `version` in
  `src/franska/progress.gleam`.

## Pull requests

Keep pull requests small and focused, with a short description of what
changed and why. By contributing, you agree that your contribution is
licensed under the [MIT License](LICENSE).
