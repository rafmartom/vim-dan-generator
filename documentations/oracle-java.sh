#!/bin/bash 
# @file oracle-java
# @brief vim-dan ruleset file for documentation on oracle-java
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOWNLOAD_LINKS=(
https://docs.oracle.com/en/java/index.html
)

## EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section ACTION_DEFINITION
# @description Ruleset for each individual stage of vim-dan

spidering_rules(){

    echo "Not Spidering in this docu, proceed with indexing"
#    ## Iterate through each link of the documentation
#    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
#        standard_spider -l ${DOWNLOAD_LINK}
#    done

}


filtering_rules() {

    echo "Not Filtering in this docu, proceed with indexing"
#    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
#        ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')
#        RAW_INDEX_LINKS_PATH="$CURRENT_DIR/../index-links/${ntfs_filename}.csv.bz2"
#        INDEX_LINKS_PATH=$(realpath -m "${RAW_INDEX_LINKS_PATH}")  # Normalize path
#
#        LOCAL_CSV_PATH="${DOCU_PATH}/${ntfs_filename}.csv"
#
#        ## Check if a index-links file exists
#        if [ ! -f "${INDEX_LINKS_PATH}" ]; then
#            echo "Error: Index links file not found: ${INDEX_LINKS_PATH}" >&2
#            exit 1
#        fi
#
#        ## Ensure output directory exists
#        mkdir -p "$(dirname "${LOCAL_CSV_PATH}")"
#
#        ## Pulling and extracting repo file to local path
#        bunzip2 -kc "${INDEX_LINKS_PATH}" > "${LOCAL_CSV_PATH}"
#
#        ## WRITE BELOW YOUR INCLUSION RULES
#        # if more than one rule needs to use temporary files
#        #incl_1=$(mktemp); sed -n '\|nodejs[.]org/docs/latest/|p' "${LOCAL_CSV_PATH}" > "$incl_1"
#        #incl_2=$(mktemp); sed -n '\|nodejs[.]org/en/guides/|p' "${LOCAL_CSV_PATH}" > "$incl_2"
#        #incl_3=$(mktemp); sed -n '\|nodejs[.]org/en/learn/|p' "${LOCAL_CSV_PATH}" > "$incl_3"
#
#        cat "$incl_1" "$incl_2" "$incl_3" > "${LOCAL_CSV_PATH}"
#        rm "$incl_1" "$incl_2" "$incl_3"
#
#        ## WRITE BELOW YOUR EXCLUSION RULES
#        #sed -i '\|developer[.]mozilla[.]org/es|d' ${LOCAL_CSV_PATH}
#    done

}

indexing_rules(){
    echo "Download from https://www.oracle.com/uk/java/technologies/javase-jdk8-doc-downloads.html"
    echo 'mkdir -p $VIMDAN_DIR/oracle-java/downloaded'
    echo 'unzip jdk-8u451-docs-all.zip -d $VIMDAN_DIR/oracle-java/downloaded'
    echo 'For instance'
    echo 'mkdir -p $HOME/downloads/vim-dan/oracle-java/downloaded'
    echo 'unzip jdk-8u451-docs-all.zip -d $HOME/downloads/vim-dan/oracle-java/downloaded/'

#    start_row="$1"
#
#    ## Iterate through each link of the documentation
#    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
#       download_fromlist_waitretry ${DOWNLOAD_LINK} 0.05 2 ${start_row}
#    done

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

    # If there is only one DOWNLOAD_LINK , (so one hostname), unnest the files
    find ${DOCU_PATH}/downloaded -mindepth 1 -maxdepth 1 -type d -exec sh -c 'mv "$0"/* "$1"/ && rmdir "$0"' {} ${DOCU_PATH}/downloaded \;

    # Delete all the files that are not .html
    find ${DOCU_PATH}/downloaded ! -name "*.html" -type f -exec rm {} \;

    # Removing empty directories
    find "${DOCU_PATH}/downloaded" -type d -empty -delete

    # EOF EOF EOF DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------


    ## Files cleanup

    ## Clean up the duplicate files
    # Keeping the least nested one
    jdupes -r -N -d ${DOCU_PATH}/downloaded/


    ## Modifying documents
}


parsing_rules(){

    parse_html_docu_multirule -f "h1" -f "h2" -b ".contentContainer" 

}

writting_rules(){

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

#    sed \
#        -e '/^Page Contents$/d' \
#        -e 's/¶//g' \
#        -e 's/[[:space:]]\+¶//g' \
#        -e '/^\[\] \[\]$/d' \
#        -e '/^\[\]$/d' \
#        -i "${MAIN_TOUPDATE}"

    # EOF EOF EOF DOCUMENT CLEANUP RULES
    # ---------------------------------------------------------------------------

    ## Change below the html tags to be parsed -f for titles , -b for body
    # Example: 
    #    We parse the Titles of the Topics by using 'h1'
    #    We parse the Content of the Pages by using 'article'
    
    #    write_html_docu_multirule -f "h1" -b "article" -cd "java"
    #
    #  Other Example:
    #    You may use various tags, the firstone to be found will be used
    #    In the documentation downloaded some pages are different than others
    #        The Content of the Pages sometimes is under "div.guide-content" sometimes under "body"
    #
    #    write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body" -cd "java"
    #
    

    write_html_docu_multirule -f "h1" -f "h2" -b ".contentContainer" -cd "java" -il -c "105"


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
    


}


## EOF EOF EOF ACTION_DEFINITION
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section SELECTING_ACTION
# @brief Not to be customised

while getopts ":sfx:apwh" opt; do
    case ${opt} in
        s) spidering_rules ;;
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
