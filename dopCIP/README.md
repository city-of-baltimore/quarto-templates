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
    - Set colors as hex codes with or without a leading `#` (e.g. `"#0082BD"` or `"0082BD"`)
    - `accentcolor` used for figure captions, terms in definition lists, and tag text
    - `accentcolor-light` used for color bar on title page and the rule below the title band
    - `accentcolor-dark` used for footer and header text and the title band fill
    - `linkcolor` used for links
- Headings
  - Font and size set by `heading-font` and `heading-fontsize` (defaults to "Raleway") <https://fonts.google.com/specimen/Raleway>
  - Weight set by `heading-weight` as a name (e.g. `medium`, `extrabold`) or number from 100 to 900 (defaults to `bold`)
  - Level 3 headings scaled to 0.95 of default
  - Level 4 headings scaled to 0.85 of default
  - Level 5+ headings scaled to 0.75 of default
- Title page
  - Set `show-cover: false` to hide the title page (defaults to `true`)
  - Font and size for title and subtitle set by `title-font` (defaults to match `heading-font`) and `title-fontsize`
  - Set `before-date` and `before-date-modified` to insert text before dates
  - `date` is passed as string (not datetime) and `date-modified` is always displayed (`date` parsing uses a function from the [quarto-invoice](https://github.com/mcanouil/quarto-invoice) custom Typst format)
  - Author font size scaled to 0.5 of `title-fontsize` and dates font size scaled to 0.4 of `title-fontsize`
- Title band
  - Set `show-title-band: true` to show a colored band with the title at the top of the first page; the document text follows on the same page (defaults to `false`)
  - Band shows the title and subtitle followed by the authors, published date, and last updated date on separate lines, with a fill matching `accentcolor-dark` and a bottom rule matching `accentcolor-light`
  - Set `show-cover: false` to use the title band in place of the title page. If both are enabled, the title page and table of contents are followed by the title band on a new page
  - Set `title-band-logo: true` to show the City of Baltimore logo in the top-right corner of the title band (defaults to `false`); the logo is 1in tall when `logo-scale` is `1`
- Logos
  - Set `logo-align` to align the logos on the title page (defaults to `left`)
  - Set `logo-scale` to scale the height of the logos on the title page and title band (defaults to `1`); use a smaller value, such as `0.75`, if a long title overlaps the logos
- Table of contents
  - Outline entries use `heading-font`
  - Shown after the title page (following a page break) or after the title band
  - If both `show-cover` and `show-title-band` are enabled, a page break follows the table of contents
  - Not shown if the document has no headings to list (within `toc-depth`)
- Header and footer
  - Font can be set with `footer-font` (defaults to match `heading-font`)
  - Header shows the current level 2 heading (all caps text); if `show-cover` is `false`, the header also shows the document title on the left
  - Footer shows the current level 1 heading on the left and page number on the right (all caps text)
  - Header and footer are hidden on the title page and the header is hidden on the page with the title band
  - Headings not included in the table of contents (such as the table of contents title) are not shown in the header or footer
  - Import [hydra Typst package](https://typst.app/universe/package/hydra/)
  - Text color set to match `accentcolor-dark`
- Figures and tables
  - Table font set by `table-font` (defaults to "Source Sans 3"; previously named "Source Sans Pro") <https://fonts.google.com/specimen/Source+Sans+3>
  - Figure caption font set by `caption-font` (defaults to match `heading-font`)
  - Tables are breakable across pages (set `breakable-tables: false` to disable) and use strong formatting for the first row (assumed to be a header row)
- Term list
  - Tighter spacing between term and definition
  - Colored text with alternate font (matching `table-font`)
- Tag text
  - Use a `.dop-tag-text` span to show text in an outlined box: `[Text inside tag]{.dop-tag-text}`
  - Add a `title` attribute to show a label before the text: `[Text inside tag]{.dop-tag-text title="Status"}`
  - Outline and label color match `accentcolor`; label uses "Source Sans 3" (falls back to "Arial")
  - Tag text is only styled in PDF output
  - Tags are rendered by the `dop-tag-text` Typst function; add a space between adjacent tags

Note, you must have the static versions of these fonts installed to use them with this extension. Typst does not yet support variable fonts: https://github.com/typst/typst/issues/185
