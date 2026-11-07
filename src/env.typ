// env.typ — numbered statements (definitions, theorems, ...), proofs and
// worked examples. All statements share one counter per chapter, so the
// reader can find "Theorem 1.6" between "Definition 1.5" and "Definition 1.7".
// Label any of them and reference with @label, or with #pref(<label>) to add
// the page number.

#import "theme.typ": *

// supplement -> (bar color, fill)
#let _env-styles = (
  "Definition": (blue, blue-soft),
  "Theorem": (accent, accent-soft),
  "Law": (accent, accent-soft),
  "Principle": (accent, accent-soft),
  "Corollary": (accent, accent-soft),
  "Lemma": (accent, accent-soft),
  "Rule": (green, green-soft),
)

#let _env(kind-name) = (title: none, body) => figure(
  body,
  kind: "env",
  supplement: kind-name,
  caption: title,
  outlined: false,
)

#let definition = _env("Definition")
#let theorem = _env("Theorem")
#let law = _env("Law")
#let principle = _env("Principle")
#let corollary = _env("Corollary")
#let lemma = _env("Lemma")
#let rule-env = _env("Rule")

#let show-env(it) = {
  let name = it.supplement.text
  let (bar, fill) = _env-styles.at(name, default: (accent, accent-soft))
  set math.equation(numbering: none)
  block(
    width: 100%, breakable: true, fill: fill, stroke: (left: 2.5pt + bar),
    inset: (left: 12pt, right: 10pt, y: 8pt), above: 1.1em, below: 1.1em,
    {
      set align(left)
      set par(justify: true)
      text(font: sans, weight: "bold", size: 9pt, fill: bar)[#name #it.counter.display(it.numbering)]
      if it.caption != none {
        text(font: sans, size: 9pt, fill: bar)[ (#it.caption.body)]
      }
      h(0.5em)
      it.body
    },
  )
}

/// Proof (or justification) of the statement above it.
#let proof(title: [Proof], body) = block(
  inset: (left: 12pt), above: 0.6em, below: 1.1em, width: 100%,
  {
    emph(title + [.])
    h(0.4em)
    body
    h(1fr)
    sym.square.stroked
  },
)

/// A worked example. `steps` is an array of (label, content) pairs, shown as
/// a two-column grid; or pass free content as the body.
#let example(title: none, steps: (), body) = figure(
  {
    if steps.len() > 0 {
      grid(
        columns: (1.6cm, 1fr), row-gutter: 0.75em, column-gutter: 0.5em,
        ..steps.map(((l, c)) => (label-text(l, color: accent, size: 7pt), c)).flatten(),
      )
    }
    body
  },
  kind: "example",
  supplement: "Example",
  caption: title,
  outlined: false,
)

#let show-example(it) = {
  set math.equation(numbering: none)
  block(
    width: 100%, breakable: true, stroke: 0.8pt + accent, radius: 3pt, clip: true,
    above: 1.1em, below: 1.1em,
    {
      block(width: 100%, fill: accent, inset: (x: 10pt, y: 6pt), below: 0pt,
        text(font: sans, size: 8.4pt, weight: "bold", fill: white, tracking: 0.04em,
          upper[Worked example #it.counter.display(it.numbering)#if it.caption != none [ · #it.caption.body]]))
      block(width: 100%, inset: (x: 10pt, y: 9pt), above: 0pt, {
        set align(left)
        set par(justify: false)
        it.body
      })
    },
  )
}
