--- @script codeblock-default
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Pandoc Lua Filter checking each Code Block and assigning a vim filetype
-- wrapping it into a markdown codeblock
--
-- Example:
--
--    codeblock_default_filetype="javascript"
--
-- pandoc -f html -t plain ./downloaded/spain.html \
--    -V codeblock_default_filetype=${codeblock_default_filetype} \
--    -L $(realpath codeblock-default.lua)"
--
--    Will parse all CodeBlock .html elements with
--    ```javascript
--    ```

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SCRIPT_VAR_INITIALIZATION.
-- @section SCRIPT_VAR_INITIALIZATION

local DEBUG = false -- Activate the debugging mode
local codeblock_default_filetype = nil

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


-- EOF EOF EOF HELPER_FUNCTIONS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------





-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SUBROUTINE_DECLARATIONS.
-- @section SUBROUTINE_DECLARATIONS

--- Load the arguments of the filter from variables
function loading_arguments (doc)

    -- Load contents into separate variables
    codeblock_default_filetype = tostring(PANDOC_WRITER_OPTIONS["variables"]["codeblock_default_filetype"]) or nil


    return doc
end 



--- The triggering function to check each Code Block
function check_each_cb(elem)
    -- Returning the Parsed String
    return pandoc.Plain(
        {"```" .. codeblock_default_filetype .. "\n" .. elem.text .. "\n" .. "```" }
    )
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
    { CodeBlock = check_each_cb } 
}

-- EOF EOF EOF SUBROUTINE_CALLS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
