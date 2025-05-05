-- Script to Parse and Identify the programming languages
-- of each codeblock
-- It will use only 1 extension provided by the argument
-- Populating the pertaining ext-csv  (ex "")
--     Useful to run it on the first time , so it can populate the ext-csv with one extension
-- -----------------------------------------------------------

-- ----------------------------------------------------------------------------
-- @section ENVIRONMENT_SETUP
-- @description Set up crucial variables and require dependencies

-- GETTING THE PATH WHERE THE SCRIPT IS SAVED
script_path = debug.getinfo(1, "S").source:sub(2)
-- Removing the filename to get the directory path
script_path = script_path:match("(.*/)")
project_path = script_path:match("(.*/)[^/]+/")

package.path = project_path .. "/lua_modules/share/lua/5.4/?.lua;" .. package.path
package.cpath = project_path .. "/lua_modules/lib/lua/5.4/?.so;" .. package.cpath

local ftcsv = require('ftcsv')

-- EOF EOF EOF ENVIRONMENT_SETUP 
-- ----------------------------------------------------------------------------


-- SCRIPT VARIABLE INITIALITATION
-- ------------------------------------
-- ------------------------------------
local exit_status = nil
local scr_choice_1 = nil
local choice_1 = nil
local scr_choice_2 = nil
local choice_2 = nil
local scr_choice_3 = nil
local choice_3 = nil
-- Path for the csv with the extensions
local csv_path = nil

local csv_exists = nil
local csv_row_iterator = nil
local needs_prompting = true

local scr_global_current_cb = nil
local global_current_cb = nil

local file_processed = nil

local choice_list = {}
local file_cb = nil 

local local_row_list = {}
local local_list = {}

-- EOF EOF SCRIPT VARIABLE INITIALITATION
-- ------------------------------------
-- ------------------------------------


-- HELPER FUNCTION DEFINITIONS
-- -------------------------------------------------------
-- -------------------------------------------------------

local function saveVariableToFile(filePath, variableName, content)
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

local function loadFileContent(filePath)
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

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end


--------- Will count the lines of a file, for a csv will give you the entry number + the header
local function count_file_lines(file_path)

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


local function save_row_to_local_list(extension, filetype)


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


-- Execute cmd in a new shell an capture the output in its return value
-- Ex: output = os.capture("node " "/scripts/helloWorld.js")
--------------------------------------------------------------------------
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end
--------------------------------------------------------------------------


