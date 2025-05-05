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
https://reactnative.dev/
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

    # If there is only one DOWNLOAD_LINK , (so one hostname), unnest the files
    find ${DOCU_PATH}/downloaded -mindepth 1 -maxdepth 1 -type d -exec sh -c 'mv "$0"/* "$1"/ && rmdir "$0"' {} ${DOCU_PATH}/downloaded \;


    ## Removing first level files 
    find "${DOCU_PATH}/downloaded/" -maxdepth 1 -type f -delete

    ## Removing non-interest files

    rm -r ${DOCU_PATH}/downloaded/blog
    rm -r ${DOCU_PATH}/downloaded/community
    rm -r "${DOCU_PATH}/downloaded/docs/0.70"
    rm -r "${DOCU_PATH}/downloaded/docs/0.71"
    rm -r "${DOCU_PATH}/downloaded/docs/0.72"
    rm -r "${DOCU_PATH}/downloaded/docs/0.73"
    rm -r "${DOCU_PATH}/downloaded/docs/0.74"
    rm -r "${DOCU_PATH}/downloaded/docs/0.75"
    rm -r ${DOCU_PATH}/downloaded/docs/assets
    rm -r "${DOCU_PATH}/downloaded/docs/next"

# EOF EOF EOF DOCUMENTATION SPECIFIC RULES
# ---------------------------------------------------------------------------

    ## Cleaning up documents

    ## Clean up the duplicates
    # Keeping the least nested one
    jdupes -r -N -d ${DOCU_PATH}/downloaded/


    ## Modifying documents
}


parsing_rules(){

    write_header
    write_html_docu_multirule -f "h1" -b "article" -cp -L "$(realpath ${CURRENT_DIR}/../pandoc-filters/react-native.lua)" -lp -c "105"


    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------

    ## Retrieving content of the files and cleaning it

    sed \
        -e '/^Previous$/d' \
        -e '/^Next$/d' \
        -E -e '/^(\[\] )*\[\]$/d' \
        -E -e '/^(\[\])*\[\]$/d' \
        -e "s/$(echo -ne '\u200b')//g" \
        -e 's/^\[\] //' \
        -i "${MAIN_TOUPDATE}"

    # EOF EOF EOF DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------

    write_ext_modeline

    # MODELINE FOR SYNTAX SPECIFIC PATTERNS FOR KEYWORDS
    # ---------------------------------------------------------------------------
    # Change below the keywords you want to be highlighted
    
    sed -i '10a\'$'\n''&@ The following lines are used by vim-dan, do not modify them! @&' "${MAIN_TOUPDATE}"
    sed -i '12a\'$'\n''&@ g:dan_kw_question_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '13a\'$'\n''&@ g:dan_kw_nontext_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '14a\'$'\n''&@ g:dan_kw_linenr_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '15a\'$'\n''&@ g:dan_kw_warningmsg_list = "" @&' "${MAIN_TOUPDATE}"
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
