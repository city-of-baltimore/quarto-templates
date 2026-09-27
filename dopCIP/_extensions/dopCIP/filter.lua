--- @module "filter"
--- @license MIT
--- @copyright 2024 City of Baltimore
--- @brief Filter entrypoint: turns custom Markdown spans into calls to the
--- Typst functions in components.typ.

--- Load a module relative to the extension (absolute paths keep the module
--- cache from mixing up modules with the same name in other extensions).
local function require_local(path)
    return require(quarto.utils.resolve_path(path):gsub('%.lua$', ''))
end

local wrapper = require_local('_modules/wrapper.lua')

--- [text]{.dop-tag-text title="..."} -> #dop-tag-text(title: "...")[text];
--- @param el pandoc.Span
--- @return pandoc.Inlines|nil
local function Span(el)
    if not quarto.doc.is_format('typst') or not el.classes:includes('dop-tag-text') then
        return nil
    end

    local args = ''
    local title = el.attributes.title
    if title and title ~= '' then
        args = 'title: "' .. wrapper.escape_typst_string(title) .. '"'
    end

    return wrapper.wrap_span('dop-tag-text', el, args)
end

return {
    { Span = Span },
}
