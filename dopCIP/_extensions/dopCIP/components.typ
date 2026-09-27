// @license MIT
// @copyright 2024 City of Baltimore
//
// Component rendering functions called by the Lua filter (filter.lua) and
// shortcodes (shortcodes.lua). Included in typst-template.typ as a partial, so a
// literal dollar sign must be written as $$.

// Text in an outlined box with an optional title (used by the dop-tag-text
// span handler in filter.lua)
#let dop-tag-text(
  title: none,
  sep: " ",
  text-color: black,
  title-color: rgb("#0082BD"),
  title-weight: "medium",
  title-font: ("Source Sans 3", "Arial", ),
  radius: 0.45em,
  fill: white,
  // Vertical inset adds space between the tag and the lines before and
  // after; outset adds more padding without changing the line spacing
  inset: (x: 0.45em, y: 0.25em),
  outset: (y: 0.2em),
  baseline: 0em,
  thickness: 0.06em,
  body,
  ) = {
    box(
      stroke: (paint: title-color, thickness: thickness),
      inset: inset,
      outset: outset,
      fill: fill,
      radius: radius,
      baseline: baseline,
      if title not in (none, "") {
        text(fill: title-color, font: title-font, weight: title-weight, title + sep)
        text(fill: text-color, body)
      } else {
        text(fill: text-color, body)
      }
    )
}

// Table of contents for the current section (used by the dop-toc shortcode).
// Lists the headings in the section containing this point, up to the next
// heading at the same or a higher level than the section heading. Shows
// nothing if there are no headings to list.
//
// - title: shown above the entries (as text, not a heading)
// - depth: number of levels below the section heading to include (none = all)
// - level: heading level of the section to use (auto = the heading before this
//   point), e.g. 1 for a chapter contents placed under a level 2 heading
// - indent: indent per level; the first level of entries is not indented
#let dop-section-outline(title: none, depth: none, level: auto, indent: 1.5em) = context {
  let here-loc = here()

  // Section heading: the last heading before here (at `level`, if set)
  let section-sel = if level == auto { selector(heading) } else { heading.where(level: level) }
  let previous = query(section-sel.before(here-loc))
  let section-level = if previous.len() > 0 { previous.last().level } else { 0 }

  // Start after the section heading (or here, if there is none), so a
  // chapter contents placed within a section lists the whole chapter
  let start = if previous.len() > 0 { previous.last().location() } else { here-loc }

  // End of the section: the next heading at the same or a higher level
  let next = query(selector(heading).after(here-loc)).filter(it => it.level <= section-level)

  let target = selector(heading).after(start, inclusive: false)
  if next.len() > 0 {
    target = target.before(next.first().location(), inclusive: false)
  }

  let max-level = if depth == none { none } else { section-level + depth }
  let entries = query(target).filter(
    it => it.outlined and (max-level == none or it.level <= max-level)
  )

  if entries.len() > 0 {
    // Title as plain text: outline(title:) adds a heading, which changes the
    // queries above and stops the layout from converging
    if title != none {
      [#block(below: 0.65em, text(weight: "bold", title)) <dop-toc-title>]
    }

    outline(
      title: none,
      target: target,
      depth: max-level,
      // n is the entry's nesting depth (0 for level 1 headings)
      indent: n => calc.max(0, n - section-level) * indent,
    )
  }
}
