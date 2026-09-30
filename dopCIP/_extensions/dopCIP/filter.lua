--- @module "filter"
--- @license MIT
--- @copyright 2024 City of Baltimore
--- @brief Filter entrypoint: turns custom Markdown spans (dop-tag-text,
--- dop-table-label, dop-secondary-header) into calls to the
--- Typst functions in components.typ.

--- Load a module relative to the extension (absolute paths keep the module
--- cache from mixing up modules with the same name in other extensions).
local function require_local(path)
    return require(quarto.utils.resolve_path(path):gsub('%.lua$', ''))
end

local wrapper = require_local('_modules/wrapper.lua')

--- [text]{.dop-tag-text title="..."} -> #dop-tag-text(title: "...")[text];
--- @param el pandoc.Span
--- @return pandoc.Inlines
local function tag_text(el)
    local args = ''
    local title = el.attributes.title
    if title and title ~= '' then
        args = 'title: "' .. wrapper.escape_typst_string(title) .. '"'
    end

    return wrapper.wrap_span('dop-tag-text', el, args)
end

--- [text]{.dop-table-label} -> #dop-table-label()[text];
--- @param el pandoc.Span
--- @return pandoc.Inlines
local function table_label(el)
    return wrapper.wrap_span('dop-table-label', el, '')
end

--- [text]{.dop-secondary-header dy="-15pt"} -> #dop-secondary-header(dy: -15pt)[text];
--- @param el pandoc.Span
--- @return pandoc.Inlines
local function secondary_header(el)
    local args = ''
    local dy = el.attributes.dy
    if dy == '' then
        dy = nil
    end
    dy = wrapper.validate('dop-secondary-header', 'dy', dy,
        wrapper.signed_length_patterns, 'a length such as -15pt or -1.25em')
    if dy then
        args = 'dy: ' .. dy
    end

    return wrapper.wrap_span('dop-secondary-header', el, args)
end

local handlers = {
    ['dop-tag-text'] = tag_text,
    ['dop-table-label'] = table_label,
    ['dop-secondary-header'] = secondary_header,
}

--- Replace spans with a dopCIP class with a call to the matching Typst
--- function (the first matching class is used)
--- @param el pandoc.Span
--- @return pandoc.Inlines|nil
local function Span(el)
    if not quarto.doc.is_format('typst') then
        return nil
    end

    for _, class in ipairs(el.classes) do
        if handlers[class] then
            return handlers[class](el)
        end
    end

    return nil
end

return {
    { Span = Span },
}
