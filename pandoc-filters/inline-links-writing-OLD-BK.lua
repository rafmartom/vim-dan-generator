--- @script inline-links-writing
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
--
-- Pandoc Lua Filter for use in vim-dan-generator in the writting process, it will analize each
--      link source and link target found, and match it against a 'links-index.csv' previously 
--      processed by filters 'links-indexing.lua' , and 'inuse-links-indexing.lua'
--      on 'links-index.csv' checking against it
--      - Will write
--          - All link source that are referred to is_anchor = 'false'
--          - All link source that are referred to is_anchor = 'true' and in_use = 'true'
--          - All link target that are referred to in_use = 'true'
--
--
-- pandoc -f html -t plain ./downloaded/spain.html \
--   -L danlinkfrom-href.lua \
--   -V docu_path="$(readlink -f ./)"
--
-- pandoc -f html -t plain ./downloaded/jsobjref/Application.html \
--   -V file_processed="./downloaded/jsobjref/Application.html" \
--   -L $(realpath ${CURRENT_DIR}/../pandoc-filters/inline-links-writing.lua)" \
--   -V links_index_csv=/home/fakuve/downloads/vim-dan/adobe-ai/links-index.csv \
--
--


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
local PATH = require("path")
local ftcsv= require('ftcsv')


-- EOF EOF EOF IMPORT_DEPENDENCIES 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SCRIPT_VAR_INITIALIZATION.
-- @section SCRIPT_VAR_INITIALIZATION

local DEBUG = true -- Activate the debugging mode
local block_counter = 0 -- DEBUGGING

local links_index_csv = nil
local file_processed = nil

local entries = {}
local headers = nil

local href = nil
local link_text = nil
local path = nil
local rel_path = nil
local anchor = nil


local formed_link = nil

-- EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------





-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- HELPER_FUNCTIONS.
-- Functions needed within the script
-- @section HELPER_FUNCTIONS

--- Print the statement if the debug mode is activated
-- @usage local DEBUG = true -- Activate the debugging mode
-- dprint('[DEBUG] myVar : ' , myVar) -- DEBUGGING
function dprint(...)
    if DEBUG then
        print(...) 
    end
end

--- Check if the link refers to an external resource
-- @param href Link to be analized
-- @return True if is external
function is_external_link(href)
    if href:match("^#$") or href:match("^https?://") or href:match("^//") then
        return true
    end 
    return false
end


--- Separates the path from the anchor part in a URL
-- @param href string The URL to be analyzed (e.g., "page.html#section")
-- @return string The base path portion (everything before '#')
-- @return string|boolean The anchor portion (after '#'), or false if no anchor exists
-- @usage
-- local path, anchor = separate_path_from_anchor("file.html#intro")
-- -- path = "file.html", anchor = "intro"
-- local path, anchor = separate_path_from_anchor("file.html")
-- -- path = "file.html", anchor = false
function separate_path_from_anchor(href)
    local path, anchor = href:match("([^#]*)#?(.*)")
    if anchor == "" then
        anchor = false
    end
    if path == "" then
        path = false
    end
    return path, anchor
end


--- Loading the csv in use for the filter
-- @param links_index_csv The csv with the info of the links
-- @return list: entries
-- @return list: headers
function loading_csv(links_index_csv)
    local entries, headers = ftcsv.parse(links_index_csv, ",", {headers=false})
    return entries, headers
end

-- EOF EOF EOF HELPER_FUNCTIONS
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SUBROUTINE_DECLARATIONS.
-- @section SUBROUTINE_DECLARATIONS


--- Load the arguments of the filter from variables
function loading_arguments (doc)
    links_index_csv = tostring(PANDOC_WRITER_OPTIONS["variables"]["links_index_csv"]) or nil
    file_processed = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_processed"]) or nil

dprint('[DEBUG] links_index_csv : ' .. links_index_csv) -- DEBUGGING
dprint('[DEBUG] file_processed : ' .. file_processed) -- DEBUGGING


    return doc
end

function loading_csv_subroutine(doc)
    entries, headers = loading_csv(links_index_csv)
    return doc
end


--- Check each link source <a> HTML tag against 'links-index.csv'
--    Form its appropiate link source if it is
--      Either is_anchor = 'false'
--             is_anchor = 'true' and in_use = 'true'
function check_link_source(elem)
    href = elem.target
dprint('[DEBUG] href : ' .. href) -- DEBUGGING


    local ok, result = pcall(pandoc.utils.stringify, elem.content)
    if ok then
        link_text = result
    else
        return elem
    end

    -- 0 - Discard all External Links or Unknown
    if is_external_link(href) then
        return elem
    end 

    -- 1 - Separate the path part from the anchor path it has such
    path , anchor  = separate_path_from_anchor(href)

