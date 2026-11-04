-- dop-toc shortcode: insert a table of contents for the current section
--
-- {{< dop-toc title="In this chapter" depth=2 indent=1.5em level=1 >}}
--
-- Calls dop-section-outline() from components.typ. Produces nothing in
-- other formats.
--
-- dop-image-layers shortcode: stack images of the same size and aspect ratio
--
-- {{< dop-image-layers basemap.png overlay.svg width=6.5in fig-alt="Map" >}}
--
-- Positional arguments are image paths, bottom layer first. Options follow
-- the Quarto figure options: width, fig-alt (fig-alt="" marks the image as
-- decorative), and fig-align (left, center, or right; default center).
-- fig-cap is reserved and ignored with a warning. Calls dop-image-layers()
-- from components.typ. Produces nothing in other formats.

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

return {
    ['dop-image-layers'] = function(args, kwargs, meta)
        if not quarto.doc.is_format('typst') then
            return pandoc.Null()
        end

        local layers = {}
        for _, arg in ipairs(args) do
            local path = pandoc.utils.stringify(arg)
            if path ~= '' then
                table.insert(layers, '"' .. wrapper.escape_typst_string(path) .. '"')
            end
        end

        if #layers == 0 then
            quarto.log.warning('dop-image-layers: no image paths given')
            return pandoc.Null()
        end

        -- A trailing comma makes a single layer an array, not parentheses
        local params = { '(' .. table.concat(layers, ', ') .. ',)' }

        local width_patterns = { table.unpack(wrapper.percent_patterns) }
        for _, pattern in ipairs(wrapper.length_patterns) do
            table.insert(width_patterns, pattern)
        end
        local width = wrapper.validate('dop-image-layers', 'width', kwarg(kwargs, 'width'),
            width_patterns, 'a length such as 6.5in or 12cm, or a percentage such as 80%')
        if width then
            table.insert(params, 'width: ' .. width)
        end

        local align = wrapper.validate('dop-image-layers', 'fig-align', kwarg(kwargs, 'fig-align'),
            { '^left$', '^center$', '^right$' }, 'left, center, or right')
        if align then
            table.insert(params, 'alignment: ' .. align)
        end

        -- A missing kwarg is an empty Inlines table, but fig-alt="" is an
        -- empty string. Only the second one means the image is decorative.
        local alt = kwarg(kwargs, 'fig-alt')
        if alt then
            table.insert(params, 'alt: "' .. wrapper.escape_typst_string(alt) .. '"')
        elseif rawget(kwargs, 'fig-alt') == nil then
            quarto.log.warning('dop-image-layers: no fig-alt given; add fig-alt="..." to describe the ' ..
                'image, or fig-alt="" if it is purely decorative')
        end

        if kwarg(kwargs, 'fig-cap') then
            quarto.log.warning('dop-image-layers: fig-cap is not supported yet and is ignored')
        end

        -- A block, so the image is not placed inside a paragraph
        return pandoc.RawBlock('typst',
            '#dop-image-layers(' .. table.concat(params, ', ') .. ')')
    end,

    ['dop-toc'] = function(args, kwargs, meta)
        if not quarto.doc.is_format('typst') then
            return pandoc.Null()
        end

        local params = {}

        local title = kwarg(kwargs, 'title')
        if title then
            table.insert(params, 'title: "' .. wrapper.escape_typst_string(title) .. '"')
        end

        local depth = wrapper.validate('dop-toc', 'depth', kwarg(kwargs, 'depth'), { '^[1-9]%d*$' },
            'a whole number from 1')
        if depth then
            table.insert(params, 'depth: ' .. depth)
        end

        local level = wrapper.validate('dop-toc', 'level', kwarg(kwargs, 'level'), { '^[1-9]$' },
            'a heading level from 1 to 9')
        if level then
            table.insert(params, 'level: ' .. level)
        end

        local indent = wrapper.validate('dop-toc', 'indent', kwarg(kwargs, 'indent'), wrapper.length_patterns,
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
