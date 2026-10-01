# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

`franska` is a web tool for a Swedish speaker (the author) to practise French
at CEFR A1/A2 level. The content is curated by hand but must be easy to
extend. It is single-user: progress will live in the browser, and there is
no backend.

The user interface and all learner-facing text are in **Swedish**. Code,
identifiers and comments are in English.

## Commands

```sh
gleam build
gleam test                      # Erlang target (CI runs this)
gleam test --target javascript  # the web app target; keep both passing
gleam format src test           # CI runs `gleam format --check src test`
```

## Architecture

The pure core lives in `src/franska/`. It only uses `gleam_stdlib` and must
work on both targets, so it has no FFI and never reads the clock.

- `lexicon.gleam`: the content model. An `Entry(id, level, theme, sv, word)`
  holds a `Word`, which is a `Noun` (with gender and elision), a `Verb`
  (présent forms) or an `Expression`. Build nouns with `lexicon.noun`, which
  works out l' elision; use `noun_aspirated_h` for exceptions.
- `exercise.gleam`: derives all exercises from an entry: translation in both
  directions, le/la for nouns, and one conjugation per person for verbs.
  Exercise ids are `<entry id>:<suffix>`.
- `answer.gleam`: normalising and grading. A grade is `Correct`,
  `Almost(expected, mistake)` or `Wrong(expected)`; `explain` gives Swedish
  feedback. Swedish å/ä/ö are letters, not accents, so they are never folded.
- `srs.gleam`: Leitner spaced repetition with 6 boxes. Times are Unix
  seconds passed in by the caller.

## Conventions

- Entry ids are stored with the learner's progress. Never rename or reuse an
  id once it exists.
- Add new content as `Entry` values. Never hand-write exercises.
- Keep the core pure and test it with gleeunit (`assert`). Put tests in
  `test/franska/<module>_test.gleam`.
- Commit and push every completed change to `origin/main`, after formatting
  and tests pass on both targets.

## Roadmap

1. ~~Core logic: types, grading, spaced repetition~~
2. Lustre app (`target = "javascript"`) with Swedish→French translation and
   about 50 A1 entries
3. le/la and conjugation drills, accent buttons, text-to-speech via the Web
   Speech API (fr-FR)
4. Progress in `localStorage`, plus a stats view
5. Maybe: deploy to GitHub Pages
