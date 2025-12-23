// import hydra package for header/footer
#import "@preview/hydra:0.6.2": hydra, anchor

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
  margin: (x: 1.25in, y: 1.25in),
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
  breakable-tables: true,

  // Table of contents

  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,

  // Page numbering

  page-numbering: "1",
  page-number-align: right + bottom,

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

  // Set font sizes from defaults
  heading-fontsize = ifnone(heading-fontsize, fontsize)
  let cover-fontsize = title-fontsize * 0.5

  // Set colors
  accentcolor = rgb(accentcolor)
  accentcolor-light = rgb(accentcolor-light)
  accentcolor-dark = rgb(accentcolor-dark)
  linkcolor = rgb(linkcolor)

  // Formats the author's names in a list with commas and a
  // final "and".
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

    header: context if not show-cover {[
      #anchor()
      // running header
      // heading 2
      #text(
        font: footer-font,
        weight: "medium",
        baseline: 0.65em,
        fill: accentcolor-dark)[
            #upper[
              #title  #h(1fr) #hydra(1)
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
            #hydra(1) #h(1fr) #counter(page).display()
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

  // Set level 1 ToC typography
  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    text(font: heading-font, size: 1.1em, weight: "bold")[#it]
  }

  // Set level 2 ToC typography
  show outline.entry.where(
    level: 2
  ): it => {
    text(font: heading-font, size: 1em)[#it]
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
          size: 0.85em,
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
        #par(leading: 0.45em)[
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
  #if authors != none {
    align(title-align)[#block(inset: title-inset)[
        #text(weight: "bold", size: cover-fontsize)[#author-string]
      ]]
    v(1%)
  }

  #place(
    bottom + left,
    grid(
      columns: (2.5in, 2.5in),
      gutter: 0in,
      align: left + horizon,
        image(
              "baltimore-city-dop-logo.png",
              height: 1.75in,
              fit: "contain"
          ),
          image(
            "baltimore-city-logo.png",
            height: 1.5in,
            fit: "contain"
          )
      )
    )

  // Show date
  #let cover-date-format = "[month repr:long] [day], [year]."

  #if date != none {
    date = parse-date(date)
    date = date.display(cover-date-format)
    align(title-align)[#block(inset: title-inset)[
      #text(size: cover-fontsize * 0.8)[#before-date #date]
    ]]
  }

  // Show date modified (always)

  #if date-modified == none {
    date-modified = datetime.today().display(cover-date-format)
  }

  #align(title-align)[#block(inset: title-inset)[
    #text(size: cover-fontsize * 0.8)[#before-date-modified #date-modified]
  ]]

  // Cover should always be followed by page break
  #pagebreak()
]

  // Show abstract (then add page break)
  if abstract != none {
    block(inset: title-inset)[
    #text(weight: "semibold")[$labels.abstract$] #h(1em) #abstract
    ]

    pagebreak()
  }

  // Show ToC (then add page break)
  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]

    pagebreak()
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
