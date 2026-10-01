# franska

A web tool for a Swedish speaker to practise French at A1/A2 level, written
in [Gleam](https://gleam.run).

It offers curated vocabulary, translation, le/la and conjugation exercises,
forgiving answer grading (accents, typos and articles get precise hints in
Swedish), and Leitner-style spaced repetition.

Try it at **https://nerggnet.github.io/franska/**.

## Status

The browser app ([Lustre](https://hexdocs.pm/lustre/)) offers rounds of 10
exercises from 67 A1 entries, optionally limited to one theme:

- Swedish → French and French → Swedish translation
- le or la? for nouns
- Verb conjugation in the present tense

It has accent buttons for French answers and reads French aloud with the
browser's speech synthesis. Progress is not saved yet.

Every push to `main` deploys to GitHub Pages
(`.github/workflows/pages.yml`).

## Development

```sh
gleam run -m lustre/dev start   # dev server with live reload on http://localhost:1234
gleam test                      # JavaScript target (the default)
gleam test --target erlang      # the core must work on Erlang too
gleam format src test
```

## Licence

MIT, see [LICENSE](LICENSE).
