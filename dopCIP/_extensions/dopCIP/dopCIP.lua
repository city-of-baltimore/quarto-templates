local function escape_typst_string(s)
    return s:gsub('\\', '\\\\'):gsub('"', '\\"')
end

function Span(el)
    if el.classes:includes('dop-tag-text') then
        local args = ""
        if el.attributes.title and el.attributes.title ~= "" then
            args = 'title: "' .. escape_typst_string(el.attributes.title) .. '"'
        end

        local inlines = pandoc.List({
            pandoc.RawInline('typst',
                '#dop-tag-text(' .. args .. ')['
            )
        })
        inlines:extend(el.content)
        -- End the call with ';' so following text such as '(' or '[' is not
        -- parsed as more arguments, without adding a space before punctuation
        inlines:insert(pandoc.RawInline('typst', '];'))
        return inlines
    end
end
