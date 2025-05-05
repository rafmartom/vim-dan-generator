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
https://wiki.wireshark.org
https://www.wireshark.org/docs/
)
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS

spidering_rules(){

    ## Iterate through each link of the documentation
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        standard_spider -l ${DOWNLOAD_LINK}
    done

}

indexing_rules(){

    ## Iterate through each link of the documentation
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        download_fromlist -l ${DOWNLOAD_LINK}
    done

}

arranging_rules(){

    ## Making a backup of the index, if it doesnt exist
    if [[ ! -d "${DOCU_PATH}/downloaded-bk" || ! "$(ls -A "${DOCU_PATH}/downloaded-bk" 2>/dev/null)" ]]; then
        cp -r ${DOCU_PATH}/downloaded ${DOCU_PATH}/downloaded-bk/
    fi

    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------
    # Add below statments regarding to arranging_rules that are specific for this documentation

    # Example, you want to remove the blog section that has been indexed
    # rm -r ${DOCU_PATH}/downloaded/blog

    ## Remove all files from that folder
    find ${DOCU_PATH}/downloaded/www.wireshark.org/docs/ -mindepth 1 -maxdepth 1 -type f -exec rm {} \;    

    ## Remove the rest of subdirs
    find ${DOCU_PATH}/downloaded/www.wireshark.org/ -mindepth 1 -maxdepth 1 -type d -not  -name docs  -exec rm -r {} \;    

    ## Remove all directories except those exceptions
    find ${DOCU_PATH}/downloaded/www.wireshark.org/docs/ -mindepth 1 -maxdepth 1 -type d \
        -not \( -name dfref -o -name man-pages -o -name wsdg_html_chunked -o -name wsug_html_chunked \) \
        -exec rm -r {} \;    


    find ${DOCU_PATH}/downloaded/www.wireshark.org/docs/ -mindepth 1 -maxdepth 1 -type d \

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
    write_html_docu_multirule \
        -f "div.navheader tbody tr:first-child" \
        -f "div#header h1" \
        -f "div.main-container section section h2" \
        -f "header h1" \
        -f "h1" \
        -b "div.section" \
        -b "body.manpage" \
        -b "div.main-container section section" \
        -b "main" \
        -cp -lp -c "105"


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
        -e '/^Discussion$/d' \
        -e 's/[[:space:]]\+¶//g' \
        -e "s/$(echo -ne '\u200b')//g" \
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
    sed -i '12a\'$'\n''&@ g:dan_kw_question_list = "^ Example traffic,^ Example capture file,^ External links" @&' "${MAIN_TOUPDATE}"
    sed -i '13a\'$'\n''&@ g:dan_kw_nontext_list = "^ Protocol Functions" @&' "${MAIN_TOUPDATE}"
    sed -i '14a\'$'\n''&@ g:dan_kw_linenr_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '15a\'$'\n''&@ g:dan_kw_warningmsg_list = "^ Protocol dependencies" @&' "${MAIN_TOUPDATE}"
    sed -i '16a\'$'\n''&@ g:dan_kw_colorcolumn_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '17a\'$'\n''&@ g:dan_kw_underlined_list = "^ Returns" @&' "${MAIN_TOUPDATE}"
    sed -i '18a\'$'\n''&@ g:dan_kw_preproc_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '19a\'$'\n''&@ g:dan_kw_comment_list = "^ Capture Filter" @&' "${MAIN_TOUPDATE}"
    sed -i '20a\'$'\n''&@ g:dan_kw_identifier_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '21a\'$'\n''&@ g:dan_kw_ignore_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '22a\'$'\n''&@ g:dan_kw_statement_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '23a\'$'\n''&@ g:dan_kw_cursorline_list = "^ History,^ Arguments" @&' "${MAIN_TOUPDATE}"
    sed -i '24a\'$'\n''&@ g:dan_kw_tabline_list = "^ Display Filter,^ Prefrence Settings" @&' "${MAIN_TOUPDATE}"

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
