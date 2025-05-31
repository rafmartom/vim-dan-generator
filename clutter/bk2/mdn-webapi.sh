#!/bin/bash

# DECLARING VARIABLES AND PROCESSING ARGS
# -------------------------------------
# (do not touch)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOCU_PATH="$1"
shift
DOCU_NAME=$(basename ${0} '.sh')
MAIN_TOUPDATE="${DOCU_PATH}/${DOCU_NAME}-toupdate.dan"
DOWNLOAD_LINKS=(
https://developer.mozilla.org/en-US/docs/
)
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS

spidering_rules(){

    echo "This is a child documentation"
    echo "No spidering will take place in here"

}

indexing_rules(){

    echo "This is a child documentation"
    echo "No Indexing will take place in here"

}

arranging_rules(){

    echo "This is a child documentation"
    echo "Arranging means pulling its files from its parent documentation first"


    mkdir -p ${DOCU_PATH}/downloaded
    mkdir -p ${DOCU_PATH}/downloaded/en-US/docs/Web/API/
    cp -r ${DOCU_PATH}/../mdn-parent/downloaded/developer.mozilla.org/en-US/docs/Web/API/* ${DOCU_PATH}/downloaded/en-US/docs/Web/API/

    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------
    # Add below statments regarding to arranging_rules that are specific for this documentation

    # Example, you want to remove the blog section that has been indexed
    # rm -r ${DOCU_PATH}/downloaded/blog

    

    # EOF EOF EOF DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------



    ## Files cleanup

    ## Clean up the duplicate files
    # Keeping the least nested one
    jdupes -r -N -d ${DOCU_PATH}/downloaded/


    ## Modifying documents
}


parsing_rules(){

    write_header
    ## Change below the html tags to be parsed -f for titles , -b for body
    # Example: 
    #    We parse the Titles of the Topics by using 'h1'
    #    We parse the Content of the Pages by using 'article'
    
    #    write_html_docu_multirule -f "h1" -b "article" -cp
    #
    #  Other Example:
    #    You may use various tags, the firstone to be found will be used
    #    In the documentation downloaded some pages are different than others
    #        The Content of the Pages sometimes is under "div.guide-content" sometimes under "body"
    #
    #    write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body" -cp
    #

    write_html_docu_multirule -f "article h1" -b "#content" -lp -c "105"


    # DOCUMENT CLEANUP RULES
    # ---------------------------------------------------------------------------
    ## Retrieving content of the files and cleaning it
    ## Change below patterns of text to be cleaned from the main document
    ## 

## Parsing codeblocks, 
##    upon finding a line that is ^js$ , will add ```javascript
##    The after that ocurrence look for the next uninteded text found , place a ``` line before it

cmd=$(cat << 'EOF'
execute "g/^js$/s/.*/```javascript/ | /^\\_s*\\n\\S/-put='```'"
EOF
)
nvim --headless -c "$cmd" -c "wq" "${MAIN_TOUPDATE}"

cmd=$(cat << 'EOF'
execute "g/^html$/s/.*/```html/ | /^\\_s*\\n\\S/-put='```'"
EOF
)
nvim --headless -c "$cmd" -c "wq" "${MAIN_TOUPDATE}"

cmd=$(cat << 'EOF'
execute "g/^html$/s/.*/```conf/ | /^\\_s*\\n\\S/-put='```'"
EOF
)
nvim --headless -c "$cmd" -c "wq" "${MAIN_TOUPDATE}"


cmd=$(cat << 'EOF'
execute "g/^css$/s/.*/```css/ | /^\\_s*\\n\\S/-put='```'"
EOF
)
nvim --headless -c "$cmd" -c "wq" "${MAIN_TOUPDATE}"

cmd=$(cat << 'EOF'
execute "g/^xml$/s/.*/```xml/ | /^\\_s*\\n\\S/-put='```'"
EOF
)
nvim --headless -c "$cmd" -c "wq" "${MAIN_TOUPDATE}"

