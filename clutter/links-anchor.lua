--- @script links-anchor
-- @author rafmartom <rafmartom@gmail.com>
-- @usage
-- Pandoc lua filter to parse the elements with identifiers assigned id=""
-- @todo
--    They will be detected and added a linkto 
--
--     Application: Starting from HTML file, you can use anchor links to address to any element that has assigned an id=""
--
--     Say we are in the following document './downloaded/jsobjref/Application.html'
--     We have
--     (...)
--     <section id="properties">
--          <h2>Properties</h2>
--     (...)
--     <a class="headerlink" href="#properties">Goto properties</a>
-- 
--      Clicking on the anchor element will take you to the Corresponding element with that id (in this case that section)
--
--  
--  The purpose of this Filter is to identify all of these id's , and create a danlinkto which will be identified by ctags
--
--  # /jsobjref/Application.html#properties #
--
--  Then upon using the other filter danlinkfrom-href , linkto's will be parsed to those linkfroms
--
--  &Application properties@/jsobjref/Application.html#properties@&
--
--  Possible limitations
--     If I dont create a new tag in ctags different to the syntax of '^# <linkto> #$' 
--     These linkto tags have to be on a newline all of them , 
--        so if found on the same line various of them will chop the lines
--
--  Filter needs to be applied to each type of element individually
--      Say you have got <section> elements with id's  also <h1><h2> ... , also <span>
--      You need to parse each individually
--
--  FINDINGS)
--    1) There may be many id-danlinkto on a single document, 
--      if we want to parse all of them 
--         1st) We will have to make this linkto , inlines (so create a new ctags label) , a new conceal system etc...
--         2nd) We will be polluting the documents with loads of concealed giverish text just to add this functionality
--            Given this it may be unpractical for readability of the document without conceal
--            In order to tackle this, we could create yet another filter that parses all of these linkto
--               And if they are not in-use by any linkfrom , just delete them
--    2) Each of this tags will create a newline just for the tag, 
--        Example what it was
--      ------------------------------------------------------------------------
--      
--      
--      Application.undo()¶
--      
--      Now is
--      ------------------------------------------------------------------------
--      
--      %$./downloaded/jsobjref/Application.html#application-translateplaceholdertext%$
--      
--      Application.undo()¶
--
--      There is no easy way to solve 2) by writting something in the filter, 
--          we need to correct this on the {MAIN}.dan document, appliying a sed filter
--
--     dan-inlinelinkfrom-corrector="sed -E ':a; N; s/\n(%\$.*?%\$)/ \1/'"    
--
--
--   inline-linkto = %$<docu_path>#<id>%$
--   inline-linkto = %$jsobjref/Application.html#jsobjref-application%$
--
--  Example
--    pandoc -f html -t plain ./downloaded/jsobjref/Application.html -L id-danlinkto.lua -V file_processed="./downloaded/jsobjref/Application.html"
--    pandoc -f html -t plain ./downloaded/jsobjref/Application.html -L id-danlinkto.lua -V file_processed="./downloaded/jsobjref/Application.html" -V objects_toparse="Span,Div" | sed -E ':a; N; s/\n(%\$.*?%\$)/ \1/'




-- HELPER FUNCTIONS
-- -------------------------------------------------------


-- EOF EOF EOF HELPER FUNCTIONS
-- -------------------------------------------------------



-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SCRIPT_VAR_INITIALIZATION.
-- @section SCRIPT_VAR_INITIALIZATION

local exit_status = nil
local file_processed = nil
local objects = {}

-- EOF EOF EOF SCRIPT_VAR_INITIALIZATION
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SUBROUTINE_DECLARATIONS.
-- @section SUBROUTINE_DECLARATIONS


function loading_arguments (doc)
    -- Load contents into separate variables
    file_processed = tostring(PANDOC_WRITER_OPTIONS["variables"]["file_processed"]) or nil
    

    return doc
end


local function parse_ids(elem)
    local id = elem.identifier

    if id == '' or id == nil then
        return elem
    end

   -- Generate the ID string
    local inline_linkto = pandoc.Str('%$' .. file_processed .. '#' .. id .. '%$')

    -- Concatenate the original content with the ID string
    table.insert(elem.content, inline_linkto)

    return elem
--    print('Id : ' .. id) -- DEBUGGING
end


-- EOF EOF EOF SUBROUTINE_DECLARATIONS 
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------




-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

--- SUBROUTINE_CALLS.
-- Define the flow of execution of the filter, calling the previously defined subroutines.
-- @section SUBROUTINE_CALLS


local filters = {
    { Pandoc = loading_arguments },
}



-- Construct filter table dynamically
-- Adding as many objects as user inputon -V objects_toparse="Span,Div,Para" 
objects_toparse = tostring(PANDOC_WRITER_OPTIONS["variables"]["objects_toparse"]) or nil
for obj in string.gmatch(objects_toparse, '([^,]+)') do
    table.insert(objects, obj)
end


-- Define valid elements as keys in a lookup table
local valid_elements = {
    CodeBlock = true,
    Div = true,
    Figure = true,  -- No images on vim-dan
    Header = true,
    Table = true,
    Code = true,
    Image = true,   
    Link = true,
    Span = true,
    Cell = true,
    TableFoot = true,
    TableHead = true,

--    Para = true,
--    BlockQuote = true,
--    BulletList = true,
--    OrderedList = true,
    -- Add more valid Pandoc elements if needed
}


---- Iterate over objects and insert into filters
for _, object in ipairs(objects) do

    -- Ensure object is a valid Pandoc element type
    if valid_elements[object] then
        filters[#filters + 1] = { [object] = parse_ids }
    end
end


return filters

-- EOF EOF EOF SUBROUTINE_CALLS
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
