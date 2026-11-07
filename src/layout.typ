// layout.typ — the book shell: page geometry, running heads, cover, front
// matter, chapter openers, appendices and back matter.

#import "theme.typ": *
#import "common.typ": *
#import "notes.typ": *
#import "env.typ": show-env, show-example
#import "boxes.typ": icon

// ---------- running heads ----------

#let _opener-page(p) = (query(heading.where(level: 1)) + query(<tb-part>)).any(h => h.location().page() == p)

#let _blank-page(p) = {
  let next-opens = (query(heading.where(level: 1)) + query(<tb-part>)).any(h => h.location().page() == p + 1)
  let ends = query(<tb-end>).map(e => e.location().page()).filter(x => x <= p)
  next-opens and ends.len() > 0 and ends.last() < p
}

#let _in-main(p) = {
  let m = query(<tb-main>)
  m.len() > 0 and p >= m.first().location().page()
}

#let _span(body) = context {
  if is-recto(here().page()) { block(width: 100% + wide-extra, body) }
  else { move(dx: -wide-extra, block(width: 100% + wide-extra, body)) }
}

#let _header(book-title) = context {
  let p = here().page()
  if not _in-main(p) or _opener-page(p) or _blank-page(p) { return }
  let num = text(font: sans, size: 9pt, weight: "bold", fill: ink, counter(page).display())
  set text(font: sans, size: 7.6pt, fill: muted, tracking: 0.06em)
  if is-recto(p) {
    let secs = query(heading.where(level: 2).before(here()))
    let chs = query(heading.where(level: 1).before(here()))
    let sec = if secs.len() > 0 and chs.len() > 0 and secs.last().location().page() >= chs.last().location().page() {
      let s = secs.last()
      [#if s.numbering != none { numbering(s.numbering, ..counter(heading).at(s.location())) + h(0.6em) }#upper(s.body)]
    } else if chs.len() > 0 { upper(chs.last().body) }
    _span({ grid(columns: (1fr, auto), sec, num); v(-5pt); line(length: 100%, stroke: 0.4pt + rule) })
  } else {
    let chs = query(heading.where(level: 1).before(here()))
    let ch = if chs.len() > 0 {
      let c = chs.last()
      let lbl = if c.numbering == none { none } else if appendix-state.at(c.location()) [Appendix #numbering("A", counter(heading).at(c.location()).first()) · ] else [Chapter #counter(heading).at(c.location()).first() · ]
      [#upper(lbl)#upper(c.body)]
    }
    _span({ grid(columns: (auto, 1fr), num, align(right, upper(book-title) + h(0.8em) + text(fill: rule, "|") + h(0.8em) + ch)); v(-5pt); line(length: 100%, stroke: 0.4pt + rule) })
  }
}

#let _footer = context {
  let p = here().page()
  if _opener-page(p) or not _in-main(p) {
    align(center, text(font: sans, size: 8pt, fill: muted, counter(page).display()))
  }
}

// ---------- chapter openers ----------

#let _chapter-outline(it-loc) = {
  let next = query(heading.where(level: 1).after(it-loc)).filter(h => h.location() != it-loc)
  let secs = query(heading.where(level: 2).after(it-loc))
  // keep only sections before the next chapter heading
  if next.len() > 0 {
    let nl = next.first().location()
    secs = secs.filter(s => {
      let sp = s.location().page()
      let np = nl.page()
      sp < np or (sp == np and s.location().position().y < nl.position().y)
    })
  }
  secs
}