local function prompt_user (elem)
    print('--------------------------------------------------')
    print('--------------------------------------------------')
    print(elem.text)
    print('--------------------------------------------------')
    print('--------------------------------------------------')
    print('What extension correspond this code to?')
    print('Previous 2 choices ; (1 , Enter):' .. (choice_list[#choice_list] or "nil") .. ' (2):' .. (choice_list[#choice_list - 1]  or "nil") .. ' (3):' .. (choice_list[#choice_list - 2]  or "nil")) 

    -- Pass the text to clip.exe
    local pipe = io.popen("clip.exe", "w")
    if pipe then
        pipe:write(elem.text)
        pipe:close()
        print('Text copied to Wsl clipboard')
    else
        print("Failed to access Wsl clipboard.")
    end


    -- PROMPTING FOR USER INPUT ON TTY-----
    local tty = io.open("/dev/tty", "r+")

    if tty then
        current_choice = tty:read("*l")
        tty:close()
    else
        -- Fallback to standard input if /dev/tty is unavailable
        current_choice = io.input():read("*l")
    end
    ---------------------------------------


    if current_choice == '1' or current_choice == '' then
        extension = choice_list[#choice_list]
    elseif current_choice == '2' then
        extension = choice_list[#choice_list - 1]
    elseif current_choice == '3' then
        extension = choice_list[#choice_list - 2]
    else
        extension = current_choice
    end

    return extension
end

-- EOF EOF EOF HELPER FUNCTION DEFINITIONS
-- -------------------------------------------------------
-- -------------------------------------------------------


-- FUNCTIONS EXECUTED ON THE MAIN SEQUENCE
-- -------------------------------------------------------
-- -------------------------------------------------------

function loading_arguments (doc)
--print('Into loading_arguments') -- DEBUGGING    

    -- Load contents into separate variables
    scr_choice_1 = tostring(PANDOC_WRITER_OPTIONS["variables"]["scr_choice_1"]) or nil
    exit_status, choice_1 = pcall(loadFileContent, scr_choice_1)
    choice_list[1] = choice_1
    scr_choice_2 = tostring(PANDOC_WRITER_OPTIONS["variables"]["scr_choice_2"]) or nil
    exit_status, choice_2 = pcall(loadFileContent, scr_choice_2)
    choice_list[2] = choice_2
    scr_choice_3 = tostring(PANDOC_WRITER_OPTIONS["variables"]["scr_choice_3"]) or nil
    exit_status, choice_3 = pcall(loadFileContent, scr_choice_3)
    choice_list[3] = choice_3
    csv_path = tostring(PANDOC_WRITER_OPTIONS["variables"]["csv_path"]) or nil
    -- checking if csv_path exists
    if not file_exists(csv_path) then
        -- If it doesnt exist create the file with its headers
-- For some reason the fields will be stored in this order up to the ftcsv library
--        local csv_string_headers = '"file_processed","file_cb","extension"\n'

        local csv_string_headers = '"extension","file_cb","file_processed","filetype"\n'
        local file = assert(io.open(csv_path, "a"))
        file:write(csv_string_headers)
        file:close()
    end


    scr_global_current_cb = tostring(PANDOC_WRITER_OPTIONS["variables"]["scr_global_current_cb"]) or 1
    exit_status, global_current_cb = pcall(loadFileContent, scr_global_current_cb)

--print('scr_global_current_cb : ' .. scr_global_current_cb) -- DEBUGGING


    -- For first iteration of the script global_current_cb will be ""
    -- For additional iterations it will be a string 
    --      -- Convert to number
   
    if global_current_cb:len() == 0 then
        global_current_cb = 1
    -- Otherwise convert to a boolean
    elseif type(global_current_cb) == 'string' then
        global_current_cb = tonumber(global_current_cb)
    end

    file_processed = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_processed"]) or nil


--print('global_current_cb : ' .. global_current_cb) -- DEBUGGING
--print('global_current_cb : ' .. type(global_current_cb)) -- DEBUGGING


--    -- checking if global_current_cb exist (it doesnt for the first call of the script)
--    --      The file will always exists as it is created by bash, 
--    --          is just its content is going to be empty
--    if #global_current_cb == 0 then
--        global_current_cb = 1
--    end
    

--    print('global_current_cb : ' .. global_current_cb) -- DEBUGGING
--    print('global_current_cb length : ' .. #global_current_cb) -- DEBUGGING
--    --global_current_cb = tonumber(global_current_cb)


-- print('csv_path : ' .. csv_path) -- DEBUGGING
-- print('choice_3 : ' .. choice_3) -- DEBUGGING

    -- As we are calling this script for each file, and each file 
    -- has many CodeBlocks (cb)
    -- We need to keep track of which cb we are, 
    --      - globaly (in the execution of .sh)
    --      - lua_script wise (within the execution of the pandoc_filter)
    -- Counter is going to be added upon a new cb found
    --
    -- We define global_current_cb which is the global counter within the execution of .sh
    --          It has been already defined as the pseudo-argument
    --          It will have to be returned at the end of the lua-script
    --
    --  We define csv_path which will keep track of all the extensions been chosen in a .csv file for:
    --          Already defined extensions, not having to choose them anytime you parse the file
    --          If the parsing process get interrumpted in the middle
    --          If there needs to be done a modification in few code blocks
    --  We define file_cb  will be the local to the actual lua script been runned
    --      Each file may have an arbitrary no of code blocks , this will keep track of which of those
    --      file_cb will be useful to identify which cb correspond to one within a file

    file_cb = 1
    --csv_row_iterator = nil
    return doc
end 




-- The particularity of this script is that is inteded to get called 
--    for each file of the vim-dan parse
-- Meaning the extension csv can either
--      - 1) Not Exists (we have created it while assigning the variables)
--      - 2) Exists but its length be lower than all documentation cb's
--      - 3) Exists and its length is the same as all documentation cb's
--               In this case there will be no prompting to human
--      - In the 2) case , its length is going to match with the cb's accrued until the last file that it stopped doing the parse . Unless the documentation has changed (in which case a new csv has to be created)
--         For this last point, we consume the csv ourselves in a variable

local function does_need_prompting (doc)
--print('into does_need_prompting') -- DEBUGGING
--print('csv_path : ' .. csv_path) -- DEBUGGING


    -- Getting the no of entries , minus 1 that is the header
    local csv_entries = count_file_lines(csv_path) - 1

--print('csv_entries : ' .. csv_entries) -- DEBUGGING
--print('global_current_cb : ' .. global_current_cb) -- DEBUGGING


    if csv_entries > global_current_cb then
        needs_prompting = false
    end

    return doc
end

local function csv_iterator_catchup(doc)
    -- We dont waste computing power catching up an iterator that is behind
    if needs_prompting then
        return doc
    else
--print('Doing iterator catchup') -- DEBUGGING
        csv_iterator = ftcsv.parseLine(csv_path)
        for i=1, global_current_cb - 1 do
            csv_iterator()
        end
    end
end


local function check_each_cb(elem)
    local extension = ''
    local filetype = ''

    -- If the csv file is behind the new cb's prompt the user
    if needs_prompting then
        extension = prompt_user(elem)

        -- Processing the vim filetype
        local command = project_path .. "/scripts/getVimFiletype.sh " .. extension .. " 2> /dev/null"
        filetype = os.capture(command)

        save_row_to_local_list(extension, filetype)
    -- If the csv has entries regarding to the current cb, automatically grab them
    else
        local status, csv_row = csv_iterator()


        filetype = csv_row.filetype
    end

    -- Incrementing the local file_cb
    file_cb = file_cb + 1
    -- Incrementing the global_current_cb
    global_current_cb = global_current_cb + 1

    -- Saving the extension used for the buffer of choices
    table.insert(choice_list, extension)

    -- Returning the Parsed String
    return pandoc.Plain(
        {"```" .. filetype .. "\n" .. elem.text .. "\n" .. "```" }
    )
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


local function save_return_vars(doc)
    -- Usage for saving variables
    saveVariableToFile(scr_choice_1, "choice_1", choice_list[#choice_list])
    saveVariableToFile(scr_choice_2, "choice_2", choice_list[#choice_list - 1])
    saveVariableToFile(scr_choice_3, "choice_3", choice_list[#choice_list - 2])

    saveVariableToFile(scr_global_current_cb, "global_current_cb", tostring(global_current_cb))

    return doc
end

-- EOF EOF EOF FUNCTIONS EXECUTED ON THE MAIN SEQUENCE
-- -------------------------------------------------------
-- -------------------------------------------------------



return {
    { Pandoc = loading_arguments },
    { Pandoc = does_need_prompting },
    { Pandoc = csv_iterator_catchup },
    { CodeBlock = check_each_cb } ,
    { Pandoc = save_csv } ,
    { Pandoc = save_return_vars } 
}