dprint('[DEBUG] path before NORMALIZED : ' .. tostring(path)) -- DEBUGGING

    -- Add path if it doesnt have such a component
    --   and Normalize path component to the root marked by docu_path
    if not path then
        path = file_processed
    elseif path:match("^/") then
        -- if href is '/en-US/docs/Web/CSS/Nesting_selector' the path doesnt need to be normalized
        
        -- if path ends without extension
        -- either it ends on a / directory , add index.html 
        if path:match("%/$") then
            path = path .. 'index.html'

        -- or it ends on a file without extension , add .html
        elseif not path:match("%.html$") then
            path = path .. '.html'

        end
    else 
        path = PATH.normalize(PATH.dirname(file_processed) .. '/' .. path)
    end


dprint('[DEBUG] path after NORMALIZED : ' .. path) -- DEBUGGING

    -- Make it relative adding './'
    -- Add './' if it doesn't start with './' or '/'
    -- If it starts with '/', just prepend '.'
    if not path:match('^%./') and not path:match('^/') then
        rel_path = './' .. path
    elseif path:match('^/') then
        rel_path = '.' .. path
    end

dprint('[DEBUG] rel_path after ./ /: ' .. rel_path) -- DEBUGGING
dprint('[DEBUG] anchor : ' .. tostring(anchor)) -- DEBUGGING

--dprint('[DEBUG] entry[1] : ' .. entry[1]) -- DEBUGGING
--dprint('[DEBUG] entry[2] : ' .. entry[2]) -- DEBUGGING
--dprint('[DEBUG] entry[3] : ' .. entry[3]) -- DEBUGGING
--dprint('[DEBUG] entry[4] : ' .. entry[4]) -- DEBUGGING
--dprint('[DEBUG] entry[5] : ' .. entry[5]) -- DEBUGGING
--dprint('[DEBUG] entry[6] : ' .. entry[6]) -- DEBUGGING
--dprint('[DEBUG] entry[7] : ' .. entry[7]) -- DEBUGGING
--dprint('[DEBUG] entry[8] : ' .. entry[8]) -- DEBUGGING

    for i, entry in ipairs(entries) do
        -- Parsing non anchor links sources
        -- 2. if is_anchor = 'false' write
        if not anchor and entry[1] == rel_path and entry[2] == 'false' then
            formed_link = '<L=' .. entry[6] .. '>' .. link_text .. '</L>'
            dprint('Parsing non-anchor link source' .. formed_link) -- DEBUGGING
            dprint('[DEBUG] formed_link : ' .. formed_link) -- DEBUGGING
            return pandoc.Str(formed_link)
        -- 3. if is_anchor = 'true' and in_use = 'true' write
        elseif entry[1] == rel_path and entry[5] == anchor and entry[2] == 'true' and entry[8] == 'true'  then
--dprint('[DEBUG] entry[6] : ' .. entry[6]) -- DEBUGGING
--dprint('[DEBUG] entry[7] : ' .. entry[7]) -- DEBUGGING
           formed_link = '<L=' .. entry[6] .. '#' .. entry[7] .. '>' .. link_text .. '</L>'
           dprint('Parsing anchor link source' .. formed_link) -- DEBUGGING
           dprint('[DEBUG] formed_link : ' .. formed_link) -- DEBUGGING
--            dprint('[DEBUG] formed_link : ' .. formed_link) -- DEBUGGING
            return pandoc.Str(formed_link)
        end

    end

    return elem

end



function check_link_target(elem, elem_type)
    block_counter = block_counter + 1
    -- Get the normalized path of the file being processed
    rel_path = PATH.normalize(file_processed)

    -- Normalize relative paths:
    if not rel_path:match('^%./') and not rel_path:match('^/') then
        rel_path = './' .. rel_path
    elseif rel_path:match('^/') then
        rel_path = '.' .. rel_path
    end

    -- If element doesn't have id, it cannot be a link target
    anchor_id = elem.identifier or ""  -- Default to empty string if nil
    if anchor_id == "" then
        return elem  -- Return unchanged if no anchor_id
    end


    dprint('[DEBUG] elem_type', elem_type)
    dprint('[DEBUG] block_counter : ' .. block_counter) -- DEBUGGING
    dprint('[DEBUG] rel_path : ' .. rel_path)
    dprint('[DEBUG] anchor_id : ' .. anchor_id)