#let _show-chapter(it) = context {
  let p = here().page()
  let app = appendix-state.get()
  let left-m = if is-recto(p) { m-inside } else { m-outside }
  if it.numbering == none or app {
    // light opener: appendices and back matter
    block(width: 100%, above: 0pt, below: 1.6em, {
      v(1.2cm)
      if it.numbering != none {
        label-text([Appendix #counter(heading).display(it.numbering)], color: accent)
        v(4pt)
      }
      text(font: serif, size: 24pt, weight: "bold", fill: ink, it.body)
      v(2pt)
      line(length: 100%, stroke: 1.5pt + ink)
    })
  } else {
    let num = counter(heading).display(it.numbering)
    let band-h = 7.4cm
    block(width: 100%, height: band-h - m-top + 1.2cm, above: 0pt, below: 0pt, {
      place(top + left, dx: -left-m, dy: -m-top, rect(width: paper-w, height: band-h, fill: accent-dark))
      // big number in the outer margin column
      let num-dx = if is-recto(p) { 100% + note-gap } else { -wide-extra }
      place(bottom + left, dx: num-dx, dy: -1.15cm,
        block(width: note-w, align(if is-recto(p) { left } else { right },
          text(font: serif, size: 92pt, weight: "bold", fill: accent-soft.transparentize(15%), num))))
      place(bottom + left, dy: -1.45cm, block(width: 100%, {
        label-text([Chapter #num], color: accent-soft, size: 8pt)
        v(6pt)
        set par(leading: 0.35em, justify: false)
        set text(hyphenate: false)
        text(font: serif, size: 30pt, weight: "bold", fill: white, it.body)
      }))
    })
    // auto chapter outline in the margin
    let secs = _chapter-outline(it.location())
    if secs.len() > 0 {
      margin-note(dy: 0.2cm, {
        label-text([Chapter outline], color: accent)
        v(3pt)
        set text(size: 8pt)
        for s in secs {
          grid(columns: (2.2em, 1fr, auto), column-gutter: 3pt,
            text(fill: accent, weight: "bold", numbering(s.numbering, ..counter(heading).at(s.location()))),
            link(s.location(), s.body),
            text(fill: muted, page-of(s.location())))
          v(-2pt)
        }
      })
    }
    v(0.4cm)
  }
}

/// Start a chapter. Opens on a right-hand page with a full-bleed band, an
/// auto-generated outline in the margin, an optional lead paragraph, an
/// optional opener figure and learning objectives.
#let chapter(title, lead: none, opener: none, objectives: (), label: none) = {
  [#metadata(none)<tb-end>]
  context if appendix-state.get() { pagebreak(weak: true) } else { pagebreak(to: "odd", weak: true) }
  [#heading(level: 1, title)#label]
  if lead != none {
    block(below: 1.2em, text(size: 12.5pt, lead))
  }
  if opener != none { opener }
  if objectives.len() > 0 {
    block(
      width: 100%, stroke: (top: 2pt + ink, bottom: 0.5pt + rule), inset: (y: 10pt), above: 1.4em, below: 1.4em, {
        label-text([In this chapter you will learn to], color: ink)
        v(4pt)
        set text(size: 10pt)
        set par(justify: false)
        list(..objectives)
      })
  }
}

/// Switch to appendices: chapters become "Appendix A", "Appendix B", ...
#let appendix(body) = {
  [#metadata(none)<tb-end>]
  pagebreak(to: "odd", weak: true)
  appendix-state.update(true)
  counter(heading).update(0)
  set heading(numbering: (..n) => {
    let n = n.pos()
    if n.len() == 1 { numbering("A", ..n) } else if n.len() == 2 { numbering("A.1", ..n) }
  })
  body
}

/// An unnumbered back-matter chapter (Glossary, Index, ...).
#let back-chapter(title) = {
  [#metadata(none)<tb-end>]
  pagebreak(weak: true)
  heading(level: 1, numbering: none, title)
}

// ---------- cover and front matter ----------

#let _cover(title, subtitle, series, abstract, meta) = page(
  margin: (x: 2.4cm, top: 0cm, bottom: 0cm), header: none, footer: none, numbering: none, {
    place(top + left, dx: -2.4cm, rect(width: paper-w, height: 9.5cm, fill: accent-dark))
    place(top + left, dx: -2.4cm, dy: 9.5cm, rect(width: paper-w, height: 0.35cm, fill: accent))
    v(3.2cm)
    if series != none { label-text(series, color: accent-soft, size: 8.5pt) }
    v(0.5cm)
    block(width: 85%, {
      set par(leading: 0.3em, justify: false)
      set text(hyphenate: false)
      text(font: serif, size: 40pt, weight: "bold", fill: white, title)
    })
    v(1fr)
    if subtitle != none {
      text(font: serif, size: 18pt, style: "italic", fill: ink, subtitle)
      v(0.4cm)
    }
    if abstract != none {
      block(width: 80%, text(size: 11pt, fill: muted, abstract))
    }
    v(1.4cm)
    if meta.len() > 0 {
      line(length: 100%, stroke: 0.6pt + ink)
      grid(columns: (3.4cm, 1fr), row-gutter: 7pt, column-gutter: 0.6cm,
        ..meta.map(((k, v)) => (label-text(k), text(font: sans, size: 9pt, v))).flatten())
    }
    v(2.2cm)
  },
)

/// The legend of icons and boxes, as used in "Icons used in this book".
#let device-legend() = {
  let row(badge, name, color, desc) = (
    box(width: 100%, inset: (y: 3pt), { if badge != none { badge; h(5pt) }; label-text(name, color: color, size: 7pt) }),
    text(size: 9.6pt, desc),
  )
  let swatch(color, fill, name, desc) = (
    block(width: 100%, fill: fill, stroke: (left: 2.5pt + color), inset: (x: 6pt, y: 5pt),
      label-text(name, color: color, size: 6.8pt)),
    text(size: 9.6pt, desc),
  )
  [In the outer margin, an icon tells you what kind of note you are looking at:]
  v(0.4em)
  grid(columns: (3.6cm, 1fr), row-gutter: 6pt, column-gutter: 10pt, align: horizon,
    ..row(icon("remember"), "Remember", accent, [The one thing from this passage worth keeping. If you read nothing else on the page, read these.]),
    ..row(icon("tip"), "Tip", teal, [A shortcut or habit that saves time, money or a second trip to the store.]),
    ..row(icon("warning"), "Warning", red, [Something that can hurt you, damage a part, or cost you a redo. Never skip these.]),
    ..row(icon("trade"), "In the trade", green, [How professionals actually do it.]),
    ..row(icon("key"), "Key term", blue, [A word you will meet again. All of them are collected in the Glossary.]),
    ..row(icon("fact"), "Did you know?", purple, [A curious fact. Safe to skip.]),
  )
  v(0.6em)
  [In the main column, colored boxes carry the structure of the lesson:]
  v(0.4em)
  grid(columns: (3.6cm, 1fr), row-gutter: 6pt, column-gutter: 10pt, align: horizon,
    ..swatch(blue, blue-soft, "Definition", [Fixes the meaning of a word. Numbered so you can find it again.]),
    ..swatch(accent, accent-soft, "Theorem · Principle", [A rule the build depends on. Theorems come with a short proof when the reasoning is the point.]),
    ..swatch(accent, white, "Worked example", [Real numbers from the build, solved step by step.]),
    ..swatch(teal, teal-soft, "Why it works", [The physical picture behind a rule, so you can rebuild it from memory.]),
    ..swatch(sepia, sepia-soft, "A bit of history", [Where an idea or a standard came from, and why it stuck.]),
    ..swatch(ink, shade, "Before you begin", [What you should already know, and where to catch up.]),
    ..swatch(muted, shade, "Deep dive", [Technical detail the build does not need. Safe to skip.]),
    ..swatch(red, red-soft, "Common mistake", [What people get wrong, what to do instead, and why.]),
    ..swatch(blue, white, "Check yourself", [Two or three quick questions at the end of a section. Answers at the back.]),
    ..swatch(accent, white, "Read more", [Hand-picked articles, datasheets and videos to go deeper. All collected again in Further Reading.]),
  )
}

#let _how-to-read() = {
  heading(level: 1, numbering: none, outlined: false, [How to use this book])
  device-legend()
}

/// The Introduction, in the classic reference-book order. Goes first in the
/// main matter. Every argument is optional.
///
/// - about: what the book covers and how it is organized.
/// - assumptions: array of things you assume about the reader.
/// - beyond: what lives outside the book (cheat sheet, repo, configs).
/// - where-next: where to start, depending on the reader.
#let introduction(about: none, assumptions: (), beyond: none, where-next: none) = {
  [#metadata(none)<tb-end>]
  pagebreak(to: "odd", weak: true)
  heading(level: 1, numbering: none, [Introduction])
  let sec(t) = heading(level: 2, numbering: none, outlined: false, t)
  if about != none { sec[About this book]; about }
  if assumptions.len() > 0 {
    sec[What I assume about you]
    [This book makes a few assumptions about you. If they fit, you are in the right place:]
    list(..assumptions)
  }
  sec[Icons used in this book]
  device-legend()
  if beyond != none { sec[Beyond the book]; beyond }
  if where-next != none { sec[Where to go from here]; where-next }
}

// ---------- parts ----------

/// A part divider: a full right-hand page that groups chapters.
#let part(title, blurb: none) = {
  [#metadata(none)<tb-end>]
  pagebreak(to: "odd", weak: true)
  counter("tb-part").step()
  context {
    let n = counter("tb-part").get().first()
    [#metadata((title: title, num: n))<tb-part>]
    let p = here().page()
    let left-m = if is-recto(p) { m-inside } else { m-outside }
    place(top + left, dx: -left-m, dy: -m-top, rect(width: paper-w, height: 100% + m-top + m-bottom, fill: accent-dark))
    v(4cm)
    label-text([Part #numbering("I", n)], color: accent-soft, size: 10pt)
    v(0.3cm)
    block(width: 100% + wide-extra, {
      set par(leading: 0.3em, justify: false)
      set text(hyphenate: false)
      text(font: serif, size: 40pt, weight: "bold", fill: white, title)
    })
    v(0.8cm)
    line(length: 4cm, stroke: 2pt + accent)
    if blurb != none {
      v(0.6cm)
      block(width: 100%, text(size: 12pt, fill: white, blurb))
    }
    // chapters in this part
    let here-loc = here()
    let next = query(<tb-part>).filter(m => m.location().page() > p)
    let chs = query(heading.where(level: 1).after(here-loc)).filter(h => h.numbering != none and not appendix-state.at(h.location()))
    if next.len() > 0 { chs = chs.filter(h => h.location().page() < next.first().location().page()) }
    if chs.len() > 0 {
      v(1fr)
      label-text([In this part], color: accent-soft)
      v(4pt)
      set text(fill: white, size: 10pt)
      for h in chs {
        grid(columns: (2em, 1fr), text(weight: "bold", fill: accent-soft, str(counter(heading).at(h.location()).first())), h.body)
        v(-2pt)
      }
      v(1cm)
    }
  }
}

// ---------- contents ----------

#let _toc(glance: false) = context {
  let items = query(selector(<tb-part>).or(heading.where(level: 1)).or(heading.where(level: 2)))
  items = items.filter(it => it.func() == metadata or (it.outlined and (not glance or it.level == 1)))
  for it in items {
    let loc = it.location()
    let pg = link(loc, page-of(loc))
    let dots = box(width: 1fr, repeat(text(fill: rule)[.#h(3pt)]))
    if it.func() == metadata {
      block(above: 1.4em, below: 0.5em, link(loc, text(font: sans, size: 8.6pt, weight: "bold", fill: accent, tracking: 0.06em,
        upper[Part #numbering("I", it.value.num): #it.value.title])))
    } else if it.level == 1 {
      let num = if it.numbering != none { numbering(it.numbering, ..counter(heading).at(loc)) }
      block(above: if glance { 0.5em } else { 0.9em }, below: 0.3em, text(font: serif, weight: "bold",
        grid(columns: (1.8em, 1fr), num, link(loc, [#it.body #dots #pg]))))
    } else {
      let num = if it.numbering != none { numbering(it.numbering, ..counter(heading).at(loc)) }
      block(above: 0.25em, below: 0.25em, pad(left: 1.8em, text(size: 9.6pt,
        grid(columns: (2.4em, 1fr), num, link(loc, [#it.body #dots #pg])))))
    }
  }
}

// ---------- the book ----------

/// Wrap the whole document: #show: book.with(title: [...], ...)
///
/// - meta: array of (label, value) pairs printed on the cover.
/// - lists: print List of Figures and List of Tables in the front matter.
#let book(
  title: [Untitled],
  short-title: none,
  subtitle: none,
  series: none,
  abstract: none,
  author: "",
  meta: (),
  how-to-read: false,
  glance: true,
  cheat-sheet: none,
  lists: true,
  body,
) = {
  let short = if short-title == none { title } else { short-title }
  set document(title: plain(title), author: author)
  set page(
    paper: "us-letter",
    margin: (inside: m-inside, outside: m-outside, top: m-top, bottom: m-bottom),
    header: _header(short),
    footer: _footer,
    numbering: "i",
  )
  set text(font: serif, size: 10.5pt, fill: ink, lang: "en", hyphenate: true)
  set par(justify: true, leading: 0.68em, spacing: 1.05em)
  set list(indent: 0.4em, marker: text(fill: accent, "▪"))
  set enum(indent: 0.2em)
  show raw: set text(font: mono, size: 8.2pt)
  show raw.where(block: true): it => block(width: 100%, fill: shade, inset: 10pt, radius: 3pt, it)
  show link: set text(fill: accent)
  show cite: set text(fill: accent)
  show ref: set text(fill: accent)

  // numbering: everything per chapter
  set heading(numbering: (..n) => {
    let n = n.pos()
    if n.len() <= 2 { numbering("1.1", ..n) }
  })
  set figure(numbering: n => chapter-label() + "." + str(n))
  set math.equation(numbering: n => "(" + chapter-label() + "." + str(n) + ")")

  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: "env")).update(0)
    counter(figure.where(kind: "example")).update(0)
    counter(math.equation).update(0)
    counter("tb-problem").update(0)
    _show-chapter(it)
  }
  show heading.where(level: 2): it => block(above: 1.7em, below: 0.75em, sticky: true, {
    set text(font: serif, size: 15pt, weight: "bold")
    if it.numbering != none {
      text(fill: accent, counter(heading).display(it.numbering))
      h(0.55em)
    }
    it.body
  })
  show heading.where(level: 3): it => block(above: 1.3em, below: 0.55em, sticky: true,
    text(font: serif, size: 11.5pt, weight: "bold", style: "italic", it.body))

  // figures
  show figure.where(kind: "env"): show-env
  show figure.where(kind: "example"): show-example
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set block(breakable: true)
  show figure.caption: it => context {
    set text(font: sans, size: 8pt)
    set par(justify: false)
    block(width: 100%, inset: (x: 0.4cm), {
      text(weight: "bold")[#it.supplement #it.counter.display(it.numbering)]
      h(0.5em)
      text(fill: muted, it.body)
    })
  }
  show table: set text(font: sans, size: 8.4pt)
  set table(align: left)
  set table(stroke: (x, y) => (top: if y <= 1 { 0.8pt } else { 0.3pt + rule }, bottom: 0.8pt), inset: (x: 6pt, y: 5pt))
  show table.cell.where(y: 0): set text(weight: "bold")

  // ----- front matter -----
  _cover(title, subtitle, series, abstract, meta)
  if cheat-sheet != none {
    page(header: none, footer: none, margin: (x: 1.6cm, y: 1.6cm), {
      block(width: 100%, height: 100%, stroke: 2pt + accent-dark, inset: 14pt, {
        grid(columns: (1fr, auto), align: bottom,
          text(font: serif, size: 22pt, weight: "bold")[Cheat Sheet],
          text(font: sans, size: 8pt, fill: muted, title))
        v(-4pt)
        line(length: 100%, stroke: 1pt + accent-dark)
        columns(2, gutter: 14pt, cheat-sheet)
      })
    })
  }
  if glance {
    heading(level: 1, numbering: none, outlined: false, [Contents at a glance])
    _toc(glance: true)
  }
  pagebreak(weak: true)
  heading(level: 1, numbering: none, outlined: false, [Contents])
  _toc()
  if how-to-read { pagebreak(weak: true); _how-to-read() }
  if lists {
    pagebreak(weak: true)
    heading(level: 1, numbering: none, outlined: false, [List of figures])
    outline(title: none, target: figure.where(kind: image))
    v(1cm)
    heading(level: 1, numbering: none, outlined: false, [List of tables])
    outline(title: none, target: figure.where(kind: table))
  }

  // ----- main matter -----
  pagebreak(to: "odd", weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata(none)<tb-main>]
  body
}
