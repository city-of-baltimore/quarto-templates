--- @module "wrapper"
--- @license MIT
--- @copyright 2024 City of Baltimore
--- @brief Shared helpers for building Typst calls from Lua, used by
--- filter.lua and shortcodes.lua.

local M = {}

--- Escape text for use inside a Typst string literal ("...").
--- Attribute values and shortcode arguments are raw text, so they must be
--- escaped before they are written into Typst code.
--- @param s string
--- @return string
function M.escape_typst_string(s)
    return (s:gsub('\\', '\\\\'):gsub('"', '\\"'))
end

--- Wrap a span's content in a Typst function call: #fn(args)[content];
--- The content stays as Pandoc inlines, so Pandoc converts and escapes it.
--- The call ends with ';' so following text such as '(' or '[' is not parsed
--- as more arguments, without adding a space before punctuation.
--- @param fn string Typst function name
--- @param span pandoc.Span
--- @param args string Typst arguments, already escaped (may be empty)
--- @return pandoc.Inlines
function M.wrap_span(fn, span, args)
    local inlines = pandoc.Inlines({
        pandoc.RawInline('typst', '#' .. fn .. '(' .. args .. ')[')
    })
    inlines:extend(span.content)
    inlines:insert(pandoc.RawInline('typst', '];'))
    return inlines
end

return M
