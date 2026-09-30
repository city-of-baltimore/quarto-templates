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
- Page layout
  - Margins default to 1in on the left and right and 1.25in on the top and bottom
  - Set `margin` with any of `x`, `y`, `top`, `bottom`, `left`, and `right` (e.g. `margin: {x: 0.75in, y: 1in}`); sides that are not set use Typst's default margin, not the format defaults
  - Set `margin-top`, `margin-bottom`, `margin-left`, or `margin-right` to change a single side; these take precedence over `margin`
  - Include units with all margin values (e.g. `1in`, `2cm`)
- Headings
  - Font and size set by `heading-font` and `heading-fontsize` (defaults to "Raleway") <https://fonts.google.com/specimen/Raleway>
  - Weight set by `heading-weight` as a name (e.g. `medium`, `extrabold`) or number from 100 to 900 (defaults to `bold`)
  - Level 3 headings scaled to 0.95 of default
  - Level 4 headings scaled to 0.85 of default
  - Level 5+ headings scaled to 0.75 of default
- Title page
  - Set `show-cover: false` to hide the title page (defaults to `true`)
  - Font and size for title and subtitle set by `title-font` (defaults to match `heading-font`) and `title-fontsize`
  - Title weight set by `title-weight` as a name (e.g. `semibold`, `regular`) or number from 100 to 900 (defaults to `bold`); also applies to the title band
  - Subtitle weight set by `subtitle-weight` in the same way (defaults to `medium`); also applies to the title band
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
- List of figures and list of tables
  - Set `lof: true` and `lot: true` to show a list of figures and a list of tables after the table of contents
  - Titles default to "List of Figures" and "List of Tables"; set them with `crossref: {lof-title: ..., lot-title: ...}` (as for LaTeX PDF output) or with top-level `lof-title` and `lot-title`
  - As in LaTeX PDF output, lists include every numbered figure and table; a table with a label (e.g. `#| label: tbl-x`) but no caption is listed with its number and no text. A list is not shown if there are no figures or tables
- Section table of contents
  - Use the `dop-toc` shortcode to insert a table of contents for the current section, e.g. a chapter contents after a level 1 heading: `{{< dop-toc title="In this chapter" >}}`
  - Lists the headings after the section heading up to the next heading at the same or a higher level; not shown if there are no headings to list
  - `title`: text shown above the entries (optional)
  - `depth`: number of heading levels below the section heading to include (defaults to all)
  - `level`: heading level of the section to list (e.g. `level=1` for the whole chapter when placed under a level 2 heading; defaults to the heading before the shortcode)
  - `indent`: indent per level as a length such as `1.5em` (defaults to `toc-indent`, or `1.5em`); the first level of entries is not indented
  - Only shown in PDF output
- Header and footer
  - Font can be set with `footer-font` (defaults to match `heading-font`)
  - Set what the running header and footer show with `page-header` and `page-footer`, using `left` and `right` keys. Each side takes one of these keywords:
    - `title`: document title
    - `heading-1`: current level 1 heading
    - `heading-2`: current level 2 heading
    - `page-number`: page number (formatted with `page-numbering`)
    - `none`: nothing (use `none`, not `false`: `false` or an empty value uses the default)
  - Defaults: the header shows the current level 2 heading on the left (`page-header: {left: heading-2, right: none}`); the footer shows the current level 1 heading on the left and the page number on the right (`page-footer: {left: heading-1, right: page-number}`). Sides that are not set use the default, e.g. `page-header: {right: title}` adds the title to the right of the header
  - Unknown keywords stop the render with an error; other keys (such as `center`) are ignored
  - The header or footer (including its line) is hidden if both sides are `none`
  - Text is all caps. Unlike the `page-footer` option for Quarto websites, values are keywords, not Markdown text
  - Set `page-numbering` to change the page number format (e.g. `i`; defaults to `1`) or to `false` to hide page numbers. A format with two numbers, such as `1 / 1` or `1 of 1`, shows the current page and the total pages
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
- Table label
  - Use a `.dop-table-label` span to show text styled like a table caption, without a caption number: `[Table label text]{.dop-table-label}`
  - Font matches `table-font` and color matches `accentcolor` (bold, 0.9em)
  - Only styled in PDF output; rendered by the `dop-table-label` Typst function
- Section page
  - Use a `.dop-section-page` div to show a heading (and an optional short summary) on its own page above a colored bar, as a section break:

    ```markdown
    ::: {.dop-section-page}
    # Part two

    A short summary of this section.
    :::
    ```

  - Adds a page break before and after the section page (without adding a blank page if the section page already starts a page)
  - The heading can be any level and is included in the table of contents, the running footer, and cross-references
  - The heading keeps the normal heading style; the heading and summary are shown at 1.2 times their normal size
  - The bar matches the cover page bar (`accentcolor-light`); add a `fill` attribute with a hex color to change it for one section page, e.g. `::: {.dop-section-page fill="#00415F"}`. Values that are not a hex color (`#RGB` or `#RRGGBB`) are ignored with a warning
  - The running header is hidden on the section page; the running footer is shown without headings (`heading-1` and `heading-2` are left empty)
  - Must be at the top level of the document, not inside a callout, column layout, or other div (Typst doesn't allow page breaks inside containers, so the render fails with "pagebreaks are not allowed inside of containers")
  - Not supported in documents with more than one column
  - Only shown as a section page in PDF output
- Secondary header
  - Use a `.dop-secondary-header` span to show a line of small caps text below the running header line and above the title of a page: `[Project details]{.dop-secondary-header}`
  - Place the span in its own paragraph before the page's first heading; it floats to the top of the page it is on
  - Add a `dy` attribute to change the vertical offset from the top of the page text (defaults to `-15pt`), e.g. `[Project details]{.dop-secondary-header dy="-12pt"}`; values that are not a length are ignored with a warning
  - Font matches `heading-font` and color matches `accentcolor-dark`
  - Only shown in PDF output as a secondary header; rendered by the `dop-secondary-header` Typst function

Note, you must have the static versions of these fonts installed to use them with this extension. Typst does not yet support variable fonts: https://github.com/typst/typst/issues/185
