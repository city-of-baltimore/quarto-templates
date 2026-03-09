function Span(el)
    if el.classes:includes('tag-text') then
        local args = ""
        if el.attributes.title then
            args = 'title: "' .. el.attributes.title .. '"'
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
