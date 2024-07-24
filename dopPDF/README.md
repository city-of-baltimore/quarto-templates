# DopPDF Format

## Installing

This will install the extension and create an example qmd file that you can use as a starting place for your article:

```bash
quarto use template city-of-baltimore/quarto-templates/dopPDF
```

You can also use the custom format without the template:

```bash
quarto add city-of-baltimore/quarto-templates/dopPDF
```

## Using

This template was designed in 2023 for use with the FY25-30 Capital Improvement Program Report created by the Baltimore City Department of Planning. 

## Format Options

The following parameters are set by default:

```yaml
common:
      toc: true
      filters:
          - color-text.lua
          - fancy-figure.lua
      knitr:
          opts_chunk:
            echo: false
    pdf:
      documentclass: scrreprt
      papersize: letter
      geometry:
        - left=1.25in
        - top=1in
        - bottom=1.25in
        - right=1.25in
        - heightrounded=true
      # text structure
      top-level-division: part
      # text formatting
      indent: false
      automark: yes
      # code formatting
      code-block-bg: lightestgray
      # link formatting
      colorlinks: true
      linkcolor: darkerblue
      urlcolor: darkerblue
      include-in-header:
        - "includes/header.tex"
        - "includes/header-colors.tex"
        - "includes/header-fonts.tex"
      template-partials:
        - "partials/title.tex"
        - "partials/before-body.tex"
```

You can customize the `linkcolor` and `urlcolor` and the `code-block-bg` color. 

The format supports the following custom color names:

- lightestblue
- lightestblue
- darkblue
- darkerblue
- darkestblue
- darkgray
- lightgray
- lightestgray
- dark
- gold
- darkgold

## Credits

This format includes elements copied from other existing format extensions:

- color text and fancy figure Lua filters from the [Association of Computing Machinery (ACM) journal format](https://github.com/quarto-journals/acm).
- text formatting from the [BBMR LaTeX template](https://github.com/baltimorebudget/LaTeX-Templates)
- line, page, and paragraph breaks from the [Quarto template for Monash Business School consulting report](https://github.com/quarto-monash/report/)

This repository also includes the [Open Font License](http://scripts.sil.org/OFL) fonts for [Lora](https://fonts.google.com/specimen/Lora), [Raleway](https://fonts.google.com/specimen/Raleway), and [Source Code Pro](https://adobe-fonts.github.io/source-code-pro/).