#!/bin/bash 
# @file google-devs-search
# @brief vim-dan ruleset file for documentation on adobe ai program.
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOWNLOAD_LINKS=(
https://developers.google.com/
)

## EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section ACTION_DEFINITION
# @description Ruleset for each individual stage of vim-dan

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
    cp -r ${DOCU_PATH}/../google-devs-parent/downloaded/developers.google.com/search/* ${DOCU_PATH}/downloaded/

    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------
    # Add below statments regarding to arranging_rules that are specific for this documentation

    # Example, you want to remove the blog section that has been indexed
    # rm -r ${DOCU_PATH}/downloaded/blog

    # If there is only one DOWNLOAD_LINK , (so one hostname), unnest the files
#    find ${DOCU_PATH}/downloaded -mindepth 1 -maxdepth 1 -type d -exec sh -c 'mv "$0"/* "$1"/ && rmdir "$0"' {} ${DOCU_PATH}/downloaded \;


    

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
    

    write_html_docu_multirule -f "h1" -b "div.devsite-article-body" -b "article" -cp -il -c "105"


    # DOCUMENT CLEANUP RULES
    # ---------------------------------------------------------------------------
    ## Retrieving content of the files and cleaning it
    ## Change below patterns of text to be cleaned from the main document
    ## 
    ## For example the below patterns are used for
    ##     Removing ¶
    ##     Removing <200b>
    ##
    ## Change accordingly


    sed \
        -E -e '/^(\[\] )*\[\]$/d' \
        -e 's/^\[\] //' \
        -i "${MAIN_TOUPDATE}"

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
    sed -i '12a\'$'\n''&@ g:dan_kw_question_list = "^Description" @&' "${MAIN_TOUPDATE}"
    sed -i '13a\'$'\n''&@ g:dan_kw_nontext_list = "^Parameters,^Type" @&' "${MAIN_TOUPDATE}"
    sed -i '14a\'$'\n''&@ g:dan_kw_linenr_list = "^Parameter " @&' "${MAIN_TOUPDATE}"
    sed -i '15a\'$'\n''&@ g:dan_kw_warningmsg_list = "^Returns" @&' "${MAIN_TOUPDATE}"
    sed -i '16a\'$'\n''&@ g:dan_kw_colorcolumn_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '17a\'$'\n''&@ g:dan_kw_underlined_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '18a\'$'\n''&@ g:dan_kw_preproc_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '19a\'$'\n''&@ g:dan_kw_comment_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '20a\'$'\n''&@ g:dan_kw_identifier_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '21a\'$'\n''&@ g:dan_kw_ignore_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '22a\'$'\n''&@ g:dan_kw_statement_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '23a\'$'\n''&@ g:dan_kw_cursorline_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '24a\'$'\n''&@ g:dan_kw_tabline_list = "" @&' "${MAIN_TOUPDATE}"

    # EOF EOF EOF MODELINE FOR SYNTAX SPECIFIC PATTERNS FOR KEYWORDS
    # ---------------------------------------------------------------------------
    

    # TUCKING IN THE IN-LINE LINKS AS MUCH AS POSSIBLE
    awk -f "$CURRENT_DIR"/../scripts/append-inline-links-prev.awk "${MAIN_TOUPDATE}" > /tmp/${DOCU_NAME}-tmp && mv /tmp/${DOCU_NAME}-tmp "${MAIN_TOUPDATE}"

    for ((i=1; i<=5; i++)); do
        awk -f "$CURRENT_DIR"/../scripts/pile-consecutive-inline-links.awk "${MAIN_TOUPDATE}" > /tmp/${DOCU_NAME}-tmp && mv /tmp/${DOCU_NAME}-tmp "${MAIN_TOUPDATE}"
    done

##  @todo if uncommented, in-line tags will be appended to the end of the previous line
##         i.e: accessed and manipulated to modify the appearance of the associated text frame.<I=1><I=2>
##        This would be desired but it seems to be breaking the functionality with the current configuration of ctags
##
##    awk -f "$CURRENT_DIR"/../scripts/append-inline-links-prev.awk "${MAIN_TOUPDATE}" > /tmp/${DOCU_NAME}-tmp && mv /tmp/${DOCU_NAME}-tmp "${MAIN_TOUPDATE}"
    # ---------------------------------------------------------------------------

}


## EOF EOF EOF ACTION_DEFINITION
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section SELECTING_ACTION
# @brief Not to be customised

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

## EOF EOF EOF SELECTING_ACTION 
## ----------------------------------------------------------------------------
