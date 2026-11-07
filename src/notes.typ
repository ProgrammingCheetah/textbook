// notes.typ — the outer-margin column and full-width ("wide") blocks.
//
// Margin notes are block-level: call them *between* paragraphs, right before
// the paragraph they belong beside. They align with the top of that paragraph
// and stack downward if an earlier note on the same page is in the way.

#import "theme.typ": *

#let _mstate = state("tb-margin", (page: 0, bottom: 0pt))

/// True on right-hand (odd) pages.
#let is-recto(page) = calc.odd(page)

/// Left edge of the text column on a given physical page.
#let _text-left(page) = if is-recto(page) { m-inside } else { m-outside }

/// Place `body` in the outer margin beside the following paragraph.
/// `dy` nudges it vertically.
#let margin-note(body, dy: 0pt) = context {
  let pos = here().position()
  let content = block(width: note-w, {
    set text(font: sans, size: 8.2pt)
    set par(justify: false, leading: 0.55em, spacing: 0.7em)
    body
  })
  let h = measure(content).height
  let prev = _mstate.get()
  let y = pos.y + dy
  if prev.page == pos.page and y < prev.bottom + 6pt { y = prev.bottom + 6pt }
  _mstate.update((page: pos.page, bottom: y + h))
  let x = if is-recto(pos.page) { paper-w - m-outside + note-gap } else { m-outside - note-gap - note-w }
  place(top + left, dx: x - _text-left(pos.page), dy: y - m-top, content)
}

/// A block that spans the text column plus the margin column.
/// Use for wide tables, figures and appendices.
#let wide(body) = context {
  if is-recto(here().page()) {
    block(width: 100% + wide-extra, body)
  } else {
    move(dx: -wide-extra, block(width: 100% + wide-extra, body))
  }
}
