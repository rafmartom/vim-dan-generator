--- @script react-native
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Multiline description of the script
-- This filter will parse the text that is embedded in <div class="snack-player">,
-- react element found in this documentation,
-- that is storing actual information to be parsed.


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- IMPORT_DEPENDENCIES.
-- @section IMPORT_DEPENDENCIES


-- GETTING THE PATH WHERE THE SCRIPT IS SAVED
script_path = debug.getinfo(1, "S").source:sub(2)
-- Removing the filename to get the directory path
script_path = script_path:match("(.*/)")
project_path = script_path:match("(.*/)[^/]+/")

package.path = project_path .. "/lua_modules/share/lua/5.4/?.lua;" .. package.path
package.cpath = project_path .. "/lua_modules/lib/lua/5.4/?.so;" .. package.cpath
local httpUtil = require("http.util")


-- EOF EOF EOF IMPORT_DEPENDENCIES 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- FILTER_ELEMENTS.
-- Description of the section
-- @section FILTER_ELEMENTS

--- Parsing special React Element Snack-player
function Div(elem, meta)
    if elem.classes:includes("snack-player") then
        -- SELECTING AN ATTRIBUTE BY ATTRIBUTE NAME AND GETTING ITS VALUE
        for attributeNo, attributeTable in ipairs(elem.attributes) do
            attributeName = tostring(attributeTable[1])
            attributeValue = tostring(attributeTable[2])
            if (attributeName == 'snack-files') then
                break
            end
        end
        -- EOF EOF SELECTING AN ATTRIBUTE BY ATTRIBUTE NAME AND GETTING ITS VALUE


        -- DECODING THE PERCENT ENCODING AND THE NEWLINES
        attributeValue = httpUtil.decodeURIComponent(attributeValue)

       -- Trim the start and end of the attribute value string
        local startTrim = '{"App.tsx":{"type":"CODE","contents":'
        local endTrim = '"}}'

        -- Remove the starting and ending parts of the string
        if string.sub(attributeValue, 1, #startTrim) == startTrim then
            attributeValue = string.sub(attributeValue, #startTrim + 1)
        end
        if string.sub(attributeValue, -#endTrim) == endTrim then
            attributeValue = string.sub(attributeValue, 1, -#endTrim - 1)
        end


        -- Replace \n with actual newlines
        attributeValue = string.gsub(attributeValue, '\\n', '\n')

        -- The string starts with " and finnish with " needs to be trimmed
        attributeValue = attributeValue:gsub("^\"" , ""):gsub("$\"" , "")


        -- Placing it in a CodeBlock 
        return pandoc.CodeBlock(
            attributeValue,
            { class="snack-player-parsed" }
        )
    end
end


-- EOF EOF EOF FILTER_ELEMENTS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
