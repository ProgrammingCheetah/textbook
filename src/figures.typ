// figures.typ — photos with credits, and a placeholder for photos not yet
// sourced. Every credited photo is listed in the back-matter Figure Credits.

#import "theme.typ": *

/// A framed stand-in for a photo you have not fetched yet. Describes what
/// should go there so the gap is visible in drafts.
#let placeholder(what, height: 4.5cm) = rect(
  width: 100%, height: height, fill: shade, stroke: (dash: "dashed", paint: rule, thickness: 0.8pt),
  align(center + horizon, {
    text(font: sans, size: 7.4pt, weight: "bold", fill: muted, tracking: 0.08em, upper[Photo to source])
    linebreak()
    text(font: sans, size: 8.4pt, fill: muted, what)
  }),
)

/// A photo or third-party image as a numbered figure with a credit line.
///
/// - src: path to the image, or none to draw a placeholder of `alt`.
/// - credit: author and license, e.g. "Jane Doe, CC BY-SA 4.0".
/// - source: URL of the original page (shown in Figure Credits).
///
/// Attach a label after the call: #photo(...) <fig:strip>
#let photo(src, caption: none, alt: none, credit: none, source: none, width: 100%, height: auto) = {
  let img = if src == none {
    placeholder(if alt == none { [ ] } else { alt }, height: if height == auto { 4.5cm } else { height })
  } else {
    image(src, width: width, height: height, alt: alt)
  }
  figure(kind: image, caption: caption, {
    img
    if credit != none {
      [#metadata((credit: credit, source: source, caption: caption))<tb-credit>]
      v(-0.35em)
      align(right, text(font: sans, size: 6.6pt, fill: muted)[#credit])
    }
  })
}
