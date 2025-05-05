--- @script indexing-links-target
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Pandoc Lua Filter for use in vim-dan-generator that parses all the links target of a given file
--   into a .csv file  we call "links-target-index.csv"
--     It will be writting them into a .csv
--         - {DOCU_PATH}/links-target-index.csv
--         path,label,is_anchor,anchor_id,buid,iid,
--             - path: The file its originated on
--                 /guidance/living-in-spain.html
--             - is_anchor: Parsing all the html elements which has id="" , true if they come from that
--             - pandoc_data_type: Origin of the anchor link , such as "CodeBlock", "Div", "Header"
--             - label: 
--                 - If it is the one addressing the file (is_anchor=false) its parsed title ${paths_linkto[$path]}
--                 - If is_anchor=true , is element.textContent()
--             - anchor_id: html id="" property value.
--             - buid: Block Unique ID, ID assigned to the file
--             - iid: Inline ID, ID assigned to the anchor ID
--
-- an example of "links-target-index.csv" 
-- 
-- path                      ,is_anchor,pandoc_data_type ,label        ,anchor_id,buid,iid,
-- /guidance/living-in-spain.html,false,,"Living in Spain",,f3,,
-- /guidance/living-in-spain.html,true,"Header","Introduction","topicIntro",f3,1,
-- /guidance/living-in-spain.html,true,"Header","Considerations","topicConsider",f3,2,
-- /guidance/living-in-zambia.html,false,,"Living in Zambia",,f4,,
-- /guidance/living-in-zambia.html,true,"Header","Introduction","topicIntro",f4,,1
-- /guidance/living-in-zambia.html,true,"Header","Considerations","topicConsider",f4,,2
--  
--  Note 1: Filter is applied in a per file basis, in order to create a complete index of the link
--      it is meant to be used in a iteration of all the files
--
--  Note 2: Filter is meant to be used in the process of indexing the target links, which
--      Doesn't involve any writting process, thus redirect output to /dev/null
--
-- Example:
--  (an iteration of it)
-- sed 's/role="main"//g' | pup -i 0 --pre 'li.current, .rst-content' | \
--      pandoc -f html -t plain -o /dev/null \
-- -L $(realpath ${CURRENT_DIR}/../pandoc-filters/indexing-links-target.lua)" \
-- -V file_processed="./jsobjref/ExportOptionsPhotoshop.html" \
-- -V csv_path=/home/fakuve/downloads/vim-dan/adobe-ai/links-target-index.csv \
-- -V parsed_title="ExportOptionsPhotoshop" -V file_no=34
-- 
--  This is inside a
--
--    for file in "${files_array[@]}"; do
--        for title_parsing in "${title_parsing_array[@]}"; do
--        done
--    done




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
local ftcsv = require('ftcsv')


-- EOF EOF EOF IMPORT_DEPENDENCIES 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------




-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SCRIPT_VAR_INITIALIZATION.
-- @section SCRIPT_VAR_INITIALIZATION

local DEBUG = false -- Activate the debugging mode

local links_index_csv = nil
local file_processed = nil
local rel_path = nil
local parsed_title = nil
local file_no = nil

local inline_link_target_counter = 1 

local is_anchor = nil
local pandoc_data_type = nil
local label = nil
local anchor_id = nil
local buid = nil
local iid = nil

-- EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- HELPER_FUNCTIONS.
-- @section HELPER_FUNCTIONS


--- Print the statement if the debug mode is activated
-- @usage local DEBUG = true -- Activate the debugging mode
-- dprint('[DEBUG] myVar : ' , myVar) -- DEBUGGING
function dprint(...)
    if DEBUG then
        print(...) 
    end
end


--- Generate a vim-dan ID 
-- @param input_counter The counter taking as reference. 
--   For BUID it will be the file_no , for IID will be the inline_link_target_counter
function generate_uid(input_counter)
    return decimal_to_alphanum(input_counter)
end

--- Transforms a decimal number to base-62 alphanumeric string
-- Maps numbers to [0-9a-zA-Z] (in that order)
-- @param input_no The decimal number to convert (must be >= 0)
-- @return string The base-62 alphanumeric representation
function decimal_to_alphanum(input_no)
    local alphanum = {}
    -- Create the base-62 character set: 0-9, a-z, A-Z
    for i = 48, 57 do table.insert(alphanum, string.char(i)) end  -- 0-9
    for i = 97, 122 do table.insert(alphanum, string.char(i)) end -- a-z
    for i = 65, 90 do table.insert(alphanum, string.char(i)) end  -- A-Z

    local base = #alphanum
    local output_string = ""
    local num = input_no

    -- Handle zero case
    if num == 0 then
        return alphanum[1] -- returns "0"
    end

    while num > 0 do
        local remainder = (num % base) + 1 -- Lua arrays are 1-indexed
        output_string = alphanum[remainder] .. output_string
        num = math.floor(num / base)
    end

    return output_string
