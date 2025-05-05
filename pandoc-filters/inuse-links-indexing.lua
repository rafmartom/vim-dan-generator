--- @script inuse-links-indexing
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Pandoc lua filter for vim-dan which populates the column in_use of the links-index.csv
-- 
-- It checks every link element parsed by the reader, checking its href property, and see if 
--    it passes all the criteria of usage such as :
--      - Point to an existant file
--      - Point to an existant tag 
--
--  - Logic behind it (the same as ./inline-links
--
--    0 - Discard all External Links or Unknown
--      <a href="https://www.google.com">Google</a> 
--
--    1 - Separate the path part from the anchor path it has such
--
--    2 - (only for Relative Links) Normalize them
--
--
-- For each relative link (e.g., `href="/guidance/living-in-spain"`):
-- 
--    3 - . Search if the path exists locally in the downloaded PATH:
--      `${DOCU_PATH}/downloaded/guidance/living-in-spain.html`
--
--  If it does
--      - If it is not an anchor link
--       3. Search in the ${DOCU_PATH}/links-index.csv for its BUID
--          Write an Inline Absolute Link
--          <L=BUID>label</L>
--       
--   
--      - If it is an anchor link
--       3. Search in the ${DOCU_PATH}/links-index.csv
--          Write an Inline Relative Link
--          <L=BUID#IID>label</L>
--    4 - If the link passes all the criteria write a 1 in the last column of the csv (in_use)
--         Otherwise write a 0 
--
-- Example:
--
--  pandoc -f html -t plain -o ${content_dump} \
-- -L $(realpath ${CURRENT_DIR}/../pandoc-filters/inuse-links-indexing.lua)"\
-- -V docu_path=${DOCU_PATH} \
-- -V file_processed=\"${filename}\" \
-- -V links_index_csv=${links_index_csv} 
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

local DEBUG = false -- Activate the debugging mode

local docu_path = nil
local links_index_csv = nil
local file_processed = nil

local entries = {}
local headers = nil


local href = nil 
local full_path = nil 
local rel_path = nil
local link_text = nil
local path = nil
local anchor = nil
local file_exists_result = nil


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


--- Strip leading slash of a path
function strip_lead_slash(myPath)
    if myPath == nil or myPath == "" then
        error("Error: strip_lead_slash requires a non-empty myPath argument.")
    end
    return string.gsub(myPath, "^/", "")
end

--- Append .html to the myPath string if is not present
function append_html(myPath)
    if not string.match(myPath, "%.html$") then
        return myPath .. ".html"
    end
    return myPath
end


--- strip_html strips the ".html" present in myPath
function strip_html(myPath)
    if myPath == nil or myPath == "" then
        error("Error: strip_html requires a non-empty myPath argument.")
    end
    return string.gsub(myPath, "%.html$", "")
end


--- Get the basename of a path
function basename(myPath)
    return string.match(myPath, "[^/]+$")
end


--- Create the danlinkfrom string
function create_danlinkfrom(href)
    local linkfrom_prefix = append_html(href)
--    local linkfrom_title = strip_html(basename(href))
    local linkfrom_title = PATH.basename(href)
    return '& @' .. linkfrom_prefix .. '@ ' .. linkfrom_title .. ' &'
end


--- Check if a file exists
function file_exists(full_path)
    local file = io.open(full_path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

--- Check if a path refers to a dir
function is_dir(input_path)
    if string.match(input_path, "/$") then
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
    if anchor ~= "" then
        return path, anchor
    else
        return href, false
    end
end

--- Check if link it has got a relative path on it 
-- @param href Link to be analized
-- @return True if it has a relative path on it
function is_relative_link(href)
    if href:match("^%.") or href:match("^%a") then
        return true
    end
    return false 
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


-- @deprecated 
----- Sort the link into different categories
---- @param href The link to sort
---- @return Either { External, Anchor, Internal Absolute, Internal Relative }
--function sorting_link(href)
--    if href_basename:match("^#%a") then
--        return 'Anchor'
--    elseif href:match("^#$") or href:match("^https?://") or href:match("^//") then
--        return 'External'
--    elseif href:match("^/") then
--        return 'Internal Absolute'
--    elseif href:match("^%.") or href:match("^%a") or href_basename:match("^#%a") then
--        return 'Internal Relative'
--    end
--        return 'Unknown'
--end


--- Retrieves the vim-dan BUID of a link from a links-index.csv
-- @param rel_path The required argument. Must not be nil or empty.
-- @param links_index_csv The csv with the info of the links
-- @see https://luarocks.org/modules/fouriertransformer/ftcsv
-- @return string|nil: The BUID if found, or nil if not found.
function get_buid_from_link (rel_path, links_index_csv)
    for index, link_entry in ftcsv.parseLine(links_index_csv) do
        if link_entry.path == rel_path then
            return link_entry.buid
        end
    end
end

--- Retrieves the vim-dan IID of a link from a links-index.csv
-- @param rel_path string: The required path. Must not be nil or empty.
-- @param anchor string: The required anchor ID. Must not be nil or empty.
-- @param links_index_csv string: Path to the CSV with link info.
-- @see https://luarocks.org/modules/fouriertransformer/ftcsv
-- @return string|nil: The IID if found, or nil if not found.
function get_iid_from_link (rel_path, anchor, links_index_csv)
    for index, link_entry in ftcsv.parseLine(links_index_csv) do
        if link_entry.path == rel_path and link_entry.anchor_id == anchor then
            return link_entry.iid
        end
    end
end


--- Loading the csv in use for the filter
-- @param links_index_csv The csv with the info of the links
-- @return list: entries
-- @return list: headers
function loading_csv(links_index_csv)
    local entries, headers = ftcsv.parse(links_index_csv, ",", {headers=false})
    return entries, headers
end

--- Marks in_use=true if the entry matches the target rel_path and anchor
-- @param rel_path string: The relative path to match
-- @param anchor string: The anchor to match
-- @param entries table: List of the entries of the loaded in memory links_index_csv
function mark_links_in_use(rel_path, anchor, entries)
    for i, entry in ipairs(entries) do
        -- Check if this entry matches both rel_path and anchor
        -- Note: CSV entries are parsed as arrays when headers=false
        if entry[1] == rel_path and entry[5] == anchor then
            -- Change the last field (in_use) to true
            entry[#entry] = "true"
        end
    end
end




------ Saves the modified entries back to CSV
----- @param list table: The modified entries
----- @param headers table: The CSV headers
----- @param links_index_csv string: Path to save the CSV file
---function save_list_to_csv(list, headers, links_index_csv)
---    local file = io.open(links_index_csv, "w")
---    
-----    -- Write headers first if they exist
-----    if headers then
-----        file:write(table.concat(headers, ",") .. "\n")
-----    end
---    
---    -- Write each entry
---    for _, entry in ipairs(list) do
---        file:write(table.concat(entry, ",") .. "\n")
---    end
---    
---    file:close()
---end

--- Saves the modified entries back to CSV
-- @param list table: The modified entries (array of arrays)
-- @param headers table: The CSV headers
-- @param links_index_csv string: Path to save the CSV file
function save_list_to_csv(list, headers, links_index_csv)
    local file = io.open(links_index_csv, "w")
    
    -- Convert array-style entries to CSV lines manually
    for _, entry in ipairs(list) do
        local quoted_fields = {}
        
        -- Quote each field and handle nil values
        for _, value in ipairs(entry) do
            value = value or ""  -- handle nil values
            -- Only quote if needed (contains comma, quote, or newline)
            if tostring(value):find('[,"\n]') then
                value = '"' .. tostring(value):gsub('"', '""') .. '"'
            end
            table.insert(quoted_fields, value)
        end
        
        file:write(table.concat(quoted_fields, ",") .. "\n")
    end
    
    file:close()
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
    docu_path = tostring(PANDOC_WRITER_OPTIONS["variables"]["docu_path"]) or nil
    links_index_csv = tostring(PANDOC_WRITER_OPTIONS["variables"]["links_index_csv"]) or nil
    file_processed = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_processed"]) or nil

    return doc
end

function loading_csv_subroutine(doc)
    entries, headers = loading_csv(links_index_csv)
    return doc
end


function save_list_to_csv_subroutine(doc)
    save_list_to_csv(entries, headers, links_index_csv)
    return doc
end


--- Triggering subroutine to check each link found
function check_links(elem)
    local href = elem.target  
    local full_path = nil
    local rel_path = href
    local link_text = nil
    

    href_basename = PATH.basename(href)

    -- Correction for urls that finnish in path
    --  for instance href="../footagesource/" that will be pointing to
    --         href="../footagesource/index.html"
    if is_dir(href) then
        href = href .. "./index.html"
    end


    -- Sorting the kind of link we have
    -- Remember:
    --   External Links : (Either absolute or relative) Start with https:// or http://
    --       <a href="https://www.google.com">Google</a> 
    --   Anchor Links :
    --       <a href="#section1">Jump to Section 1</a>
    --   Internal Absolute Links : 
    --       <a href="/about/us.html">About Us</a>
    --   Internal Relative Links :
    --       <a href="about/us.html">About Us</a>
    --       <a href="../about/us.html">About Us</a>
   

    -- 0 - Discard all External Links or Unknown
    if is_external_link(href) then
        return
    end 

    -- 1 - Separate the path part from the anchor path it has such
    path , anchor  = separate_path_from_anchor(href)

    -- correct if the href doesn't have a path section doesnt exit
    -- meaning is a fragment identifier
    -- i.e : <a href="#section1">Go to Section 1</a>
    -- We need to correct it to point to the current file_processed
    if path == '' then
        path = PATH.basename(file_processed)
    end


    -- 2 - (only for Relative Links) Normalize them
    full_path = PATH.normalize(docu_path .. "/downloaded" .. PATH.dirname(file_processed) .. '/' .. PATH.normalize(path))
    rel_path = PATH.normalize(PATH.dirname(file_processed) .. '/' .. path)



    -- 3 - Search if the path exists locally in the downloaded PATH:
    file_exists_result = file_exists(full_path)


    -- If it doesn't exist skip and go to the next CodeBlock
    if not file_exists_result then
        dprint('[DEBUG] This File Doesnt Exists locally : ') -- DEBUGGING

        return
    end
    

    mark_links_in_use('.' .. rel_path, anchor, entries)

    return 

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
    { Link = check_links }, 
    { Pandoc = save_list_to_csv_subroutine }
}


-- EOF EOF EOF SUBROUTINE_CALLS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
