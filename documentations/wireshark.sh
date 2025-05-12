#!/bin/bash 
# @file wireshark
# @brief vim-dan ruleset file for documentation on adobe ai program.
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOWNLOAD_LINKS=(
https://wiki.wireshark.org
https://www.wireshark.org/docs/
)

## EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section ACTION_DEFINITION
# @description Ruleset for each individual stage of vim-dan

spidering_rules(){

    ## Iterate through each link of the documentation
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        standard_spider -l ${DOWNLOAD_LINK}
    done

}


filtering_rules() {

    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')
        RAW_INDEX_LINKS_PATH="$CURRENT_DIR/../index-links/${ntfs_filename}.csv.bz2"
        INDEX_LINKS_PATH=$(realpath -m "${RAW_INDEX_LINKS_PATH}")  # Normalize path

        LOCAL_CSV_PATH="${DOCU_PATH}/${ntfs_filename}.csv"

        ## Check if a index-links file exists
        if [ ! -f "${INDEX_LINKS_PATH}" ]; then
            echo "Error: Index links file not found: ${INDEX_LINKS_PATH}" >&2
            exit 1
        fi

        ## Pulling and extracting repo file to local path
        bunzip2 -kc "${INDEX_LINKS_PATH}" > "${LOCAL_CSV_PATH}"

        ## WRITE BELOW YOUR INCLUSION RULES
        #sed -ni '\|developer[.]mozilla[.]org|p' ${LOCAL_CSV_PATH}

        ## WRITE BELOW YOUR EXCLUSION RULES
        #sed -i '\|developer[.]mozilla[.]org/es|d' ${LOCAL_CSV_PATH}
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

    parse_html_docu_multirule \
        -f "div.navheader tbody tr:first-child" \
        -f "div#header h1" \
        -f "div.main-container section section h2" \
        -f "header h1" \
        -f "h1" \
        -b "div.section" \
        -b "body.manpage" \
        -b "div.main-container section section" \
        -b "main"

}

writting_rules(){

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
        -cp -il -c "105"


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

while getopts ":sfx:apwh" opt; do
    case ${opt} in
        s) spiderind_rules ;;
        f) filtering_rules ;;
        x) 
            if [[ -n "$OPTARG" && "$OPTARG" =~ ^[0-9]+$ ]]; then
                indexing_rules "$OPTARG"
            else
                echo "Error: -x requires a numeric row number" >&2
                exit 1
            fi
            ;;
        a) arranging_rules ;;
        p) parsing_rules ;;
        w) writting_rules ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

## EOF EOF EOF SELECTING_ACTION 
## ----------------------------------------------------------------------------
