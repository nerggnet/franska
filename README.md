# franska

A web tool for a Swedish speaker to practise French at A1/A2 level, written
in [Gleam](https://gleam.run).

It offers curated vocabulary, translation, le/la and conjugation exercises,
forgiving answer grading (accents, typos and articles get precise hints in
Swedish), and Leitner-style spaced repetition.

## Status

The core logic is done: content model, exercise generation, grading and
scheduling. The browser UI ([Lustre](https://hexdocs.pm/lustre/)) is next.

## Development

```sh
gleam test                      # Erlang target
gleam test --target javascript  # JavaScript target (what the web app uses)
gleam format src test
```

## Licence

MIT, see [LICENSE](LICENSE).
