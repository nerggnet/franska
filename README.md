# franska

A web tool for a Swedish speaker to practise French at A1/A2 level, written
in [Gleam](https://gleam.run).

It offers curated vocabulary, translation, le/la and conjugation exercises,
forgiving answer grading (accents, typos and articles get precise hints in
Swedish), and Leitner-style spaced repetition.

Try it at **https://nerggnet.github.io/franska/**.

## Status

The browser app ([Lustre](https://hexdocs.pm/lustre/)) offers rounds of 10
exercises from 1342 words and phrases (447 at A1 and 895 at A2), 247
gap-fill sentences and 54 sentences to rewrite (negation and pronouns),
optionally limited to one theme:

- Swedish → French and French → Swedish translation
- le or la? for nouns
- Verb conjugation: présent, présent progressif (en train de), futur proche,
  passé récent (venir de), futur simple, passé composé,
  imparfait, conditionnel and imperative, including reflexive verbs (se lever, lève-toi)
- Dictation: write down French read aloud
- Numbers: write 0–100, the hundreds and a few thousands in words
- Sentences: fill the gap in a sentence, with the Swedish meaning as context;
  themes for partitive articles, possessives, demonstratives, negation,
  pronouns, comparisons, the future and the conditional, relative pronouns
  (qui, que, où), passé composé or imparfait, places (à, en, au), time
  expressions (depuis, il y a, pendant), reflexive verbs, the imperative,
  articles, adjective agreement, question words and à/de with articles
- Adjectives: agreement in gender and number (grand, grande, grands, grandes)
- Negation: make a sentence negative (Tu as un chien → Tu n'as pas de chien)
- Pronouns: replace part of a sentence with le, la, les, lui, leur, y or en
  (Je parle à Paul → Je lui parle)
- Comparisons: plus, moins and aussi … que and the superlative (les plus grandes, le plus grand) for every
  gradable adjective, with agreement (Elle est plus grande que lui) and meilleur
- Reading and listening comprehension: 34 short texts and dialogues with
  questions in Swedish; in listening, the text is only read aloud, a
  sentence at a time and at three speeds, with two voices in dialogues, and the transcript and translation are shown afterwards

Blandad runda mixes all of these except the texts in one round, and every
exercise shows whether it is A1 or A2; the menu can limit practice to one
level. It has accent buttons for French answers and reads French aloud with the
browser's speech synthesis, choosing the best French voice available (or
the one picked in the menu). On a Mac, a premium voice such as Audrey
(Premium) or Thomas (Förbättrad), installed under System Settings →
Accessibility → Spoken Content, sounds much better than the defaults. Spaced repetition decides what each round
contains, so due reviews come first and then new words. Dagens
repetition reviews everything due across all exercise types in one round,
and Svåra ord on the statistics page practises the exercises you have got
wrong most often. Progress, a
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
