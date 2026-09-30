// import hydra package for header/footer
#import "@preview/hydra:0.6.3": hydra, anchor, selectors

// Parse date function for quarto-invoice
//
// Source: https://github.com/mcanouil/quarto-invoice/blob/main/_extensions/invoice/typst-template.typ
// MIT License

// Copyright (c) 2024 Mickaël Canouil

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// License: https://github.com/mcanouil/quarto-invoice/blob/main/LICENSE
#let parse-date(date) = {
  let date = date.replace("\\", "")
  let date = str(date).split("-").map(int)
  datetime(year: date.at(0), month: date.at(1), day: date.at(2))
}

// Default if value is none or empty array (similar to %||% from rlang)
#let ifnone(x, default) = {
  if x == none {
    return default
  }

  if x == () {
    return default
  }

  x
}

// Convert a numeric font weight from metadata (e.g. "600") to an integer;
// weight names (e.g. "semibold") are returned unchanged
#let as-weight(weight) = {
  if type(weight) == str and weight.codepoints().all(c => c in "0123456789") {
    return int(weight)
  }

  weight
}

// Component rendering functions (dop-tag-text, dop-table-label,
// dop-secondary-header, dop-color-bar, dop-section-page, dop-section-outline)
$components.typ()$

//------------------------------------------------------------------------------
// Document Template
//------------------------------------------------------------------------------

