// FIXME: Customize term list formatting without hard-coding type and colors
#show terms: it => pad(
  left: it.indent + it.hanging-indent,
  stack(
    ..it.children.map(item => {
      h(-it.hanging-indent)
      text(
        font: "Source Sans Pro",
        size: 0.85em,
        fill: rgb("#0082BD"),
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


// import hydra package for header/footer
#import "@preview/hydra:0.5.1": hydra, anchor

// Default if value is none or empty array
#let ifnone(x, default) = {
  if x == none {
    return default
  }

  if x == () {
    return default
  }

  x
}

#let article(
  // FIXME: Expose full list of variables in typst-show.typst

  // Document attributes
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract: none,
  abstract-title: none,
  lang: "en",
  region: "US",

  cols: 1,
  gutter: 4%,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",

  // Typography

  font: ("Lora", "Georgia",),
  fontsize: 11pt,
  monofont: ("Source Code Pro", "Courier", ),

  // Body text typography

  justify: false,
  linebreaks: "optimized",
  first-line-indent: 0pt,
  hanging-indent: 0pt,
  leading: 0.75em,
  spacing: 1.25em,

  // Heading typography

  heading-font: ("Raleway", "Arial", ),
  heading-fontsize: 1.2em,
  heading-fontfill: (),
  sectionnumbering: none,

  // Title typography

  title-font: (),
  title-align: left,
  title-inset: 0pt,

  // Colors

  accentcolor: "#0082BD",
  accentcolor-light: "#FCB826",
  linkcolor: "#00415F",

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
  title-font = ifnone(title-font, heading-font)
  footer-font = ifnone(footer-font, heading-font)

  // Set font sizes from defaults
  heading-fontsize = ifnone(heading-fontsize, fontsize)

  // Set colors
  accentcolor = rgb(accentcolor)
  linkcolor = rgb(linkcolor)
  accentcolor-light = rgb(accentcolor-light)

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
    numbering: page-numbering,
    number-align: page-number-align,

    header: context [
      #anchor()
      // running header
      // heading 2
      #text(font: heading-font, baseline: 0.65em, fill: linkcolor)[
        #upper[
          #hydra(2)
        ]
      ]
      #line(length: 100%, stroke: 0.5pt)
    ],

    footer: context [
      #line(length: 100%, stroke: 0.5pt)
      // running footer
      #text(
        font: heading-font,
        fill: linkcolor,
        baseline: -0.5em,
      )[
        #upper[
          // heading 1 / page number
          #hydra(1) #h(1fr) #counter(page).display()
        ]
      ]
    ],
    footer-descent: footer-descent,
  )

  // Set document metadata
  set document(title: title, author: names, keywords: keywords,)

  // Set paragraph properties
  set par(
    justify: justify,
    first-line-indent: first-line-indent,
    hanging-indent: hanging-indent,
    linebreaks: linebreaks,
    leading: leading,
  )

  // Set table typography
  // show table: set text(font: monofont)

  // Make quarto-float-tbl figures breakable
  // See docs for implementation https://typst.app/docs/reference/model/figure/#figure-behaviour
  // See SO for inspiration https://stackoverflow.com/a/78727447
  show figure.where(
    kind: "quarto-float-tbl"
  ): set block(breakable: true)

  // Set figure caption
  show figure.caption: set text(
    fill: accentcolor,
    font: heading-font,
  )

  show par: set block(spacing: spacing)

  // Set general typography
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
      size: if it.level < 4 {
        heading-fontsize
      } else if it.level < 5 {
        heading-fontsize * 0.9
      } else {
        heading-fontsize * 0.8
      },

    )

    it
  }

  // Set font for inline code and blocks
  show raw: set text(font: monofont)

  // Set linkcolor
  show link: set text(fill: linkcolor)

  // Set up ToC
  set outline(fill: none, indent: 2em)

  // https://typst.app/docs/reference/model/outline/#definitions-entry
  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(it)
  }

  // Show title
  if title != none {
    align(title-align)[#block(inset: title-inset)[
      #par(leading: 0.45em)[
        #text(font: title-font, weight: "bold", size: 3em)[#upper[#title]]
      ]

    ]]

    rect(width: 100%, height: 6em, fill: accentcolor-light)
  }

  date = datetime.today().display()

  // Show authors

  if authors != none {
    align(title-align)[#block(inset: title-inset)[
        #text(weight: "bold", size: 1.25em)[#author-string]
      ]]
  }

  // Show date
  if date != none {
    align(title-align)[#block(inset: title-inset)[
      #text(size: 1.25em)[#date]
    ]]
  }

  // Show abstract

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[$labels.abstract$] #h(1em) #abstract
    ]
  }

  // Insert page break between title and ToC

  pagebreak()

  // Show ToC

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
  }

  pagebreak()

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
