vim9script
# Author: freddieventura
# File related to vim-dan linking rules
# so in files with the extension .dan
#      Upon locating in certain navigation areas
#      You can press Ctrl + ] and move around topics/signatures/etc
# Check https://github.com/rafmartom/vim-dan for more info

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
command! IsLineLinkfrom call IsLineLinkfromFn()
nnoremap <expr> <C-]>  IsLineLinkfromFn() ? ':GotoLinkto<CR>' :  '<C-]>'



def IsLineLinkfromFn(): number
    # if there is a $linkfrom& in the current line
    if match(getline('.'), '&.*&') != -1
        return 1
    else
    endif
    return 0
enddef


def GotoLinktoFn(): void
## Trigger the custom Dan GotoLinkto functionality
##    - If in the current line there is only one DanTagMath ,
##         Goto that Linkto, regardless of cursor position
##    - If in the current line there is more than one DanTagMath
##         Goto the Linkto corresponding to the current cursor position

    var myString = getline('.')
    var danTagMatchPos = GetDanTagMatchPos(myString)
    var danLinkfromMatchPos = GetDanLinkfromMatchPos(myString)


    if len(danTagMatchPos) == 1
        if match(myString, '@.*@') != -1
            execute "tag " .. matchstr(myString, '@\@<=.*@\@=')
            return
        endif
    else
        var mouse_position = col('.') - 1

    # Iterate through both lists simultaneously
        for index in range(len(danTagMatchPos))
            var danTagMatch = danTagMatchPos[index]
            var danLinkfromMatch = danLinkfromMatchPos[index]

            if ( danLinkfromMatch[1] < mouse_position && danLinkfromMatch[2] > mouse_position )
                execute "tag " .. matchstr(danTagMatch[0], '@\@<=.*@\@=')
            endif
        endfor
    endif

enddef


def GetDanTagMatchPos(inputString: string): list<list<any>>
## Parse a bi-dimensional-list of matches @.\{-}@ its start and end position of the match
##     And its indexStart (index where the match start)
##     Ex . var myString = "nothing@Patxie@again nothing @peps@"
##     echo GetDanTagMatchPos(myString) ## [['Patxie', 8, 14],['peps', 31, 35]] 


    var danTagMatchPos: list<list<any>> = []
    var current_char = 0

    while 1
        var newMember: list<any> = []
        var match_result = matchstr(inputString, '@.\{-}@', current_char)
        current_char = match(inputString, '@.\{-}@', current_char)
        if !empty(match_result)
            add(newMember, match_result)
            add(newMember, current_char + 1)
            current_char = matchend(inputString, '@.\{-}@', current_char)
            add(newMember, current_char - 1)
            add(danTagMatchPos, newMember)
        else
            break
        endif
    endwhile


    return danTagMatchPos
enddef


def GetDanLinkfromMatchPos(inputString: string): list<list<any>>
## Like previousone but with Linkfrom positions so
##     Ex . var myString = "nothing &yepe@Patxie@& again &lopo @peps@& "
##     echo GetDanLinkfromMatchPos(myString) ## [[ 'yepe@Patxie@', 8, 21],['lopo @peps@', 29, 41]] 
    var datLinkfromMatchPos: list<list<any>> = []
    var current_char = 0

    while 1
        var newMember: list<any> = []
        var match_result = matchstr(inputString, '&.\{-}&', current_char)
        current_char = match(inputString, '&.\{-}&', current_char)
        if !empty(match_result)
            add(newMember, match_result)
            add(newMember, current_char + 1)
            current_char = matchend(inputString, '&.\{-}&', current_char)
            add(newMember, current_char - 1)
            add(datLinkfromMatchPos, newMember)
        else
            break
        endif
    endwhile


    return datLinkfromMatchPos
enddef



# VIM-DAN FUNCTIONALITIES
# ----------------------------------
nnoremap <C-p> :normal $a (X)<Esc>

noremap <F4> :ToggleXConceal<CR>

noremap <F5> :call dan#Refreshloclist()<CR>:call dan#UpdateTags()<CR>:redraw!<CR>:silent! tag<CR>

command! ToggleXConceal call dan#ToggleXConceal(g:xConceal)

set nofoldenable
set nomodeline

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
        call ParseDanModeline(25)
        source /home/fakuve/dotfiles/common/.vim/syntax/dan.vim 
    endif
}


# ----------------------------------
#eof eof eof eof eof VIM-DAN FUNCTIONALITIES

