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

// Text in an outlined box with an optional title (used by the dop-tag-text
// span filter in dopCIP.lua)
#let dop-tag-text(
  title: none,
  sep: " ",
  text-color: black,
  title-color: rgb("#0082BD"),
  title-weight: "medium",
  title-font: ("Source Sans 3", "Arial", ),
  radius: 0.45em,
  fill: white,
  inset: (x: 0.45em),
  outset: (y: 0.35em),
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

  // Page numbering

  page-numbering: "1",
  page-number-align: right + bottom,

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

  // Convert numeric heading weight from metadata (e.g. "600") to an integer
  if type(heading-weight) == str and heading-weight.codepoints().all(c => c in "0123456789") {
    heading-weight = int(heading-weight)
  }

  // Set font sizes from defaults
  heading-fontsize = ifnone(heading-fontsize, fontsize)
  let cover-fontsize = title-fontsize * 0.5

  // Set colors
  accentcolor = rgb(accentcolor)
  accentcolor-light = rgb(accentcolor-light)
  accentcolor-dark = rgb(accentcolor-dark)
  linkcolor = rgb(linkcolor)

  // Top margin (used to extend the title band to the top edge of the page)
  let margin-top = if type(margin) == dictionary {
    margin.at("top", default: margin.at("y", default: margin.at("rest", default: 2.5cm)))
  } else {
    margin
  }

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

    header: context if query(<title-band>).any(it => it.location().page() == here().page()) {
      // No running header above the title band (hydra still needs an anchor)
      anchor()
    } else if not show-cover {[
      #anchor()
      // running header
      // heading 2
      #text(
        font: footer-font,
        weight: "medium",
        baseline: 0.65em,
        fill: accentcolor-dark)[
            #upper[
              #title  #h(1fr) #hydra(2)
            ]
      ]
      #line(length: 100%, stroke: 0.5pt)

    ]} else if (counter(page).get().first() > 1) {[
      #anchor()
      // running header
      // heading 2
      #text(
        font: footer-font,
        weight: "medium",
        baseline: 0.65em,
        fill: accentcolor-dark)[
            #upper[
              #hydra(2)
            ]
        ]
      #line(length: 100%, stroke: 0.5pt)
    ]},

    footer: context if (counter(page).get().first() > 1 or not show-cover) {[
        #line(length: 100%, stroke: 0.5pt)
        // running footer
        #text(
          font: footer-font,
          fill: accentcolor-dark,
          baseline: -0.5em)[
          #upper[
            // heading 1 / page number
            #hydra(section-heading) #h(1fr) #counter(page).display()
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

  // Set ToC entry typography per level, keeping the page number in a
  // consistent font and weight across all levels (only the heading label
  // varies)
  show outline.entry: it => {
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

    it.indented(it.prefix(), label + h(1fr) + page-number)
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
        #text(font: title-font, weight: "bold", size: title-fontsize)[#upper[#title]]
      ]
    ]]

    // Show subtitle (only if title is provided)
    if subtitle != none {
      v(2%)
      align(title-align)[#block(inset: title-inset)[
        #par(leading: 0.65em)[
          #text(font: title-font, fill: luma(45), weight: "extrabold", size: title-fontsize * 0.85)[#upper[#subtitle]]
        ]
      ]]
    }
  }

  // Show color bar on title page
  #v(4%)
  #rect(width: 100%, outset: (x: 100%), height: 8em, fill: accentcolor-light)
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
      outset: (x: 100%, top: margin-top),
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
            #text(font: title-font, weight: "bold", size: title-fontsize * 0.75)[#upper[#title]]
          ]
        }

        #if subtitle != none {
          par(leading: 0.5em)[
            #text(font: title-font, weight: "medium", size: title-fontsize * 0.4)[#upper[#subtitle]]
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

  // ToC (only shown if there are headings to list)
  let toc-block(pagebreak-after: false) = if toc {
    context {
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

        if pagebreak-after {
          pagebreak()
        }
      }
    }
  }

  if show-cover and show-title-band {
    // Cover page, ToC, then title band on a new page
    toc-block(pagebreak-after: true)
    title-band-block
    abstract-block
  } else if show-title-band {
    // Title band, abstract, and ToC on the first page
    title-band-block
    abstract-block
    toc-block()
  } else {
    // Abstract on its own page, then ToC
    if abstract != none {
      abstract-block
      pagebreak()
    }
    toc-block()
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
