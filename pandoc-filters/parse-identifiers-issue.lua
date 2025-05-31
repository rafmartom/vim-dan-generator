function parse_identifier(elem, elem_type)
    -- Discard elements with no id
    if elem.identifier == '' or elem.identifier == nil then
        return elem
    end

    print('[DEBUG] elem.identifier : ' .. elem.identifier) -- DEBUGGING
    print('[DEBUG] elem_type : ' .. elem_type) -- DEBUGGING

    return elem
end


return {
    { CodeBlock = function(e) return parse_identifier(e, "CodeBlock") end },
    { Div = function(e) return parse_identifier(e, "Div") end },
    { Figure = function(e) return parse_identifier(e, "Figure") end },
    { Header = function(e) return parse_identifier(e, "Header") end },
    { Table = function(e) return parse_identifier(e, "Table") end },
    { Code = function(e) return parse_identifier(e, "Code") end },
    { Image = function(e) return parse_identifier(e, "Image") end },
    { Link = function(e) return parse_identifier(e, "Link") end },
    { Span = function(e) return parse_identifier(e, "Span") end },
    { Cell = function(e) return parse_identifier(e, "Cell") end },
    { TableFoot = function(e) return parse_identifier(e, "TableFoot") end },
    { TableHead = function(e) return parse_identifier(e, "TableHead") end },
    { Para = function(e) return parse_identifier(e, "Para") end },
    { BlockQuote = function(e) return parse_identifier(e, "BlockQuote") end },
    { BulletList = function(e) return parse_identifier(e, "BulletList") end },
    { OrderedList = function(e) return parse_identifier(e, "OrderedList") end }
}
