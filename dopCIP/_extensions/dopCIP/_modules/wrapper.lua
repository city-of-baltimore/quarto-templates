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

--- Lua patterns for a Typst length such as 1.5em, 12pt, or .25in
--- (length_patterns), or one that may be negative such as -15pt
--- (signed_length_patterns).
M.length_patterns = {}
M.signed_length_patterns = {}
for _, unit in ipairs({ 'em', 'pt', 'in', 'cm', 'mm' }) do
    for _, number in ipairs({ '%d+%.?%d*', '%.%d+' }) do
        table.insert(M.length_patterns, '^' .. number .. unit .. '$')
        table.insert(M.signed_length_patterns, '^%-?' .. number .. unit .. '$')
    end
end

--- Lua patterns for a hex color such as #0082BD or #08B.
M.hex_color_patterns = { '^#%x%x%x$', '^#%x%x%x%x%x%x$' }

--- Return the value if it matches one of the patterns, otherwise warn and
--- return nil so the Typst default is used.
--- @param component string component name shown in the warning
--- @param name string attribute or argument name
--- @param value string|nil
--- @param patterns string[] Lua patterns
--- @param expected string description of valid values for the warning
--- @return string|nil
function M.validate(component, name, value, patterns, expected)
    if value == nil then
        return nil
    end
    for _, pattern in ipairs(patterns) do
        if value:match(pattern) then
            return value
        end
    end
    quarto.log.warning(component .. ': ignoring ' .. name .. '="' .. value ..
        '" (expected ' .. expected .. ')')
    return nil
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

--- Wrap a div's content in a Typst function call: #fn(args)[content]
--- The content stays as Pandoc blocks, so Pandoc converts and escapes it.
--- @param fn string Typst function name
--- @param div pandoc.Div
--- @param args string Typst arguments, already escaped (may be empty)
--- @return pandoc.Blocks
function M.wrap_div(fn, div, args)
    local blocks = pandoc.Blocks({
        pandoc.RawBlock('typst', '#' .. fn .. '(' .. args .. ')[')
    })
    blocks:extend(div.content)
    blocks:insert(pandoc.RawBlock('typst', ']'))
    return blocks
end

return M