cmd=$(cat << 'EOF'
execute "g/^json$/s/.*/```json/ | /^\\_s*\\n\\S/-put='```'"
EOF
)
nvim --headless -c "$cmd" -c "wq" "${MAIN_TOUPDATE}"



    sed -e '/^\[\]$/d' \
        -e "/^-    Previous$/d" \
        -e "/^-    Next$/d" \
        -e "/^Help improve MDN$/d" \
        -e "/^Was this page helpful to you?/d" \
        -e "/^Yes$/d" \
        -e "/^No$/d" \
        -e "/^Learn how to contribute \\.$/d" \
        -e "/^This page was last modified on Dec 19, 2024 by MDN contributors \\.$/d" \
        -e "/^View this page on GitHub • Report a problem with this content$/d" \
        -i "${MAIN_TOUPDATE}"

    ## Delete 6 consecutives empty lines
    sed '/^\s*$/N; /^\s*$/N; /^\s*$/N; /^\s*$/N; /^\s*$/N; /^\s*$/N; /^\(\s*\n\)\{6\}$/d' -i "${MAIN_TOUPDATE}"

    # EOF EOF EOF DOCUMENT CLEANUP RULES
    # ---------------------------------------------------------------------------

    write_ext_modeline


    # MODELINE FOR SYNTAX SPECIFIC PATTERNS FOR KEYWORDS
    # ---------------------------------------------------------------------------
    # Change below the keywords you want to be highlighted
    #    The syntax highlighting will be using Default groups , such as Question , NonText etc...
    #        Introduce the patterns that you want to be highlighted with the same style than those groups
    #
    #    For instance to highlight the Pattern "^Reference" and "^Example:" which are repeated throughout the documentation 
    #    In this example I want to highlight it with Green Letter, normal foreground. 
    #         I will be using then the Question group
    #         So Using coma separated
    #           
    #    sed -i '11a\'$'\n''&@ g:dan_kw_question_list = "^Example:,^Reference"" @&' "${MAIN_TOUPDATE}"
    #    Note : there are Character limitations ",= and others wont be working
    
    sed -i '10a\'$'\n''&@ The following lines are used by vim-dan, do not modify them! @&' "${MAIN_TOUPDATE}"
    sed -i '12a\'$'\n''&@ g:dan_kw_question_list = "^See also,^Examples,^Specifications,^Syntax,^Formal syntax,^Description,Optional" @&' "${MAIN_TOUPDATE}"
    sed -i '13a\'$'\n''&@ g:dan_kw_nontext_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '14a\'$'\n''&@ g:dan_kw_linenr_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '15a\'$'\n''&@ g:dan_kw_warningmsg_list = "^Exceptions,^Constructor,Deprecated" @&' "${MAIN_TOUPDATE}"
    sed -i '16a\'$'\n''&@ g:dan_kw_colorcolumn_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '17a\'$'\n''&@ g:dan_kw_underlined_list = "^Usage notes,^Directives,^Technical summary,^Return value,^Value,inherits" @&' "${MAIN_TOUPDATE}"
    sed -i '18a\'$'\n''&@ g:dan_kw_preproc_list = "^Events" @&' "${MAIN_TOUPDATE}"
    sed -i '19a\'$'\n''&@ g:dan_kw_comment_list = "^Parameters,Experimental,Non-standard" @&' "${MAIN_TOUPDATE}"
    sed -i '20a\'$'\n''&@ g:dan_kw_identifier_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '21a\'$'\n''&@ g:dan_kw_ignore_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '22a\'$'\n''&@ g:dan_kw_statement_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '23a\'$'\n''&@ g:dan_kw_cursorline_list = "^Attributes,^Instance properties,^Instance methods" @&' "${MAIN_TOUPDATE}"
    sed -i '24a\'$'\n''&@ g:dan_kw_tabline_list = "^Values,^Interfaces" @&' "${MAIN_TOUPDATE}"

    # EOF EOF EOF MODELINE FOR SYNTAX SPECIFIC PATTERNS FOR KEYWORDS
    # ---------------------------------------------------------------------------
}

## PARSING ARGUMENTS
## ------------------------------------
# (do not touch)
while getopts ":siap" opt; do
    case ${opt} in
        s)
            spidering_rules
            ;;
        i)
            indexing_rules
            ;;
        a)
            arranging_rules
            ;;
        p)
            parsing_rules
            ;;
        h | *)
            echo "Usage: $0 [-s] [-i] [-a] [-p] [-h] "
            echo "Options:"
            echo "  -s  Spidering"
            echo "  -i  Indexing"
            echo "  -a  Arranging"
            echo "  -p  Parsing"
            echo "  -h  Help"
            exit 0
            ;;
    esac
done
## EOF EOF EOF PARSING ARGUMENTS
## ------------------------------------
