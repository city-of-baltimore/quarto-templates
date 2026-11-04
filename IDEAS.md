# Ideas for future improvements

## dopCIP

### Title band

- **Reuse Quarto's `title-block-banner` option in place of `show-title-band`.**
  Quarto HTML formats already use `title-block-banner` for a colored banner
  containing the title block, which is the same idea as the title band.
  A test render with `title-block-banner: true` mapped to the band in
  `typst-show.typ` worked with no schema warnings.
  - Pros: familiar to Quarto users; if set at the top level of the front
    matter (not under a format), one setting turns on the banner for both
    HTML and PDF output; HTML also accepts a color value
    (`title-block-banner: "#00415F"`), which could set the band fill.
  - Cons: users may expect HTML behavior that the band doesn't support
    (e.g. an image as the value); the name is inconsistent with
    `show-cover`; `title-band-logo` would need a matching name
    (e.g. `title-block-banner-logo`).
  - If adopted, keep `show-title-band` working as an alias.
- **Choice of logo in the band.** The band always uses the City of Baltimore
  logo because the Department of Planning logo has a white (non-transparent)
  background. A transparent version of the Department of Planning logo would
  allow a `title-band-logo: dop | city` option.
- **Centered title with logo.** With `title-align: center` and
  `title-band-logo: true`, the title is centered in the space beside the
  logo, not on the page.
- **Title as a PDF bookmark.** The title could be added to the PDF outline
  (bookmarks) without affecting the running header or footer, e.g. via
  Typst's `title` element or a hidden heading.

### Cover page and options

- **Single option for first-page design.** If more first-page designs are
  added, consider replacing `show-cover` and `show-title-band` with one
  option (e.g. `title-page: cover | band | cover-band | none`). `show-cover`
  has been released since v1.1.1, so it would need to keep working.
- **Automatic logo scaling.** `logo-scale` is manual. The cover page could
  measure the title block and shrink the logos to avoid overlap.
- **Long titles in the running header.** When `show-cover` is `false`, a long
  title pushes the level 2 heading onto a second header line.

### Tag text

- **More attributes.** Pass an allowlisted set of attributes (e.g. `color`,
  `fill`) from the span to `dop-tag-text`, escaping values in Lua.
- **Markdown in the label.** `title` is passed as a Typst string, so
  Markdown in it shows literally; passing it as content would allow
  formatting.
- **HTML output.** Add CSS so tags look similar in HTML.
- **Duplicated default color.** `#0082BD` is set in both `dop-tag-text` and
  `article()`; define it once.

### Options

- **Extension schema file.** Add a `_schema.yml` next to `_extension.yml`
  describing every dopCIP option (type, allowed values, default,
  description), following the
  [Quarto Wizard schema specification](https://m.canouil.dev/quarto-wizard/reference/schema-specification.html).
  - Quarto Wizard (VS Code) uses it for autocompletion, hover documentation,
    and diagnostics in front matter, `_quarto.yml`, and `_metadata.yml`.
  - Optionally, vendor Quarto Wizard's `schema.lua` validator into
    `_modules/` and call it from `filter.lua` to report invalid options
    during a render.
  - Quarto CLI (as of 1.10) does not read the file, and the specification
    may change; the schema also needs to be kept in sync with
    `typst-show.typ` and the README.
  - Would document options Quarto's own schema doesn't list for Typst,
    such as `margin-top`.
- **Margin defaults for partial `margin` maps.** Sides not set in a
  `margin` map fall back to Typst's default margin rather than the
  format defaults (1in / 1.25in). Merging the document's `margin` over the
  format defaults would be more predictable.

### Stacked images (`dop-image-layers`)

- **Captions and cross-references.** Wrap the block in `figure()` when
  `fig-cap` is given (it is currently ignored with a warning), with a
  `label` option so `@fig-...` references and the list of figures work.
  Test how it interacts with `lof`.
- **Block-level output only.** The shortcode returns a `RawBlock`, so it only
  works on its own line. Used inline in a paragraph, Quarto may drop it or
  render it unpredictably; this is untested.
- **Other figure options.** `fig-pos`, `height`/`out-height`, and
  `fig-env`-style options are not supported. `height` was left out because
  the first layer's aspect ratio sets it.
- **Check for missing files early.** A missing path gives a Typst "file not
  found" error with the full path. A Lua check (`io.open`) could warn with the
  shortcode name and path, but needs the same path rules as Typst (relative to
  the qmd, or `/` for the project root).
- **Warn on mismatched aspect ratios.** Overlays are stretched to match the
  first layer, so a wrong-ratio overlay is silently distorted. Reading image
  dimensions in Lua (e.g. `pandoc.image.size`) could warn.
- **Per-layer options.** Opacity or blend per layer, and per-layer alt text
  (currently only the first layer carries `fig-alt`, so it must describe the
  combined image).
- **Quoting limitation.** Quarto's shortcode parser can't read `\"` inside a
  double-quoted value; a bad value turns into stray positional args that are
  treated as image paths. Validating that each path exists would catch this.
- **Tests.** There is no automated check; the template.qmd examples are the
  only coverage. A small script that renders it and fails on unexpected `(W)`
  warnings would help.
- **PDF accessibility not verified.** The README says overlay layers are
  hidden from assistive technology (`alt: ""`); this was not checked in a
  tagged PDF. The claim about SVG re-embedding
  (typst/typst#7379) was also not verified.

### Fonts

- **Bundle fonts.** Lora, Raleway, Source Sans 3 and Source Code Pro are not
  bundled with the extension, so documents render with fallback fonts on
  machines without them installed. Consider shipping the static font files
  (with licenses) in `_extensions/dopCIP/fonts/` and setting `font-paths`.
