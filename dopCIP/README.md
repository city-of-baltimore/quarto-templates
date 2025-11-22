# dopCIP Format

This format is designed for use with the Baltimore City Department of Planning Capital Improvement Program report series.

## Installing

```bash
quarto use template city-of-baltimore/quarto-templates/dopCIP
```

This will install the format extension and create an example qmd file
that you can use as a starting place for your document.

## Using the dopCIP format

These are the custom features supported by this custom format:

- General
  - Fonts
    - `mainfont` defaults to "Lora" <https://fonts.google.com/specimen/Lora>
    - `monofont` defaults to "Source Code Pro" <https://fonts.google.com/specimen/Source+Code+Pro>
    - Format supports extra typography parameters: `linebreaks`, `first-line-indent`, `hanging-indent`, `leading`, `spacing`
  - Colors
    - `accentcolor` used for figure captions and terms in definition lists
    - ``accentcolor-light` used for color bar on title page
    - `accentcolor-dark` used for footer and header text
    - `linkcolor` used for links
- Headings
  - Font and size set by `heading-font` and `heading-fontsize` (defaults to "Raleway") <https://fonts.google.com/specimen/Raleway>
  - Level 4 headings scaled to 0.9 of default
  - Level 5+ headings scaled to 0.8 of default
- Title page
  - Font and size for title and subtitle set by `title-font` (defaults to match `heading-font`) and `title-fontsize`
  - Set `before-date` and `before-date-modified` to insert text before dates
  - `date` is passed as string (not datetime) and `date-modified` is always displayed (`date` parsing uses a function from the [quarto-invoice](https://github.com/mcanouil/quarto-invoice) custom Typst format)
  - Author and dates font size scaled to 0.5 of `title-fontsize`
- Table of contents
  - Font for level 1 and 2 in outline set to match `heading-font`
  - Page break before and after TOC
- Header and footer
  - Font can be set with `footer-font` (defaults to match `heading-font`)
  - Header shows heading 1 in top-left corner (all caps text)
  - Footer shows heading 2 in bottom-left corner and page number in bottom-right (all caps text)
  - Import [hydra Typst package](https://typst.app/universe/package/hydra/)
  - Text color set to match `accentcolor-dark`
- Figures and tables
  - Table font set by `table-font` (defaults to "Source Sans 3"; previously named "Source Sans Pro") <https://fonts.google.com/specimen/Source+Sans+3>
  - Figure caption font set by `caption-font` (defaults to match `heading-font`)
  - Tables are automatically breakable and use strong formatting for the first row (assumed to be a header row)
- Term list
  - Tighter spacing between term and definition
  - Colored text with alternate font (matching `table-font`)

Note, you must have the static versions of these fonts installed to use them with this extension. Typst does not yet support variable fonts: https://github.com/typst/typst/issues/185
