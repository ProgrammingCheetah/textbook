// backmatter.typ — everything generated from markers left in the text:
// glossary, index, list of symbols, further reading, figure credits,
// answer key, and page-aware cross-references.

#import "theme.typ": *
#import "common.typ": *

/// Reference with page number: "Theorem 1.6 on page 4".
/// Use for things more than a page away.
#let pref(target) = context {
  let el = query(target)
  if el.len() == 0 { ref(target) } else {
    let loc = el.first().location()
    [#ref(target) on #link(loc)[page #page-of(loc)]]
  }
}

/// Page number of a label, as a link: "p. 4".
#let pageref(target) = context {
  let loc = query(target).first().location()
  link(loc)[p. #page-of(loc)]
}

#let _sorted-unique(entries, key) = {
  let seen = (:)
  let out = ()
  for e in entries.sorted(key: e => lower(key(e))) {
    let k = lower(key(e))
    if k not in seen { seen.insert(k, true); out.push(e) }
  }
  out
}

/// Glossary built from every #keyterm, alphabetized.
#let glossary() = context {
  let terms = query(<tb-term>).map(m => (m.value, m.location()))
  let items = _sorted-unique(terms, ((v, _)) => v.term)
  set par(justify: false)
  grid(columns: (4.2cm, 1fr), row-gutter: 0.75em, column-gutter: 1em,
    ..items.map(((v, loc)) => (
      text(font: sans, size: 9pt, weight: "bold", v.term),
      [#v.body #text(fill: muted, size: 8pt)[(#link(loc)[p. #page-of(loc)])]],
    )).flatten())
}

/// Index built from every #idx, #term and #keyterm. Pages are links.
#let make-index(cols: 3) = context {
  let marks = query(<tb-idx>)
  let groups = (:)  // term -> (pages: (), subs: (sub -> pages))
  for m in marks {
    let v = m.value
    let p = page-of(m.location())
    let loc = m.location()
    let key = lower(v.term)
    let g = groups.at(key, default: (pages: (), subs: (:), forms: (:)))
    g.forms.insert(v.term, g.forms.at(v.term, default: 0) + 1)
    if v.sub == none {
      if p not in g.pages.map(x => x.at(0)) { g.pages.push((p, loc)) }
    } else {
      let s = g.subs.at(v.sub, default: ())
      if p not in s.map(x => x.at(0)) { s.push((p, loc)) }
      g.subs.insert(v.sub, s)
    }
    groups.insert(key, g)
  }
  let keys = groups.keys().sorted(key: lower)
  let pages(ps) = ps.map(((p, loc)) => link(loc, p)).join(", ")
  set text(size: 8.6pt)
  set par(justify: false, leading: 0.45em, hanging-indent: 1em)
  columns(cols, gutter: 1.2em, {
    let last-letter = none
    for k in keys {
      let letter = upper(k.first())
      if letter != last-letter {
        if last-letter != none { v(0.5em) }
        text(font: sans, weight: "bold", fill: accent, letter)
        linebreak()
        last-letter = letter
      }
      let g = groups.at(k)
      let shown = g.forms.pairs().sorted(key: ((f, n)) => (-n, f)).first().at(0)
      [#shown#if g.pages.len() > 0 [, #pages(g.pages)]]
      linebreak()
      for s in g.subs.keys().sorted(key: lower) {
        h(1em); [#s, #pages(g.subs.at(s))]
        linebreak()
      }
    }
  })
}

/// List of symbols from every #notation, in order of first appearance.
#let symbol-list() = context {
  let seen = (:)
  let rows = ()
  for m in query(<tb-sym>) {
    let v = m.value
    if v.key not in seen {
      seen.insert(v.key, true)
      rows.push((v.sym, v.meaning, if v.unit == none { [—] } else { v.unit }, link(m.location(), page-of(m.location()))))
    }
  }
  table(
    columns: (auto, 1fr, auto, auto), stroke: none, inset: (x: 6pt, y: 5pt),
    table.hline(stroke: 0.8pt),
    table.header(..([Symbol], [Meaning], [Unit], [Page]).map(x => text(font: sans, size: 8pt, weight: "bold", x))),
    table.hline(stroke: 0.5pt),
    ..rows.flatten(),
    table.hline(stroke: 0.8pt),
  )
}

/// Further reading: every #read-more item, grouped by chapter.
#let further-reading() = context {
  let items = query(<tb-read>)
  let chapters = (:)
  for m in items {
    let ch = chapter-label-at(m.location())
    let list = chapters.at(ch, default: ())
    if m.value.url not in list.map(x => x.url) { list.push(m.value) }
    chapters.insert(ch, list)
  }
  set par(justify: false)
  for (ch, list) in chapters {
    text(font: sans, weight: "bold", size: 9pt, fill: accent)[Chapter #ch]
    v(2pt)
    for it in list {
      block(above: 0.5em, below: 0.5em, {
        link(it.url, strong(it.title))
        if it.at("source", default: none) != none { text(fill: muted)[ — #it.source] }
        linebreak()
        text(font: mono, size: 7pt, fill: muted, it.url)
      })
    }
    v(0.6em)
  }
}

/// Credits for every photo placed with #photo(credit: ...).
#let figure-credits() = context {
  let items = query(<tb-credit>)
  if items.len() == 0 { return [No third-party images in this edition.] }
  set par(justify: false)
  for m in items {
    let figs = query(figure.where(kind: image).before(m.location()))
    let num = if figs.len() > 0 {
      let f = figs.last()
      [Figure #chapter-label-at(f.location()).#f.counter.at(f.location()).first()]
    }
    block(above: 0.5em, below: 0.5em, {
      text(weight: "bold", num)
      [ (p. #page-of(m.location())). #m.value.credit.]
      if m.value.source != none { [ #link(m.value.source)] }
    })
  }
}

/// Answer key for every #check-yourself and #problem with an answer.
#let answer-key() = context {
  let items = query(<tb-ans>)
  let chapters = (:)
  for m in items {
    let v = m.value
    let list = chapters.at(v.ch, default: ())
    list.push(v)
    chapters.insert(v.ch, list)
  }
  set par(justify: true)
  for (ch, list) in chapters {
    text(font: sans, weight: "bold", size: 10pt, fill: accent)[Chapter #ch]
    v(4pt)
    for v in list {
      block(above: 0.6em, below: 0.6em, grid(
        columns: (5.2em, 1fr), column-gutter: 6pt,
        text(font: sans, size: 8pt, weight: "bold", if v.kind == "check" [Check #v.label] else [#v.label]),
        if v.answers.len() == 1 { v.answers.first() } else {
          enum(numbering: "a)", tight: true, ..v.answers)
        },
      ))
    }
    v(0.8em)
  }
}
