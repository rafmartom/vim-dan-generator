--- @script codeblock-prompt
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Pandoc Lua Filter to Parse and Identify the programming languages
-- of each codeblock, User will be prompted for each codeblock
-- to identify its extension


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

--- HELPER_FUNCTIONS.
-- @section HELPER_FUNCTIONS


--- Save a local variable to a file in the hard-drive
-- This way we can transfer information from the Lua Script back to bash
-- @usage saveVariableToFile(/path/to/file, "myVar", tostring(myVar))
function saveVariableToFile(filePath, variableName, content)
    if not filePath then
        print(string.format("File path for %s is nil", variableName))
        return false
    end

    local file = io.open(filePath, "w")
    if file then
        file:write(content)
        file:close()
        return true
    else
        print(string.format("Failed to create or write to file: %s", filePath))
        return false
    end
end

--- Load local variable to a file in the hard-drive
-- @usage Use it in conjunction with CLI -V passed to pandoc
--      This way you can recall values from previous filter calls.
--      In the following assume var_filepath is storing a value in the hard-drive
--      We could retrieve its content and store it in my_var
-- Example:
--
-- var_filepath = tostring(PANDOC_WRITER_OPTIONS["variables"]["var_filepath"]) or nil
-- exit_status, my_var = pcall(loadFileContent, var_filepath)
function loadFileContent(filePath)
    if not filePath then
        error("No filePath inputed") 
    end

    local file = io.open(filePath, "r")
    if not file then
        error("File " .. filePath .. " doesn\'t exists") 
    else
        local content = file:read("*all")
        file:close()
        return content
    end
end

--- Check if there is a file in a certain path
function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end


--- Count the lines of a file, for a csv will give you the entry number + the header
function count_file_lines(file_path)

    local file = io.open(file_path, "r")
--    if not file then return 0 end
    if not file then 
        print('not file')
        return 0
    end -- DEBUGGING
    local content = file:read("*a")
    file:close()
    -- Count the number of '\n' characters
    local _, line_breaks = content:gsub("\n", "")
    return line_breaks
end


--- Save a row of the csv into a list
function save_row_to_local_list(extension, filetype)


    -- Initialize the local_row_list entry
   local_row_list = {
       extension = extension,
       filetype = filetype,
       file_cb = file_cb,
       file_processed = file_processed
   }

    -- Append this row to the `local_list`
    table.insert(local_list, local_row_list)
end

-- EOF EOF EOF HELPER_FUNCTIONS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------





-- FUNCTIONS EXECUTED ON THE MAIN SEQUENCE
-- -------------------------------------------------------
-- -------------------------------------------------------

function loading_arguments (doc)

    file_processed = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_processed"]) or nil
    file_no = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_no"]) or nil
    buid_csv = tostring(PANDOC_WRITER_OPTIONS["variables"]["buid_csv"]) or nil


    return doc
end 




local function save_csv(doc)
-- Only save if there was actual human prompting
--  Basically the iterator was consumed
--      And within the file there was at least one cb , so local_list will be populated
if needs_prompting and #local_list > 0 then
    -- SAVING A LIST AS CSV
    -- -----------------------------------
    local csvString = ftcsv.encode(local_list)
    -- Removing the header line
    csvString = csvString:match("^[^\n]*\n(.*)$")

    local file = assert(io.open(csv_path, "a"))
    print(csvString)
    file:write(csvString)
    file:close()
    -- -----------------------------------
end
    return doc
end


-- EOF EOF EOF FUNCTIONS EXECUTED ON THE MAIN SEQUENCE
-- -------------------------------------------------------
-- -------------------------------------------------------


return {
    { Pandoc = loading_arguments },
    { CodeBlock = check_each_cb } ,
    { Pandoc = save_csv } 
}
