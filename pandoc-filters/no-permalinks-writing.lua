--- @script no-permalinks-writing
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Pandoc lua filter for vim-dan which filters down the permalinks on the writing stage
--     Many website include anchors strings that users can select such as ¶, #
--     These are made so the user can just copy link to there 
--
--   <section id="properties">
--   <h2>Properties<a class="headerlink" href="#properties" title="Permalink to this heading">¶</a></h2>

--     
--     When transforming this to vim-dan syntax this element does not have any utility
--     In regards of the link target we already have the target element <section id="properties">
--     And if parsing a link source will be cluttering the document
--
--     This filter aims to provide some logic to filter these elements down, where there is no standarized construct 
--     for these links, we can follow some patterns, and update the filter for new cases.
--
-- Example:
--  pandoc -f html -t plain \
--  -L $(realpath ${CURRENT_DIR}/../pandoc-filters/no-permalinks-writing.lua)" \
--  /home/fakuve/downloads/vim-dan/adobe-ai/downloaded/jsobjref/Application.html 
--





-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- IMPORT_DEPENDENCIES.
-- @section IMPORT_DEPENDENCIES


-- EOF EOF EOF IMPORT_DEPENDENCIES 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------




-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SCRIPT_VAR_INITIALIZATION.
-- @section SCRIPT_VAR_INITIALIZATION

local DEBUG = false -- Activate the debugging mode


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


--- Iterate on each Link Object, filtering down the ones matching the expression
function filtering_down_permalink(elem)
    if elem.title:match('Permalink') then
        return {}
    else
        return elem
    end
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
    { Link = filtering_down_permalink }
}

-- EOF EOF EOF SUBROUTINE_CALLS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
