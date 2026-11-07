# Authoring guide

How to write a book with this template. Written for people and for agents (Claude) alike: follow it and every book in the series reads the same way.

## The shape of a book

A book teaches one build from first principles, the way a high school or first-year college text does. Each chapter:

1. **Opens** with `#chapter(title, lead:, objectives:)`. The outline of sections is generated in the margin.
2. Sets prerequisites in a `#background[...]` box when the reader needs anything from school physics or math.
3. Has **4–7 numbered sections** (`==`). Each section builds one idea on the last and ends, when it fits, with a `#check-yourself(...)` and a `#read-more(...)`.
4. Closes with `== Summary and review`: `#summary`, `#key-equations`, `#problems` + `#problem`, and `#looking-ahead`.

Appendices (`#show: appendix`) hold reference material: spec, bill of materials, configs, build sequence, troubleshooting. Back matter (`#back-chapter`) is generated: glossary, symbols, references, further reading, figure credits, answer key, index.

## Components

### Statements (numbered per chapter, shared counter)

| Call | Use for |
|---|---|
| `#definition(title: [..])[..]` | Fixing the meaning of a word |
| `#theorem`, `#law`, `#lemma`, `#corollary` | A claim that can be proved or derived |
| `#principle`, `#rule-env` | A design rule the build depends on |
| `#proof[..]` | Short proof right after a theorem, when the reasoning is the point |
| `#example(title:, steps: ((label, content), ..))[]` | Worked example with real numbers from the build |

Label them (`<thm:fault>`) and refer with `@thm:fault`, or `#pref(<thm:fault>)` for "Theorem 1.6 on page 4". Never type a number like "Theorem 1.6" by hand.

### Margin (outer column)

Call these **between paragraphs, right before the paragraph they belong to**. They stack if two land close together.

| Call | Color | Use for |
|---|---|---|
| `#keyterm("Term")[def]` | blue | New vocabulary. Also feeds the glossary and index. `"Term"` must be a string. |
| `#watch-out[..]` | red | Safety or failure warnings |
| `#trade[..]` | green | How professionals actually do it |
| `#did-you-know[..]` | purple | A curious fact, safe to skip |
| `#sidenote[..]` | rule | Source notes, small caveats |
| `#margin-figure(img, caption:)` | — | Small photo or part in the margin |

Keep margin notes to 1–3 sentences. A page holds about four before they run off the bottom.

### Inline boxes

| Call | Use for |
|---|---|
| `#history(era: "1827", title: [..], image: ..)[..]` | Where an idea or standard came from, and why it stuck. One per chapter or two, with a citation. |
| `#background[..]` | Prerequisites and where to catch up |
| `#intuition(title: [..])[..]` | "Why it works": the physical picture behind a rule |
| `#mistake(wrong: [..], right: [..])[why]` | A common error, the fix, and the reason |
| `#check-yourself(([q], [a]), ..)` | 2–3 quick questions at a section's end. Answers go to the answer key. |
| `#read-more((title:, url:, source:, kind:, note:), ..)` | Curated links. `kind`: article, video, datasheet, book, course, forum. Also collected in Further Reading. |
| `#summary(..)`, `#key-equations((name, $eq$), ..)`, `#looking-ahead(intro, (label, title, text), ..)` | Chapter close |
| `#problems()` then `#problem(level: 0–3, answer: [..])[..]` | End-of-chapter problems. Stars mark difficulty. |

### Figures

- `#figure(drawing, caption: [..]) <fig:x>`: diagrams. Prefer drawing natively in Typst (lines, rects, `curve`, gradients) so they need no files and match the palette. See `examples/lighting-handbook/figures.typ`.
- `#photo("img/x.jpg", caption:, credit: "Author, CC BY-SA 4.0", source: "https://...") <fig:y>`: third-party images. Credits are collected into Figure Credits. Pass `none` as the path to draw a labeled placeholder until the image is sourced.
- Tables: `#figure(table(..), caption: [..])`. Captions go on top automatically.
- `#wide(..)` makes anything span the text column plus the margin. Use it for wide tables and code in appendices.

### Indexing and symbols

- `#term("phosphor")` bolds a word in running text and indexes it. `display:` changes what is shown.
- `#idx("Ohm's law")` adds an invisible index entry; `sub:` makes a sub-entry.
- `#notation($Delta V$, [voltage drop], unit: [V])` registers a symbol for the List of Symbols. Place it right after the symbol is introduced.

### Citations

Put sources in a Hayagriva `refs.yml` next to the book and cite with `@key`. Citations render as superscript numbers. Close the book with:

```typst
#back-chapter([References])
#bibliography("refs.yml", title: none, style: "american-medical-association")
```

## Writing rules

- **Teach in order.** Definition, then the rule, then a worked example with the build's real numbers, then a check. Each section should be answerable without reading ahead.
- **Every number has a source.** Datasheet values are cited. Assumptions are called assumptions (in the example and in a note under the References).
- **History is evidence, not decoration.** Use a history box when knowing the origin explains the rule (why CRI is weak, why AWG numbers run backward). Cite it.
- **Read More is curated.** Two or three links a section at most, each with one line on why it is worth the time. Prefer primary sources: datasheets, standards bodies, official docs, nobelprize.org-style explainers.
- **Margins are for the second pass.** The main column must make sense without them.
- **Photos need a license.** Credit author and license; Wikimedia Commons is the default source.

## Building

```sh
python3 scripts/build.py examples/lighting-handbook/main.typ   # inside this repo
python3 scripts/build.py ~/books/my-book/main.typ              # any book importing @local/textbook
```

`build.py` uses the `typst` Python package (`pip install typst`), the bundled fonts, and exposes this repo as `@local/textbook:<version>` automatically. With the Typst CLI instead, run `scripts/install.sh` once, then `typst compile --font-path <repo>/fonts main.typ`.

## Known limits

- Margin notes are placed relative to the page flow, so call them at block level (not inside a box or table).
- A page with many margin notes can overflow the bottom margin; move a note or shorten it.
- Typst Universe packages are not used, so the template builds offline.
