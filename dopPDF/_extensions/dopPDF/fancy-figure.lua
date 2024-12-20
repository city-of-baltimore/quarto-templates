-- copied 2023-12-04
-- https://github.com/quarto-journals/acm/blob/main/_extensions/quarto-journals/acm/fancy-figure.lua

-- MIT License - https://github.com/quarto-journals/acm/blob/main/LICENSE

-- Copyright (c) 2022 RStudio, PBC

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

function has_class(el, class)
  if el.attr == nil then
    return nil
  end
  for i,v in ipairs(el.attr.classes) do
    if v == class then
      return true
    end
  end
  return false
end

function find_node(el, predicate)
  if el.content == nil then
    return nil
  end
  for i, v in ipairs(el.content) do
    if predicate(v) then
      return v
    end
    if v.content ~= nil then
      local r = find_node(v, predicate)
      if r ~= nil then
        return r
      end
    end
  end
  return nil
end

function get_block_with_class(el, class)
  return find_node(el, function(el)
    return has_class(el, class)
  end)
end

function get_image(el)
  return find_node(el, function (v)
    return v.t == "Image"
  end)
end

function attribute(el, name, default)
  for k,v in pairs(el.attr.attributes) do
    if k == name then
      return v
    end
  end
  return default
end

return {
  {
    Image = function(image)
      local description = attribute(image, "fig-alt", nil)
      if description == nil then
        return image
      end
      description = pandoc.write(pandoc.Pandoc({description}), "latex")
      if quarto.doc.is_format("latex") then
        local caption = pandoc.write(pandoc.Pandoc({image.caption}), "latex")
        local blockStr = "\\begin{figure}\n" ..
          "{\\centering \\includegraphics{" .. image.src .. "}}\n" ..
          "\\caption{" .. caption .. "}\n\\Description{"
          .. description .. "}\n\\end{figure}\n"
        return {pandoc.RawInline("latex", blockStr)}
      else
        image.attr.attributes["alt"] = description
        image.attr.attributes["fig-alt"] = nil
        return image
      end
    end
  }
}