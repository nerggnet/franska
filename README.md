# franska

A web tool for a Swedish speaker to practise French at A1/A2 level, written
in [Gleam](https://gleam.run).

It offers curated vocabulary, translation, le/la and conjugation exercises,
forgiving answer grading (accents, typos and articles get precise hints in
Swedish), and Leitner-style spaced repetition.

Try it at **https://nerggnet.github.io/franska/**.

## Status

The browser app ([Lustre](https://hexdocs.pm/lustre/)) offers rounds of 10
exercises from 158 entries (67 at A1 and 91 at A2), optionally limited to
one theme:

- Swedish → French and French → Swedish translation
- le or la? for nouns
- Verb conjugation: présent, futur proche, passé composé and imparfait
- Dictation: write down French read aloud
- Numbers: write 0–100, the hundreds and a few thousands in words

It has accent buttons for French answers and reads French aloud with the
browser's speech synthesis. Spaced repetition decides what each round
contains, so due reviews come first and then new words. Dagens
repetition reviews everything due across all exercise types in one round. Progress, a
statistics page and the practice streak are saved in the browser's local
storage, and nothing leaves your device. The app asks the browser to keep
that data, and the statistics page can export it to a file and import it
again, for a backup or to move to another device.

The app works offline and can be installed on a phone or computer (in
Safari: *Dela → Lägg till på hemskärmen*; in Chrome: the install icon in
the address bar).

Every push to `main` deploys to GitHub Pages
(`.github/workflows/pages.yml`).

## Development

```sh
gleam run -m lustre/dev start   # dev server with live reload on http://localhost:1234
gleam test                      # JavaScript target (the default)
gleam test --target erlang      # the core must work on Erlang too
gleam format src test
```

## Contributing

Corrections to the vocabulary are especially welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

MIT, see [LICENSE](LICENSE).
