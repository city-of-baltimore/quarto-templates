-- dop-toc shortcode: insert a table of contents for the current section
--
-- {{< dop-toc title="In this chapter" depth=2 indent=1.5em level=1 >}}
--
-- Calls dop-section-outline() from components.typ. Produces nothing in
-- other formats.

local function require_local(path)
    return require(quarto.utils.resolve_path(path):gsub('%.lua$', ''))
end

local wrapper = require_local('_modules/wrapper.lua')

-- Missing kwargs are empty Inlines, not nil
local function kwarg(kwargs, name)
    local value = pandoc.utils.stringify(kwargs[name] or '')
    if value == '' then
        return nil
    end
    return value
end

-- Return the value if it matches one of the patterns, otherwise warn and
-- return nil so the Typst default is used
local function validate(name, value, patterns, expected)
    if value == nil then
        return nil
    end
    for _, pattern in ipairs(patterns) do
        if value:match(pattern) then
            return value
        end
    end
    quarto.log.warning('dop-toc: ignoring ' .. name .. '="' .. value ..
        '" (expected ' .. expected .. ')')
    return nil
end

local length_patterns = {}
for _, unit in ipairs({ 'em', 'pt', 'in', 'cm', 'mm' }) do
    table.insert(length_patterns, '^%d+%.?%d*' .. unit .. '$')
    table.insert(length_patterns, '^%.%d+' .. unit .. '$')
end

return {
    ['dop-toc'] = function(args, kwargs, meta)
        if not quarto.doc.is_format('typst') then
            return pandoc.Null()
        end

        local params = {}

        local title = kwarg(kwargs, 'title')
        if title then
            table.insert(params, 'title: "' .. wrapper.escape_typst_string(title) .. '"')
        end

        local depth = validate('depth', kwarg(kwargs, 'depth'), { '^[1-9]%d*$' },
            'a whole number from 1')
        if depth then
            table.insert(params, 'depth: ' .. depth)
        end

        local level = validate('level', kwarg(kwargs, 'level'), { '^[1-9]$' },
            'a heading level from 1 to 9')
        if level then
            table.insert(params, 'level: ' .. level)
        end

        local indent = validate('indent', kwarg(kwargs, 'indent'), length_patterns,
            'a length such as 1.5em, 12pt, or 0.25in')
        if indent then
            table.insert(params, 'indent: ' .. indent)
        end

        -- End with ';' so text right after the shortcode isn't read as part
        -- of the call
        return pandoc.RawInline('typst',
            '#dop-section-outline(' .. table.concat(params, ', ') .. ');')
    end
}
