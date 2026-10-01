# franska

A web tool for a Swedish speaker to practise French at A1/A2 level, written
in [Gleam](https://gleam.run).

It offers curated vocabulary, translation, le/la and conjugation exercises,
forgiving answer grading (accents, typos and articles get precise hints in
Swedish), and Leitner-style spaced repetition.

## Status

The browser app ([Lustre](https://hexdocs.pm/lustre/)) has rounds of 10
Swedish → French translations, optionally limited to one theme, drawn from
67 A1 entries. Progress is not saved yet.

## Development

```sh
gleam run -m lustre/dev start   # dev server with live reload on http://localhost:1234
gleam test                      # JavaScript target (the default)
gleam test --target erlang      # the core must work on Erlang too
gleam format src test
```

## Licence

MIT, see [LICENSE](LICENSE).
