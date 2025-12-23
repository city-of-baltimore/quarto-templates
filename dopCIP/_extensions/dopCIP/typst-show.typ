#show: doc => article(

// Document information
$if(title)$
  title: [$title$],
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$endif$
$if(by-author)$
  authors: (
  $for(by-author)$
  $if(it.name.literal)$
      ( name: "$it.name.literal$",
        affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
        email: [$it.email$] ),
  $endif$
  $endfor$
      ),
$endif$
$if(date)$
  date: "$date$",
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(abstract)$
  abstract: [$abstract$],
  abstract-title: "$labels.abstract$",
$endif$
  flipped: $flipped$,
  show-cover: $show-cover$,
  breakable-tables: $breakable-tables$,

// Body text typography

$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$

$if(justify)$
  justify: $justify$,
$endif$
$if(linebreaks)$
  linebreaks: "$linebreaks$",
$endif$
$if(first-line-indent)$
  first-line-indent: $first-line-indent$,
$endif$
$if(hanging-indent)$
  hanging-indent: $hanging-indent$,
$endif$
$if(leading)$
  leading: $leading$,
$endif$
$if(spacing)$
  spacing: $spacing$,
$endif$

// Heading typogrpahy

$if(heading-font)$
  heading-font: ("$heading-font$",),
$endif$
$if(heading-fontsize)$
  heading-fontsize: $heading-fontsize$,
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(heading-weight)$
  heading-weight: heading-weight,
$endif$
$if(heading-style)$
  heading-style: "$heading-style$",
$endif$

// Title typography

$if(title-font)$
  title-font: ("$title-font$",),
$endif$
$if(title-align)$
  title-align: $title-align$,
$endif$
$if(title-fontsize)$
  title-fontsize: $title-fontsize$,
$endif$
$if(title-inset)$
  title-inset: $title-inset$,
$endif$

// Additional typographic parameters
$if(monofont)$
  monofont: ("$monofont$",),
$endif$
$if(table-font)$
  table-font: ("$table-font$",),
$endif$
$if(caption-font)$
  caption-font: ("$caption-font$",),
$endif$

// Colors

$if(accentcolor)$
  accentcolor: "$accentcolor$",
$endif$
$if(accentcolor-dark)$
  accentcolor-dark: "$accentcolor-dark$",
$endif$
$if(accentcolor-light)$
  accentcolor-light: "$accentcolor-light$",
$endif$
$if(linkcolor)$
  linkcolor: "$linkcolor$",
$endif$

// Table of contents

$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
$if(toc-indent)$
  toc_indent: $toc-indent$,
$endif$
  toc_depth: $toc-depth$,

// Page layout
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$

cols: $if(columns)$$columns$$else$1$endif$, // Columns
$if(gutter)$
  gutter: $gutter$,
$endif$
  doc,
)