--    dprint('[DEBUG] link_text : ' .. link_text) -- DEBUGGING

    for i, entry in ipairs(entries) do
        if entry[1] == rel_path and entry[5] == anchor_id and entry[8] == 'true' then
            local formed_link = '<I=' .. entry[6] .. '#' .. entry[7] .. '>'
            dprint('[DEBUG] formed_link : ' .. formed_link) -- DEBUGGING


            if elem_type == 'Table' then
                -- Convert Table to SimpleTable for easier manipulation
                local simple_table = pandoc.utils.to_simple_table(elem)
                
                -- Prepend formed_link to the caption (or another part if desired)
                local new_caption = {}
                table.insert(new_caption, pandoc.Str(formed_link))
                for _, inline in ipairs(simple_table.caption) do
                    table.insert(new_caption, inline)
                end
                
                -- Create new SimpleTable with modified caption
                local new_simple_table = pandoc.SimpleTable(
                    new_caption,               -- Updated caption with formed_link
                    simple_table.aligns,       -- Original alignments
                    simple_table.widths,       -- Original widths
                    simple_table.headers,      -- Original headers
                    simple_table.rows          -- Original rows
                )
                
                -- Convert back to Table
                return pandoc.utils.from_simple_table(new_simple_table)
            elseif elem_type == 'CodeBlock' then
                -- Append formed_link to the text field
                local new_text = (elem.text or "") .. "\n" .. formed_link
                return pandoc.CodeBlock(new_text, elem.attr)
            elseif elem_type == 'Code' then
                -- Append formed_link as a separate inline element
                return pandoc.Span({elem, pandoc.Str(" "), pandoc.Str(formed_link)}, elem.attr)
            else
                -- Handle other element types as before
                local new_content = {}

                -- Traverse through the content of the element
                for _, block in ipairs(elem.content or {}) do
                    if block.t == "Para" then
                        local inline_content = {}
                        for _, inline in ipairs(block.content) do
                            table.insert(inline_content, inline)
                        end
                        table.insert(new_content, pandoc.Para(inline_content))
                    else
                        table.insert(new_content, block)
                    end
                end

                -- Append formed_link to content
                table.insert(new_content, pandoc.Str(formed_link))

                -- Return appropriate element type
                if elem_type == 'CodeBlock' then
                    return pandoc.CodeBlock(new_content, elem.attr)
                elseif elem_type == 'Div' then
                    return pandoc.Div(new_content, elem.attr)
                elseif elem_type == 'Figure' then
                    return pandoc.Div(new_content, elem.attr)  -- fallback
                elseif elem_type == 'Header' then
                    return pandoc.Header(elem.level, new_content, elem.attr)
                elseif elem_type == 'Code' then
                    return pandoc.Code(new_content, elem.attr)
                elseif elem_type == 'Link' then
                    return pandoc.Link(new_content, elem.attr)
                elseif elem_type == 'Span' then
                    return pandoc.Span(new_content, elem.attr)
                elseif elem_type == 'Cell' then
                    return pandoc.Plain(new_content)
                elseif elem_type == 'Para' then
                    return pandoc.Para(new_content, elem.attr)
                elseif elem_type == 'BlockQuote' then
                    return pandoc.BlockQuote(new_content, elem.attr)
                elseif elem_type == 'BulletList' then
                    return pandoc.BulletList(new_content, elem.attr)
                elseif elem_type == 'OrderedList' then
                    return pandoc.OrderedList(new_content, elem.attr)
                else
                    return elem
                end
            end
        end
    end

    return elem
end



-- EOF EOF EOF SUBROUTINE_DECLARATIONS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SUBROUTINE_CALLS.
-- Define the flow of execution of the filter, calling the previously defined subroutines.
-- @section SUBROUTINE_CALLS

return {

    { Pandoc = loading_arguments },
    { Pandoc = loading_csv_subroutine },
    { Link = check_link_source },
    { CodeBlock = function(e) return check_link_target(e, "CodeBlock") end },
    { Div = function(e) return check_link_target(e, "Div") end },
    { Figure = function(e) return check_link_target(e, "Figure") end },
    { Header = function(e) return check_link_target(e, "Header") end },
    { Table = function(e) return check_link_target(e, "Table") end },
    { Code = function(e) return check_link_target(e, "Code") end },
--    { Image = function(e) return check_link_target(e, "Image") end },
    { Link = function(e) return check_link_target(e, "Link") end },
    { Span = function(e) return check_link_target(e, "Span") end },
    { Cell = function(e) return check_link_target(e, "Cell") end },
--    { TableHead = function(e) return check_link_target(e, "TableHead") end },
--    { TableBody = function(e) return check_link_target(e, "TableBody") end },
--    { TableFoot = function(e) return check_link_target(e, "TableFoot") end },
    { Para = function(e) return check_link_target(e, "Para") end },
    { BlockQuote = function(e) return check_link_target(e, "BlockQuote") end },
    { BulletList = function(e) return check_link_target(e, "BulletList") end },
    { OrderedList = function(e) return check_link_target(e, "OrderedList") end }

}

-- EOF EOF EOF SUBROUTINE_CALLS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