#let article(
  // Document attributes
  title: none,
  subtitle: none,
  authors: none,
  keywords: (), // FIXME: Expose this argument
  abstract: none,
  abstract-title: none,
  lang: "en",
  region: "US",

  // Dates and before date text
  date: none,
  date-modified: none,

  before-date: "Published",
  before-date-modified: "Last updated",

  // Page layout
  cols: 1,
  gutter: 4%,
  margin: (x: 1in, y: 1.25in),
  // Individual margins (take precedence over margin)
  margin-top: none,
  margin-bottom: none,
  margin-left: none,
  margin-right: none,
  paper: "us-letter",
  flipped: false,

  // Typography

  font: ("Lora", "Georgia", "Libertinus Serif", ),
  fontsize: 11pt,
  monofont: ("Source Code Pro", "DejaVu Sans Mono", ),

  // Body text typography

  justify: false,
  linebreaks: "optimized",
  first-line-indent: 0pt,
  hanging-indent: 0pt,
  leading: 0.75em,
  spacing: 1.25em,

  // Heading typography

  heading-font: ("Raleway", "Arial", ),
  heading-fontsize: 1.4em,
  heading-weight: "bold",
  heading-style: "normal",
  sectionnumbering: none,

  // Title typography

  title-font: (),
  title-fontsize: 3em,
  title-weight: "bold",
  subtitle-weight: "medium",
  title-align: left,
  title-inset: 0pt,
  title-leading: 1.35em,

  // Colors

  accentcolor: "#0082BD",
  accentcolor-light: "#FCB826",
  accentcolor-dark: "#00415F",
  linkcolor: "#00415F",

  // Table settings
  table-font: ("Source Sans 3", "Arial", ),
  caption-font: ("Raleway", "Arial", ),
  caption-align: left,

  show-cover: true,
  // Show title in a colored band at the top of the first page (replaces cover)
  show-title-band: false,
  breakable-tables: true,

  // Table of contents

  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,

  // List of figures and list of tables

  lof: false,
  lof-title: [List of Figures],
  lot: false,
  lot-title: [List of Tables],

  // Page numbering (none hides the page number in the header and footer)

  page-numbering: "1",
  page-number-align: right + bottom,

  // Running header and footer: content for the left and right of each, as
  // one of "title", "heading-1", "heading-2", "page-number", or "none".
  // Sides that are not set use the defaults in article().
  page-header: (:),
  page-footer: (:),

  logo-align: left,
  // Scale factor for logo heights (e.g. 0.75 to make room for a long title)
  logo-scale: 1,
  // Show the city logo in the top-right corner of the title band
  title-band-logo: false,

  // Footer

  footer-font: (),
  footer-descent: 30%,

  doc,
) = {

  // Set fonts from defaults
  heading-font = ifnone(heading-font, font)
  table-font = ifnone(table-font, font)
  title-font = ifnone(title-font, heading-font)
  footer-font = ifnone(footer-font, heading-font)
  caption-font = ifnone(caption-font, heading-font)

  // Convert numeric weights from metadata to integers
  heading-weight = as-weight(heading-weight)
  title-weight = as-weight(title-weight)
  subtitle-weight = as-weight(subtitle-weight)

  // Set font sizes from defaults
  heading-fontsize = ifnone(heading-fontsize, fontsize)
  let cover-fontsize = title-fontsize * 0.5

  // Set colors
  accentcolor = rgb(accentcolor)
  accentcolor-light = rgb(accentcolor-light)
  accentcolor-dark = rgb(accentcolor-dark)
  linkcolor = rgb(linkcolor)

  // Add individual margins (e.g. margin-top) to the margin dictionary
  if type(margin) != dictionary {
    margin = (rest: margin)
  }

  for (side, value) in (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right) {
    if value != none {
      margin.insert(side, value)
    }
  }

  // Top margin (used to extend the title band to the top edge of the page)
  let page-margin-top = margin.at(
    "top",
    default: margin.at("y", default: margin.at("rest", default: 2.5cm)),
  )

  // Format dates for cover page and title band
  let cover-date-format = "[month repr:long] [day padding:none], [year]"

  if date != none {
    date = parse-date(date).display(cover-date-format)
  }

  // Date modified is always shown (defaults to today)
  if date-modified == none {
    date-modified = datetime.today().display(cover-date-format)
  } else {
    date-modified = parse-date(date-modified).display(cover-date-format)
  }

  // Level 1 headings shown in the running header and footer (excludes
  // headings not in the ToC, such as the ToC title)
  let section-heading = selectors.custom(
    heading.where(level: 1),
    filter: (ctx, e) => e.outlined,
  )

  // Running header and footer content, with defaults for sides not set
  // (typst-show.typ passes () if neither side is set)
  if type(page-header) != dictionary { page-header = (:) }
  if type(page-footer) != dictionary { page-footer = (:) }
  page-header = (left: "heading-2", right: "none") + page-header
  page-footer = (left: "heading-1", right: "page-number") + page-footer

  // Content for one side of the running header or footer (call in context)
  // Headings are left empty on section pages (dop-section-page div), where
  // hydra would show the section before the one starting on the page
  let on-section-page() = query(<dop-section-page>).any(it => it.location().page() == here().page())

  let page-slot(key, option) = if key == "title" {
    title
  } else if key == "heading-1" {
    if not on-section-page() { hydra(section-heading) }
  } else if key == "heading-2" {
    if not on-section-page() { hydra(2) }
  } else if key == "page-number" {
    // Show the total pages if the pattern has two counting symbols (e.g.
    // "1 / 1"), as Typst does for page numbering
    if page-numbering != none {
      counter(page).display(
        page-numbering,
        both: page-numbering.matches(regex("[1aAiI*]")).len() > 1,
      )
    }
  } else if key in ("none", none) {
    none
  } else {
    panic(option + ": unknown value \"" + key +
      "\" (use title, heading-1, heading-2, page-number, or none)")
  }

  // Header and footer are hidden (including the line) if both sides are none
  let show-page-header = page-header.values().any(it => it not in ("none", none))
  let show-page-footer = page-footer.values().any(it => it not in ("none", none))

  // Formats the author's names in a list with commas and a
  // final "and".
  authors = ifnone(authors, ())
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: ", and ")
  }

  set page(
    paper: paper,
    margin: margin,
    flipped: flipped,
    numbering: page-numbering,
    number-align: page-number-align,

    header: context if (query(<title-band>) + query(<dop-section-page>)).any(it => it.location().page() == here().page()) {
      // No running header above the title band or on a section page (hydra
      // still needs an anchor)
      anchor()
    } else if show-cover and counter(page).get().first() == 1 {
      // No running header on the cover page
      none
    } else if not show-page-header {
      // No running header (hydra still needs an anchor)
      anchor()
    } else {[
      #anchor()
      // running header (page-header option)
      #text(
        font: footer-font,
        weight: "medium",
        baseline: 0.65em,
        fill: accentcolor-dark)[
            #upper[
              #page-slot(page-header.left, "page-header") #h(1fr) #page-slot(page-header.right, "page-header")
            ]
      ]
      #line(length: 100%, stroke: 0.5pt)
    ]},

    footer: context if show-page-footer and (counter(page).get().first() > 1 or not show-cover) {[
        #line(length: 100%, stroke: 0.5pt)
        // running footer (page-footer option)
        #text(
          font: footer-font,
          fill: accentcolor-dark,
          baseline: -0.5em)[
          #upper[
            #page-slot(page-footer.left, "page-footer") #h(1fr) #page-slot(page-footer.right, "page-footer")
          ]
        ]
    ]},
    footer-descent: footer-descent,
  )

  // Set document metadata
  set document(title: title, author: names, keywords: keywords,)

  // Set paragraph properties
  set par(
    leading: leading,
    spacing: spacing,
    justify: justify,
    linebreaks: linebreaks,
    first-line-indent: first-line-indent,
    hanging-indent: hanging-indent,

  )

  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize,
           slashed-zero: true)

  // Set heading typography
  set heading(numbering: sectionnumbering)

  show heading: it => {
    set text(
      font: heading-font,
      weight: heading-weight,
      style: heading-style,
      size: if it.level < 3 {
        heading-fontsize
      } else if it.level < 4 {
        heading-fontsize * 0.95
      } else if it.level < 5 {
        heading-fontsize * 0.85
      } else {
        heading-fontsize * 0.75
      },

    )

    it
  }

  // Set font for inline code and blocks
  show raw: set text(font: monofont)

  // Set linkcolor
  show link: set text(fill: linkcolor)

  // Set up ToC
  // https://typst.app/docs/reference/model/outline/#definitions-entry
  set outline(
    indent: 2em
  )

  set outline.entry(fill: none)

  // Section ToC titles (dop-toc shortcode) use the heading font
  show <dop-toc-title>: set text(font: heading-font)

  // Table labels (dop-table-label span) match the table font and accent color
  show <dop-table-label>: set text(font: table-font, fill: accentcolor)

  // Secondary headers (dop-secondary-header span) match the running header
  show <dop-secondary-header>: set text(font: heading-font, fill: accentcolor-dark)

  // Section pages (dop-section-page div): larger text (heading sizes are
  // relative, so the heading is also larger) above a bar matching the cover
  show <dop-section-page-body>: set text(size: 1.2em)
  show <dop-section-page-bar>: set rect(fill: accentcolor-light)

  // Set ToC entry typography per level, keeping the page number in a
  // consistent font and weight across all levels (only the heading label
  // varies)
  show outline.entry: it => context {
    // Link to the heading or figure, as the default outline entry does
    // (rebuilding the entry from its parts drops the link). Keep the text
    // color from outside the link so linkcolor isn't applied to entries.
    let fill = text.fill
    let linked(body) = link(it.element.location(), text(fill: fill, body))

    // List of figures and list of tables entries
    if it.element.func() == figure {
      return linked(it.indented(
        text(font: heading-font)[#it.prefix()],
        text(font: heading-font)[#it.body()] + h(1fr) + text(font: heading-font)[#it.page()],
      ))
    }

    if it.level == 1 {
      v(12pt, weak: true)
    }

    let label = if it.level == 1 {
      text(font: heading-font, size: 1.1em, weight: "bold")[#it.body()]
    } else if it.level == 2 {
      text(font: heading-font, size: 1em)[#it.body()]
    } else {
      text(font: heading-font)[#it.body()]
    }

    let page-number = text(font: heading-font, weight: "regular")[#it.page()]

    linked(it.indented(it.prefix(), label + h(1fr) + page-number))
  }

  // Set figure caption font and color
  show figure.caption: set text(
    fill: accentcolor,
    font: caption-font,
  )

  // Set figure caption alignment
  // show figure.caption: set block(
  //   align: caption-align,
  // )

  // Set table typography
  show table: set text(font: table-font)

  // Make quarto-float-tbl figures breakable
  // See docs for implementation https://typst.app/docs/reference/model/figure/#figure-behaviour
  // See SO for inspiration https://stackoverflow.com/a/78727447
  show figure.where(
    kind: "quarto-float-tbl"
  ): set block(breakable: true) if breakable-tables

  // Set term list formatting

  // FIXME: Customize term list formatting without hard-coding type and colors
  show terms: it => pad(
    left: it.indent + it.hanging-indent,
    stack(
      ..it.children.map(item => {
        h(-it.hanging-indent)
        text(
          font: table-font,
          size: 0.9em,
          fill: accentcolor,
          baseline: 0.5em,
        )[#strong(item.term)]
        it.separator
        item.description
      }),
      spacing: if it.tight {
        par.leading
      } else if it.spacing == auto {
        1.2em // block.below doesn't work yet
      } else {
        it.spacing
      },
    )
  )

if show-cover [
  // Show title
  #if title != none {
    v(10%)
    align(title-align)[#block(inset: title-inset)[
      #par(leading: title-leading)[
        #text(font: title-font, weight: title-weight, size: title-fontsize)[#upper[#title]]
      ]
    ]]

    // Show subtitle (only if title is provided)
    if subtitle != none {
      v(2%)
      align(title-align)[#block(inset: title-inset)[
        #par(leading: 0.65em)[
          #text(font: title-font, fill: luma(45), weight: subtitle-weight, size: title-fontsize * 0.85)[#upper[#subtitle]]
        ]
      ]]
    }
  }

  // Show color bar on title page
  #v(4%)
  #dop-color-bar(fill: accentcolor-light)
  #v(4%)

  // Show authors
  #if authors.len() > 0 {
    align(title-align)[#block(inset: title-inset)[
        #text(weight: "bold", size: cover-fontsize)[#author-string]
      ]]
    v(1%)
  }

  #place(
    bottom + logo-align,
    grid(
      columns: (2.5in * logo-scale, 2.5in * logo-scale),
      gutter: 0in,
      align: logo-align + horizon,
        image(
              "baltimore-city-dop-logo.png",
              height: 1.75in * logo-scale,
              fit: "contain"
          ),
          image(
            "baltimore-city-logo.png",
            height: 1.5in * logo-scale,
            fit: "contain"
          )
      )
    )

  // Show date
  #if date != none {
    align(title-align)[#block(inset: title-inset)[
      #text(size: cover-fontsize * 0.8)[#before-date #date]
    ]]
  }

  // Show date modified (always)
  #align(title-align)[#block(inset: title-inset)[
    #text(size: cover-fontsize * 0.8)[#before-date-modified #date-modified]
  ]]

  #pagebreak()
]

  // Title band (document text follows on the same page)
  let title-band-block = if show-title-band {
    block(
      width: 100%,
      fill: accentcolor-dark,
      outset: (x: 100%, top: page-margin-top),
      inset: (bottom: 1.5em),
      stroke: (bottom: 0.5em + accentcolor-light),
      below: 2em,
    )[
      // Label used to hide the running header on the title band page
      #metadata(none) <title-band>

      #set text(fill: white)
      #set par(linebreaks: "simple")

      #let band-text = [
        #set align(title-align)

        #if title != none {
          par(leading: 0.5em)[
            #text(font: title-font, weight: title-weight, size: title-fontsize * 0.75)[#upper[#title]]
          ]
        }

        #if subtitle != none {
          par(leading: 0.5em)[
            #text(font: title-font, weight: subtitle-weight, size: title-fontsize * 0.4)[#upper[#subtitle]]
          ]
        }

        #text(font: footer-font, size: 0.9em)[
          // Authors, date, and date modified on separate lines
          #if authors.len() > 0 [#box(author-string) \ ]
          #if date != none [#box[#before-date #date] \ ]
          #box[#before-date-modified #date-modified]
        ]
      ]

      // Title text with optional logo in the top-right corner
      #if title-band-logo {
        grid(
          columns: (1fr, auto),
          column-gutter: 1.5em,
          align: top,
          band-text,
          image("baltimore-city-logo.png", height: 1in * logo-scale, fit: "contain"),
        )
      } else {
        band-text
      }
    ]
  }

  // Abstract
  let abstract-block = if abstract != none {
    block(inset: title-inset)[
    #text(weight: "semibold")[$labels.abstract$] #h(1em) #abstract
    ]
  }

  // ToC, list of figures, and list of tables (each only shown if it has
  // entries), with an optional page break after them
  let contents-block(pagebreak-after: false) = context {
    let shown = false

    if toc {
      let entries = query(heading.where(outlined: true)).filter(
        it => toc_depth == none or it.level <= toc_depth
      )

      if entries.len() > 0 {
        block(above: 0em, below: 2em)[
        #outline(
          title: toc_title,
          depth: toc_depth,
          indent: toc_indent
        );
        ]
        shown = true
      }
    }

    for (show-list, title, kind) in (
      (lof, lof-title, "quarto-float-fig"),
      (lot, lot-title, "quarto-float-tbl"),
    ) {
      if show-list and query(figure.where(kind: kind)).len() > 0 {
        block(above: 0em, below: 2em)[
        #outline(title: title, target: figure.where(kind: kind));
        ]
        shown = true
      }
    }

    if shown and pagebreak-after {
      pagebreak()
    }
  }

  if show-cover and show-title-band {
    // Cover page, ToC and lists, then title band on a new page
    contents-block(pagebreak-after: true)
    title-band-block
    abstract-block
  } else if show-title-band {
    // Title band, abstract, ToC and lists on the first page
    title-band-block
    abstract-block
    contents-block()
  } else {
    // Abstract on its own page, then ToC and lists
    if abstract != none {
      abstract-block
      pagebreak()
    }
    contents-block()
  }

  // Show document
  if cols == 1 {
    doc
  } else {
    columns(cols, gutter: (gutter), doc)
  }
}

// Configure table
#set table(
  inset: 6pt,
  stroke: none
)
