// theme.typ — palette, fonts and page geometry shared by every book.
// Change the series look here; books should not override colors locally.

// ---------- palette ----------
#let ink = rgb("#1d201e")
#let muted = rgb("#5b625d")
#let rule = rgb("#c9cec7")
#let shade = rgb("#f2f3f1")

#let accent = rgb("#b5651a")        // chapter numbers, section numbers, links
#let accent-dark = rgb("#7a3f0c")   // chapter opener band
#let accent-soft = rgb("#f7e8d6")   // theorems, principles

#let blue = rgb("#2c5e8a")          // definitions, key terms
#let blue-soft = rgb("#e3edf6")
#let red = rgb("#a4361f")           // watch out, common mistakes
#let red-soft = rgb("#f8e2dc")
#let green = rgb("#3d6b3f")         // in the trade, right answers
#let green-soft = rgb("#e3efe2")
#let sepia = rgb("#7d5a2c")         // history
#let sepia-soft = rgb("#f3ead9")
#let teal = rgb("#2f6f73")          // why it works (intuition)
#let teal-soft = rgb("#e0eeee")
#let purple = rgb("#6b4c8a")        // did you know
#let purple-soft = rgb("#ece6f3")

// ---------- fonts ----------
// Pagella (Palatino) for text and headings, Heros (Helvetica) for labels and
// margin notes. Both ship in ../fonts; compile with --font-path fonts.
#let serif = ("TeX Gyre Pagella", "Libertinus Serif")
#let sans = ("TeX Gyre Heros", "Liberation Sans", "DejaVu Sans")
#let mono = ("DejaVu Sans Mono",)

// ---------- geometry (US Letter, two-sided) ----------
#let paper-w = 8.5in
#let m-inside = 2.0cm
#let m-outside = 6.6cm
#let m-top = 2.5cm
#let m-bottom = 2.3cm
#let note-gap = 0.6cm
#let note-w = 4.6cm
#let wide-extra = note-gap + note-w     // how far a wide block reaches into the margin

// ---------- small typographic helpers ----------
#let label-text(body, color: muted, size: 7.4pt) = text(
  font: sans, size: size, weight: "bold", fill: color, tracking: 0.08em, upper(body),
)
