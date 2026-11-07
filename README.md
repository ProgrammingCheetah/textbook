# textbook

A Typst template for technical books in the style of a high school or first-year college textbook, organized like a good reference book (cheat sheet, introduction, parts, margin icons, Part of Tens): chapter openers, numbered definitions and theorems, worked examples, margin notes, history and "why it works" boxes, check-yourself questions, read-more links, starred problems with an answer key, and a generated glossary, symbol list, further reading, figure credits and index.

Built for the BIFL & DIY build handbooks, usable for anything that wants this shape.

![](https://img.shields.io/badge/typst-0.13%2B-239dad)

## Quick start

```sh
pip install typst
python3 scripts/build.py examples/lighting-handbook/main.typ
```

New book:

```sh
scripts/install.sh                                  # once, for the Typst CLI
typst init @local/textbook:0.1.0 my-book
typst compile --font-path path/to/textbook/fonts my-book/main.typ
```

or copy `template/main.typ` anywhere and build it with `python3 scripts/build.py path/to/main.typ`.

## Layout

```
src/            the template (lib.typ re-exports everything)
  theme.typ     palette, fonts, page geometry
  layout.typ    book(), chapter(), appendix, running heads, cover, front matter
  notes.typ     outer-margin notes and wide blocks
  env.typ       definitions, theorems, proofs, worked examples
  boxes.typ     history, background, intuition, mistakes, read-more, checks, problems, index marks
  figures.typ   photos with credits and placeholders
  backmatter.typ glossary, index, symbols, further reading, credits, answer key, page refs
template/       starter book for `typst init`
examples/       The Apartment Lighting Handbook, Chapter 1
tests/          kitchen-sink.typ: every component on a few pages
fonts/          TeX Gyre Pagella and Heros (GUST Font License)
scripts/        build.py, install.sh
```

See [AUTHORING.md](AUTHORING.md) for every component and the writing rules.

## License

Code: MIT. Fonts: GUST Font License (see `fonts/GUST-FONT-LICENSE.txt`).
