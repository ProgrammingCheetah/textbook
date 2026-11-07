// notes.typ — the outer-margin column and full-width ("wide") blocks.
//
// Margin notes are block-level: call them *between* paragraphs, right before
// the paragraph they belong beside. They align with the top of that paragraph
// and stack downward if an earlier note on the same page is in the way.

#import "theme.typ": *

/// True on right-hand (odd) pages.
#let is-recto(page) = calc.odd(page)

/// Left edge of the text column on a given physical page.
#let _text-left(page) = if is-recto(page) { m-inside } else { m-outside }

/// Place `body` in the outer margin beside the following paragraph.
/// `dy` nudges it vertically.
///
/// Stacking is computed from markers (flow position + measured height) of
/// every earlier note on the same page, so layout converges in two passes.
#let margin-note(body, dy: 0pt) = {
  let content = block(width: note-w, {
    set text(font: sans, size: 8.2pt)
    set par(justify: false, leading: 0.55em, spacing: 0.7em)
    body
  })
  context [#metadata((h: measure(content).height, dy: dy))<tb-mnote>]
  context {
    let me = query(selector(<tb-mnote>).before(here())).last()
    let pos = me.location().position()
    let bottom = -1000pt
    let y = 0pt
    for m in query(<tb-mnote>) {
      let mp = m.location().position()
      if mp.page != pos.page { continue }
      y = calc.max(mp.y + m.value.dy, bottom + 6pt)
      bottom = y + m.value.h
      if m.location() == me.location() { break }
    }
    let x = if is-recto(pos.page) { paper-w - m-outside + note-gap } else { m-outside - note-gap - note-w }
    place(top + left, dx: x - _text-left(pos.page), dy: y - m-top, content)
  }
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
