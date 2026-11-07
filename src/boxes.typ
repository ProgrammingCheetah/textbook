// boxes.typ — the textbook's learning devices.
//
// Margin (outer column):   keyterm, watch-out, trade, did-you-know, sidenote,
//                          margin-figure
// Inline (text column):    history, background, intuition, mistake,
//                          read-more, check-yourself, objectives, summary,
//                          key-equations, looking-ahead, problems/problem
// Indexing and symbols:    term, idx, notation

#import "theme.typ": *
#import "common.typ": *
#import "notes.typ": margin-note

// ======================================================================
// Indexing
// ======================================================================

/// Invisible index entry at this point. `sub` makes a sub-entry.
#let idx(term, sub: none) = [#metadata((term: term, sub: sub))<tb-idx>]

/// A term introduced in running text: bold, and indexed.
#let term(t, display: none) = {
  idx(t)
  strong(if display == none { t } else { display })
}

/// Register a symbol for the list of symbols (first use is recorded).
/// Example: #notation($Delta V$, [voltage drop along a conductor], unit: [V])
#let notation(sym, meaning, unit: none) = [#metadata((sym: sym, meaning: meaning, unit: unit, key: repr(sym)))<tb-sym>]

// ======================================================================
// Margin boxes
// ======================================================================

#let _sidebox(name, color, fill, body) = block(
  width: 100%, fill: fill, inset: (x: 8pt, y: 7pt), radius: 2pt, {
    label-text(name, color: color)
    v(1pt)
    body
  },
)

/// Key term: margin definition, also added to the glossary and the index.
/// `t` must be a string (it is sorted).
#let keyterm(t, body, dy: 0pt) = {
  [#metadata((term: t, body: body))<tb-term>]
  idx(t)
  margin-note(dy: dy, _sidebox("Key term", blue, blue-soft)[*#t.* #body])
}

/// Safety or failure warning.
#let watch-out(body, dy: 0pt) = margin-note(dy: dy, _sidebox("Watch out", red, red-soft, body))

/// How professionals in the trade actually do it.
#let trade(body, dy: 0pt) = margin-note(dy: dy, _sidebox("In the trade", green, green-soft, body))

/// A curious fact; not needed for the build.
#let did-you-know(body, dy: 0pt) = margin-note(dy: dy, _sidebox("Did you know?", purple, purple-soft, body))

/// Plain margin remark with a thin rule.
#let sidenote(body, dy: 0pt) = margin-note(dy: dy, block(
  stroke: (left: 0.6pt + rule), inset: (left: 6pt, y: 2pt), text(fill: muted, body),
))

/// A small figure in the margin (photo, part, symbol). Counts as a figure.
#let margin-figure(body, caption: none, dy: 0pt) = margin-note(dy: dy, {
  show figure.caption: set text(size: 7.4pt, fill: muted)
  show figure.caption: set align(left)
  figure(body, caption: caption)
})

// ======================================================================
// Inline boxes
// ======================================================================

#let _inbox(name, color, fill, body, title: none, aside: none) = block(
  width: 100%, breakable: true, fill: fill, radius: 3pt, inset: (x: 12pt, y: 10pt),
  above: 1.2em, below: 1.2em, {
    label-text(name, color: color)
    if title != none {
      v(2pt)
      text(font: serif, weight: "bold", size: 11pt, fill: color, title)
    }
    v(3pt)
    set par(justify: true)
    if aside != none {
      grid(columns: (1fr, auto), column-gutter: 10pt, body, aside)
    } else { body }
  },
)

/// A Bit of History: where an idea or standard came from.
/// `era` is a short tag like "1879" or "1960s"; `image` sits to the right.
#let history(title: none, era: none, image: none, body) = _inbox(
  if era == none { "A bit of history" } else { "A bit of history · " + era },
  sepia, sepia-soft, title: title, aside: image, body,
)

/// What the reader should already know, with pointers to catch up.
#let background(title: none, body) = _inbox("Before you begin", ink, shade, title: title, body)

/// Why it works: the physical or mental model behind a rule.
#let intuition(title: none, body) = _inbox("Why it works", teal, teal-soft, title: title, body)

/// A common mistake, shown as the wrong move, the right move, and why.
#let mistake(wrong: none, right: none, body) = block(
  width: 100%, breakable: true, stroke: (left: 2.5pt + red), fill: red-soft.lighten(40%),
  inset: (left: 12pt, right: 10pt, y: 9pt), above: 1.2em, below: 1.2em, {
    label-text("Common mistake", color: red)
    v(3pt)
    set par(justify: false)
    if wrong != none {
      grid(columns: (1.1em, 1fr), row-gutter: 5pt,
        text(fill: red, weight: "bold")[✗], wrong,
        ..if right != none { (text(fill: green, weight: "bold")[✓], right) } else { () })
      v(4pt)
    }
    body
  },
)

