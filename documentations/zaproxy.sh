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
https://www.zaproxy.org/docs/
)
#DOWNLOAD_LINK=""
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
    wget \
    `##tBasic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
      -o ./wget.log \
    `## Download Options` \
      --timestamping \
    `## Directory Options` \
      --directory-prefix=${DOCU_PATH}/downloaded \
      -nH \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.gif,*.jpg,*.PNG,*.png,*.webp,*.mp4,*.ico,*.svg,*.js,*json,*.css,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
done 
}

arranging_rules(){


    ## Making a backup of the index, if it doesnt exists
    if [[ ! -d "${DOCU_PATH}/downloaded-bk" || ! "$(ls -A "${DOCU_PATH}/downloaded-bk" 2>/dev/null)" ]]; then
        cp -r ${DOCU_PATH}/downloaded ${DOCU_PATH}/downloaded-bk/
    fi


    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------
    # Add below statments regarding to arranging_rules that are specific for this documentation


    # EOF EOF EOF DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------



    ## Cleaning up documents

    ## Clean up the duplicates
    # Keeping the least nested one
    jdupes -r -N -d ${DOCU_PATH}/downloaded/


    ## Modifying documents


    rename_lone_index
    deestructuring_dir_tree
}



parsing_rules(){

    write_header
    write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body" -cp 


    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------
    # Add below statments regarding to arranging_rules that are specific for this documentation


    ## Retrieving content of the files and cleaning it
    sed -e '/^\[\]$/d' \
        -e 's/\[\]//g' \
        -e '/^-   $/d' \
        -e '/^ZAP$/d' \
        -e '/^Download$/d' \
        -e '/^-   Blog$/d' \
        -e '/^-   Videos$/d' \
        -e '/^-   Documentation$/d' \
        -e '/^-   Community$/d' \
        -e '/^-   Support$/d' \
        -e '/^-   Statistics/d' \
        -e '/^-   \[Search icon\]$/d' \
        -e '/\[The Crash Override Open Source Fellowship\]/d' \
        -i "${MAIN_TOUPDATE}"


    # EOF EOF EOF DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------


    write_ext_modeline


    # MODELINE FOR SYNTAX SPECIFIC PATTERNS FOR KEYWORDS
    # ---------------------------------------------------------------------------
    # Change below the keywords you want to be highlighted
    
    sed -i '11a\'$'\n''&@ g:dan_kw_question_list = "^References" @&' "${MAIN_TOUPDATE}"
    sed -i '12a\'$'\n''&@ g:dan_kw_nontext_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '13a\'$'\n''&@ g:dan_kw_linenr_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '14a\'$'\n''&@ g:dan_kw_warningmsg_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '15a\'$'\n''&@ g:dan_kw_colorcolumn_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '16a\'$'\n''&@ g:dan_kw_underlined_list = "^Responses" @&' "${MAIN_TOUPDATE}"
    sed -i '17a\'$'\n''&@ g:dan_kw_preproc_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '18a\'$'\n''&@ g:dan_kw_comment_list = "^Parameters:" @&' "${MAIN_TOUPDATE}"
    sed -i '19a\'$'\n''&@ g:dan_kw_identifier_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '20a\'$'\n''&@ g:dan_kw_ignore_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '21a\'$'\n''&@ g:dan_kw_statement_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '22a\'$'\n''&@ g:dan_kw_cursorline_list = "" @&' "${MAIN_TOUPDATE}"
    sed -i '23a\'$'\n''&@ g:dan_kw_tabline_list = "^Other Info,^Summary,^Code,^Latest Code,^See also,^  Code Samples,^  Example Responses" @&' "${MAIN_TOUPDATE}"
    # EOF EOF EOF MODELINE FOR SYNTAX SPECIFIC PATTERNS FOR KEYWORDS
    # ---------------------------------------------------------------------------
}


## PARSING ARGUMENTS
## ------------------------------------
# (do not touch)
while getopts ":ipa" opt; do
    case ${opt} in
        i)
            indexing_rules
            ;;
        p)
            parsing_rules
            ;;
        a)
            arranging_rules
            ;;
        h | *)
            echo "Usage: $0 [-i] [-p] [-a] [-h] "
            echo "Options:"
            echo "  -i  Indexing"
            echo "  -p  Parsing"
            echo "  -a  Arranging"
            echo "  -h  Help"
            exit 0
            ;;
    esac
done
## EOF EOF EOF PARSING ARGUMENTS
## ------------------------------------
