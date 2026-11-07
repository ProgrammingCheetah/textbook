// common.typ — shared state and helpers used across modules.

#let appendix-state = state("tb-appendix", false)

/// Formatted number of the chapter at the current location: "1", "2", ... or
/// "A", "B", ... in the appendices. Call inside `context`.
#let chapter-label() = {
  let n = counter(heading).get().first()
  if appendix-state.get() { numbering("A", n) } else { str(n) }
}

/// Same as chapter-label, at an arbitrary location.
#let chapter-label-at(loc) = {
  let n = counter(heading).at(loc).first()
  if appendix-state.at(loc) { numbering("A", n) } else { str(n) }
}

/// Displayed page number (respecting roman front matter) of a location.
#let page-of(loc) = {
  let nums = loc.page-numbering()
  if nums == none { str(loc.page()) } else { numbering(nums, ..counter(page).at(loc)) }
}

/// Plain-text form of simple content, for sorting and lookup.
#let plain(x) = {
  if type(x) == str { x }
  else if x.func() == [ ].func() { " " }
  else if x.has("text") { x.text }
  else if x.has("children") { x.children.map(plain).join("") }
  else if x.has("body") { plain(x.body) }
  else { "" }
}