/// Read more: curated links at the end of a section. Each item is a
/// dictionary (title:, url:, source:, note:, kind:) where kind is one of
/// "article", "video", "datasheet", "book", "course", "forum".
/// Items are also collected into the back-matter Further Reading list.
#let read-more(..items) = {
  let icons = (article: "≡", video: "▶", datasheet: "◧", book: "❑", course: "◆", forum: "☰")
  for it in items.pos() { [#metadata(it)<tb-read>] }
  block(
    width: 100%, stroke: (top: 1.5pt + accent, bottom: 0.5pt + rule), inset: (y: 8pt),
    above: 1.4em, below: 1.2em, breakable: false, {
      label-text("Read more", color: accent)
      v(3pt)
      set text(size: 9.2pt)
      set par(justify: false, leading: 0.5em)
      for it in items.pos() {
        let icon = icons.at(it.at("kind", default: "article"), default: "≡")
        grid(columns: (1.2em, 1fr), column-gutter: 2pt,
          text(fill: accent, font: sans, size: 8pt, icon),
          {
            link(it.url, text(fill: ink, weight: "bold", it.title))
            if it.at("source", default: none) != none { text(fill: muted)[ — #it.source] }
            if it.at("note", default: none) != none { linebreak(); text(size: 8.6pt, it.note) }
          })
        v(3pt)
      }
    },
  )
}

/// Learning objectives box for a chapter opener.
#let objectives(..items) = block(
  width: 100%, stroke: (top: 2pt + ink, bottom: 0.5pt + rule), inset: (y: 10pt),
  above: 1.4em, below: 1.4em, {
    label-text([In this chapter you will learn to], color: ink)
    v(4pt)
    set text(size: 10pt)
    set par(justify: false)
    list(..items.pos())
  },
)

/// Check yourself: quick questions at the end of a section. Each argument is
/// a (question, answer) pair; answers go to the answer key.
#let check-yourself(..pairs) = context {
  let sec = counter(heading).get()
  sec = sec.slice(0, calc.min(2, sec.len()))
  let sec-label = if appendix-state.get() { numbering("A.1", ..sec) } else { sec.map(str).join(".") }
  [#metadata((kind: "check", ch: chapter-label(), label: sec-label, answers: pairs.pos().map(p => p.at(1))))<tb-ans>]
  block(
    width: 100%, stroke: 0.8pt + blue, radius: 3pt, inset: (x: 12pt, y: 9pt),
    above: 1.2em, below: 1.2em, breakable: false, {
      label-text([Check yourself · #sec-label], color: blue)
      v(3pt)
      set par(justify: false)
      enum(numbering: "a)", ..pairs.pos().map(p => p.at(0)))
    },
  )
}

/// Chapter summary as bullet points.
#let summary(..items) = block(width: 100%, above: 1em, below: 1em, {
  block(width: 100%, stroke: (top: 2pt + ink), inset: (top: 8pt), below: 6pt,
    label-text([Chapter summary], color: ink))
  list(..items.pos())
})

/// Key equations: pairs of (name, equation) in two columns.
#let key-equations(..pairs) = block(
  width: 100%, fill: accent-soft, radius: 3pt, inset: (x: 14pt, y: 12pt), above: 1.2em, below: 1.2em, {
    label-text([Key equations], color: accent)
    v(6pt)
    grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 8pt, row-gutter: 9pt,
      ..pairs.pos().map(((n, e)) => (n, align(right, box(e)))).flatten())
  },
)

/// Looking ahead: where the next chapters go. Items are (label, title, text).
#let looking-ahead(intro, ..items) = block(
  width: 100%, fill: shade, radius: 3pt, inset: (x: 14pt, y: 12pt), above: 1.4em, {
    label-text([Looking ahead], color: accent)
    v(4pt)
    intro
    v(4pt)
    set text(font: sans, size: 8.4pt)
    grid(columns: (3.4em, 1fr), row-gutter: 6pt,
      ..items.pos().map(((l, t, d)) => (text(fill: accent, weight: "bold", l), [*#t.* #d])).flatten())
  },
)

// ======================================================================
// Problems
// ======================================================================

/// Problems heading for the end of a chapter.
#let problems(title: [Problems], intro: none) = {
  heading(level: 3, numbering: none, outlined: false, title)
  if intro != none { text(size: 9.4pt, fill: muted, intro) }
  block(above: 0.4em, below: 0.4em,
    text(font: sans, size: 7.6pt, fill: muted)[#text(font: "DejaVu Sans", fill: accent)[★] needs two steps · #text(font: "DejaVu Sans", fill: accent)[★★] uses a result from another section · #text(font: "DejaVu Sans", fill: accent)[★★★] open-ended])
}

/// One problem. `level` 0–3 adds stars; `answer` goes to the answer key.
#let problem(level: 0, answer: none, body) = {
  counter("tb-problem").step()
  context {
    let n = counter("tb-problem").get().first()
    let lbl = chapter-label() + "." + str(n)
    if answer != none {
      [#metadata((kind: "problem", ch: chapter-label(), label: lbl, answers: (answer,)))<tb-ans>]
    }
    block(above: 0.7em, below: 0.7em, breakable: false,
      grid(columns: (2.6em, 2.6em, 1fr), column-gutter: 2pt,
        text(font: sans, weight: "bold", size: 9pt, fill: accent, lbl),
        text(font: "DejaVu Sans", size: 7.5pt, fill: accent, "★" * level),
        body))
  }
}
