# Notes for Claude

This repo is a Typst textbook template. Before writing or editing a book, read AUTHORING.md: it lists every component and the writing rules.

- Build with `python3 scripts/build.py <main.typ>` (needs `pip install typst --break-system-packages` in a fresh workspace). It wires up fonts and `@local/textbook` automatically.
- After building, render pages (`pdftoppm -r 50 -png`) and look at them. Check margin notes for overlap and pages for overflow.
- Change the series look only in `src/theme.typ`. Books do not restyle components locally.
- Typst Universe packages cannot be downloaded from Claude's cloud workspace; keep the template dependency-free.
- Remote images cannot be fetched from the workspace either. Use `#photo(none, alt: ..., credit: ...)` placeholders and list what to source.
