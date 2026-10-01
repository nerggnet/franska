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
gleam run -m lustre/dev start   # dev server on http://localhost:1234 (live reload)
gleam test                      # JavaScript, the project's default target
gleam test --target erlang      # CI runs both targets; keep both passing
gleam format src test           # CI runs `gleam format --check src test`
```

## Architecture

The project target is JavaScript. The pure core lives in `src/franska/`: it
only uses `gleam_stdlib`, must work on both targets, has no FFI and never
reads the clock.

- `src/franska.gleam`: the Lustre app (model, update, view), the only place
  with UI state. Browser FFI is in `src/franska.ffi.mjs`; give every external
  a Gleam fallback body so the package still compiles for Erlang.
- `assets/franska.css`: styles, served at `/` by the dev tools. Page config
  (lang, title, stylesheet) is under `[tools.lustre.html]` in `gleam.toml`.
- `content.gleam` and `content/a1.gleam`: the curated entries. Add a new
  level as a module and include it in `content.entries()`.
- `session.gleam`: one practice round. A wrong answer comes back 3 exercises
  later.

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

- Test UI changes in the browser on the dev server. Synthetic DOM events from
  injected scripts do not reach Lustre's handlers, so drive the app with real
  clicks and keystrokes.
- Entry ids are stored with the learner's progress. Never rename or reuse an
  id once it exists.
- Add new content as `Entry` values. Never hand-write exercises.
- Keep the core pure and test it with gleeunit (`assert`). Put tests in
  `test/franska/<module>_test.gleam`.
- Commit and push every completed change to `origin/main`, after formatting
  and tests pass on both targets.

## Roadmap

1. ~~Core logic: types, grading, spaced repetition~~
2. ~~Lustre app with Swedish→French translation and about 50 A1 entries~~
3. le/la and conjugation drills, accent buttons, text-to-speech via the Web
   Speech API (fr-FR)
4. Progress in `localStorage`, plus a stats view
5. Maybe: deploy to GitHub Pages
