local function escape_typst_string(s)
    return s:gsub('\\', '\\\\'):gsub('"', '\\"')
end

function Span(el)
    if el.classes:includes('tag-text') then
        local args = ""
        if el.attributes.title and el.attributes.title ~= "" then
            args = 'title: "' .. escape_typst_string(el.attributes.title) .. '"'
        end

        local inlines = pandoc.List({
            pandoc.RawInline('typst',
                '#tag-text(' .. args .. ')['
            )
        })
        inlines:extend(el.content)
        inlines:insert(pandoc.RawInline('typst', ']\n'))
        return inlines
    end
end