end

--- A string you want to surround in " quotes
-- @param string 
-- @return string Surrounded by quotes string
local function surround_by_quotes(string)
    -- Convert nil to empty string
    string = string or ""
    -- Convert to string if it isn't already
    string = tostring(string)
    -- Escape double quotes by doubling them
    string = string:gsub('"', '""')
    -- Wrap in quotes
    return '"' .. string .. '"'
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
    dprint('[DEBUG] Into loading_arguments') -- DEBUGGING    

    links_index_csv = tostring(PANDOC_WRITER_OPTIONS["variables"]["links_index_csv"]) or nil
    file_processed = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_processed"]) or nil
    parsed_title = tostring(PANDOC_WRITER_OPTIONS["variables"]["parsed_title"]) or nil
    file_no = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_no"]) or nil

dprint('[DEBUG] links_index_csv : ' .. links_index_csv) -- DEBUGGING
dprint('[DEBUG] file_processed : ' .. file_processed) -- DEBUGGING
dprint('[DEBUG] parsed_title : ' .. parsed_title) -- DEBUGGING
dprint('[DEBUG] file_no : ' .. file_no) -- DEBUGGING

    return doc
end 


--- Appends the entry of the current file as a block_link to the "links-target-index.csv"
function append_block_link(doc)
    rel_path = '.' .. file_processed
    is_anchor = false
    pandoc_data_type = ''
    label = parsed_title
    anchor_id = ''
    buid = generate_uid(tonumber(file_no))
    iid = ''

    output_str = string.format("%s,%s,%s,%s,%s,%s,%s,false\n", rel_path, is_anchor, pandoc_data_type, surround_by_quotes(label), surround_by_quotes(anchor_id), buid, iid)

    -- Append to file (like "echo ... >> file" in bash)
    local file = io.open(links_index_csv, "a")  -- "a" = append mode
    if file then
        file:write(output_str)
        file:close()
    else
        io.stderr:write("Failed to open links_index_csv for appending: " .. links_index_csv .. "\n")
    end


    return doc
end

--- Appends an entry for an inline_link to the "links-target-index.csv"
-- This function iterates through each element that is subject to become a link-target
function append_inline_link(elem, elem_type)


    -- Discard elements with no id
    if elem.identifier == '' or elem.identifier == nil then
        return elem
    end

    dprint('[DEBUG] elem.identifier : ' .. elem.identifier) -- DEBUGGING

    rel_path = '.' .. file_processed
    is_anchor = true
    pandoc_data_type = elem_type
    -- @todo elem.innerText
    -- label = pandoc.utils.stringify(elem)
    anchor_id = elem.identifier
    iid = generate_uid(inline_link_target_counter)

    output_str = string.format("%s,%s,%s,%s,%s,%s,%s,false\n", rel_path, is_anchor, pandoc_data_type, surround_by_quotes(label), surround_by_quotes(anchor_id), buid, iid )


    -- Append to file (like "echo ... >> file" in bash)
    local file = io.open(links_index_csv, "a")  -- "a" = append mode
    if file then
        file:write(output_str)
        file:close()
    else
        io.stderr:write("Failed to open links_index_csv for appending: " .. links_index_csv .. "\n")
    end


    inline_link_target_counter = inline_link_target_counter + 1
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
    { Pandoc = append_block_link},
    { CodeBlock = function(e) return append_inline_link(e, "CodeBlock") end },
    { Div = function(e) return append_inline_link(e, "Div") end },
    { Figure = function(e) return append_inline_link(e, "Figure") end },
    { Header = function(e) return append_inline_link(e, "Header") end },
    { Table = function(e) return append_inline_link(e, "Table") end },
    { Code = function(e) return append_inline_link(e, "Code") end },
    { Image = function(e) return append_inline_link(e, "Image") end },
    { Link = function(e) return append_inline_link(e, "Link") end },
    { Span = function(e) return append_inline_link(e, "Span") end },
    { Cell = function(e) return append_inline_link(e, "Cell") end },
    { TableFoot = function(e) return append_inline_link(e, "TableFoot") end },
    { TableHead = function(e) return append_inline_link(e, "TableHead") end },
    { Para = function(e) return append_inline_link(e, "Para") end },
    { BlockQuote = function(e) return append_inline_link(e, "BlockQuote") end },
    { BulletList = function(e) return append_inline_link(e, "BulletList") end },
    { OrderedList = function(e) return append_inline_link(e, "OrderedList") end }
}

-- EOF EOF EOF SUBROUTINE_CALLS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
