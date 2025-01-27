vim9script
# Author: freddieventura
# File related to vim-dan linking rules
# so in files with the extension .${framework_name}dan
#      Upon locating in certain navigation areas
#      You can press Ctrl + ] and move around topics/signatures/etc
# Check https://github.com/freddieventura/vim-dan for more info

# Setting iskeyword to
set iskeyword=!-~,^*,^\|,^\",192-255

# New linkto functionality
# In vim-dan documents there are a bunch of
#   - & @link_from@ link_string &
#  That refer to
#   - # link_to # 
#  (been link_from and link_to the same)
#  You just need to locate the cursor on top of the line
#   with the linkFrom and press Ctrl + ]
#
#   The syntax is conealing @link_from@ from the user so it can only see
#   link_string
#   Basically link_from is now a unique identifier

command! GotoLinkto call GotoLinktoFn()
command! IsLineLinkto call IsLineLinktoFn()
nnoremap <expr> <C-]>  IsLineLinktoFn() ? ':GotoLinkto<CR>' :  '<C-]>'

def IsLineLinktoFn(): number
    # if there is a $linkto& in the current line
    if match(getline('.'), '&.*&') != -1
        return 1
    else
    endif
    return 0
enddef

def GotoLinktoFn(): void
    var myString = getline('.')

    # If there is a keyword enclosed in between &keyword& goto there
    if match(myString, '@.*@') != -1
        execute "tag " .. matchstr(myString, '@\@<=.*@\@=')
    else
    endif
enddef


# VIM-DAN FUNCTIONALITIES
# ----------------------------------
nnoremap <C-p> :normal $a (X)<Esc>

noremap <F4> :ToggleXConceal<CR>

noremap <F5> :call dan#Refreshloclist()<CR>:call dan#UpdateTags()<CR>:redraw!<CR>:silent! tag<CR>

command! ToggleXConceal call dan#ToggleXConceal(g:xConceal)


# Giving a linenumber parse the variable and its content
#  ie : &@ g:dan_lang_list = "javascriptreat,cpp" @&
#  ie : &@ g:dan_other_var = "something" @&
# -----------------------------------------------
export def ParseDanModeline(lineNumber: number): void

    ## First, parse the content of the line into a list,
    ##   Its first member is the varName
    ##      keyValueList[0] = varName
    ##   Its second member is the list of values
    ##      keyValueList[1] = varContent
    var keyValueList = ParseDanModelineContent(lineNumber)


    ## Check if the varName already exists
    if (has_key(g:dynamicLookupDict, keyValueList[0]))
        ## If so append its varContent to the existing one
        ## (check not to overwrite existing keys)
        var updatedContent = g:dynamicLookupDict[keyValueList[0]] + keyValueList[1]

        ## Assign the existing variable to the concatenation of the varContent

            # Call the function to get the string representation of the list
             var listLiteral = ListToListLiteral(keyValueList[1])
        var cmd = keyValueList[0] .. ' = ' .. listLiteral
        execute(cmd)

        ## Update the g:dynamicLookupDict
        g:dynamicLookupDict[keyValueList[0]] = DanUniq(updatedContent)


    ## If varName doesnt already exists
    else
        ##append this keyValueList to the g:dynamicLookupDict
        g:dynamicLookupDict[keyValueList[0]] = keyValueList[1]


        ## And Declare the Variable from scratch
        var listLiteral = ListToListLiteral(keyValueList[1])
        var cmd = keyValueList[0] .. ' = ' .. listLiteral
        execute(cmd)
    endif

    ## Adding the FileName to the danFileSourced list
    var currentFileName = expand('%')
    g:danFilesSourced += [currentFileName]
enddef
# -----------------------------------------------


export def ParseDanModelineContent(lineNumber: number): list<any>
# -----------------------------------------------
    var lineContent = getline(lineNumber) 

    # Parsing the modeline variable name and value
    # Trimming the ends
    lineContent = substitute(lineContent, '^&@ ', '', '') 
    lineContent = substitute(lineContent, ' @&$', '', '') 

    var varName = matchstr(lineContent, '.*\( =\)\@=')

    # Substracting that match to get the value
    lineContent = substitute(lineContent, '.*\( =\)\@=', '', '') 

    # The varValueList is a list of values first get the string
    lineContent = matchstr(lineContent, '\"\@<=.*\"\@=')
    
    var varValueList = split(lineContent, ",")

    # See if it is a list or just a single value
    var outputList = [ varName, varValueList]
    return outputList
enddef
# -----------------------------------------------


# Define the function to convert a list to a string list literal
# -----------------------------------------------
export def ListToListLiteral(inputList: list<any>): string
    var listString = '['

    # Loop through each item in the list and build the string representation
    for item in inputList
        listString = listString .. "'" .. item .. "', "
    endfor

    # Remove the trailing comma and space
    if len(listString) > 1
        listString = listString[0 : len(listString) - 2]
    endif

    # Close the list with a closing bracket
    listString = listString .. ']'

    return listString
enddef
# -----------------------------------------------


export def DanUniq(inputList: list<any>): list<any>
    # Create a dictionary to track unique values
    var uniqueDict = {}

    # Populate the dictionary with the list items as keys to ensure uniqueness
    for item in inputList
        uniqueDict[item] = 1
    endfor

    # Extract unique items from the dictionary as a list
    var uniqueList = keys(uniqueDict)

    # Optionally sort if needed
    sort(uniqueList)

    return uniqueList
enddef



autocmd BufEnter *.dan {
    var currentFileName = expand('%')

    # Check if the current file is already in the list
    if index(g:danFilesSourced, currentFileName) == -1
        call ParseDanModeline(11)
        call ParseDanModeline(12)
        call ParseDanModeline(13)
        call ParseDanModeline(14)
        call ParseDanModeline(15)
        call ParseDanModeline(16)
        call ParseDanModeline(17)
        call ParseDanModeline(18)
        call ParseDanModeline(19)
        call ParseDanModeline(20)
        call ParseDanModeline(21)
        call ParseDanModeline(22)
        call ParseDanModeline(23)
        call ParseDanModeline(24)
        source /home/fakuve/dotfiles/common/.vim/syntax/dan.vim 
    endif
}


# ----------------------------------
#eof eof eof eof eof VIM-DAN FUNCTIONALITIES

