# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

`franska` is a web tool for a Swedish speaker (the author) to practise French
at CEFR A1/A2 level. The content is curated by hand but must be easy to
extend. It is single-user: progress lives in the browser's localStorage,
and there is no backend. The repo is public (see CONTRIBUTING.md).

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

The project target is JavaScript. The pure core lives in `src/franska/`
(everything outside `ui/`): it only uses `gleam_stdlib` and `gleam_json`,
must work on both targets, has no FFI and never reads the clock.

- `src/franska.gleam`: `main` only. It loads progress and starts the app
  with a real `Env` (clock, `list.shuffle`, speech support).
- `src/franska/ui/app.gleam`: the Lustre app (model, update, view), the only
  place with UI state. Time and randomness come from `model.env`, never
  from FFI directly, so `update` is tested in `test/franska/ui/app_test.gleam`
  with a fixed clock and no shuffling. The menu picks a `Drill` and a theme.
- `src/franska/ui/browser.gleam` and `browser.ffi.mjs`: all browser access
  (storage and the persistence request, file export/import, speech, focus,
  inserting accents at the caret, the clock). Give
  every external a Gleam fallback body so the package still compiles for
  Erlang.
- `assets/franska.css`: styles, served at `/` by the dev tools. Page config
  (lang, title, stylesheet) is under `[tools.lustre.html]` in `gleam.toml`.
  Keep asset paths relative (`franska.css`, not `/franska.css`), because the
  site is served from https://nerggnet.github.io/franska/.
- `assets/sw.js`, `assets/manifest.webmanifest` and the icons make the app
  installable and usable offline. The service worker tries the network
  first and falls back to its cache, and is only registered in production
  builds (never by the dev server). Keep its `SHELL` list in line with the
  built files.
- `.github/workflows/pages.yml`: deploys every push to `main`. It runs
  `gleam run -m lustre/dev build --minify` and then rewrites the generated
  root-relative script path to a relative one.
- `content.gleam`, `content/a1.gleam` and `content/a2.gleam`: the curated
  entries. Keep easier levels first in `content.entries()`. Add a new level
  as a module, add it to `lexicon.Level` and `level_rank`, and include it
  there.
- `numbers.gleam`: French number words (traditional spelling, 1990 reform
  also accepted) and the generated `Numbers` drill. Number exercises are
  not entries; `content.exercises` and `content.all_exercises` add them.
- `gender.gleam`: gender rules of thumb by noun ending (-tion feminine,
  -age masculine, ...), shown after le/la exercises and article mistakes,
  including when a noun is an exception.
- `session.gleam`: one practice round. A wrong answer comes back 3 exercises
  later.

- `lexicon.gleam`: the content model. An `Entry(id, level, theme, sv, word)`
  holds a `Word`, which is a `Noun` (with gender and elision), a `Verb`
  (présent forms, participle, auxiliary and whether it is reflexive), an
  `Adjective` (four forms,
  plurals derived by `lexicon.adjective`), an `Expression`, a
  `Rewrite` (a sentence to transform, such as negating it) or a `Sentence`
  with one `___` gap. Other tenses are generated from the verb
  data. Build nouns with `lexicon.noun`, which
  works out l' elision; use `noun_aspirated_h` for exceptions.
- `exercise.gleam`: derives all exercises from an entry: translation in both
  directions, le/la for nouns, and one conjugation per person for verbs.
  Exercise ids are `<entry id>:<suffix>`; conjugation suffixes are
  `<tense id>:<pronoun>` (`present:je`, `futur-proche:nous`). The
  imperative only has tu, nous and vous (`lexicon.persons_for`), and verbs
  without a form get no exercise for it. `Exercise.french` is the full
  French form, used to reveal answers and for reading aloud. A `Drill` is
  the kind of practice picked in the menu.
- `answer.gleam`: normalising and grading. `exercise.check` uses
  `grade_without_typos` for conjugation, agreement, comparisons and
  rewrites, where a letter or two is the point of the exercise. A grade is `Correct`,
  `Almost(expected, mistake)` or `Wrong(expected)`; `explain` gives Swedish
  feedback. Swedish å/ä/ö are letters, not accents, so they are never folded.
- `srs.gleam`: Leitner spaced repetition with 6 boxes. Times are Unix
  seconds passed in by the caller. A correct answer before a card is due
  does not promote it.
- `progress.gleam`: the saved state (cards by exercise id, read-aloud
  setting, streak), its JSON format, `plan_round` (due first, then new
  with easier levels first, then due soonest) and `stats`. The app stores it under the
  localStorage key `franska:progress`. Bump `version` when the format
  changes incompatibly; unreadable data falls back to a fresh start.
  Only the first attempt at an exercise in a round is recorded.

## Conventions

- Test UI changes in the browser on the dev server. Synthetic DOM events from
  injected scripts do not reach Lustre's handlers, so drive the app with real
  clicks and keystrokes. Hover before clicking after a screen change (a
  click without a prior mouse move can be ignored), and leave a moment
  before typing.
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
3. ~~le/la and conjugation drills, accent buttons, text-to-speech~~
   ~~(Web Speech API, fr-FR), deploy to GitHub Pages~~
4. ~~Progress in `localStorage`, spaced repetition picks rounds, stats view~~

Since then: Dagens repetition, progress export/import and persistent
storage, offline/installable (PWA), dictation, futur proche, passé composé,
imparfait, numbers, gap-fill sentences, gender hints, Svåra ord and le/la
keyboard shortcuts (1/2).

Ideas for later: more A2 content and sentences, futur simple and the
conditional, rounds mixing drills.
