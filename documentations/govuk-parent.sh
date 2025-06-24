#!/bin/bash 
# @file govuk
# @brief vim-dan ruleset file for documentation on govuk
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOWNLOAD_LINKS=(
https://www.gov.uk
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

        ## Ensure output directory exists
        mkdir -p "$(dirname "${LOCAL_CSV_PATH}")"

        ## Pulling and extracting repo file to local path
        bunzip2 -kc "${INDEX_LINKS_PATH}" > "${LOCAL_CSV_PATH}"

        ## WRITE BELOW YOUR INCLUSION RULES
        # if more than one rule needs to use temporary files
        incl_1=$(mktemp); sed -n '\|\.html",|p' "${LOCAL_CSV_PATH}" > "$incl_1"
        incl_2=$(mktemp); sed -n '\|\/",|p' "${LOCAL_CSV_PATH}" > "$incl_2"
        incl_3=$(mktemp); sed -En '/\/[^\.\/]+",/p' "${LOCAL_CSV_PATH}" > "$incl_3"
        incl_4=$(mktemp); sed -n '\|www[.]gov[.]uk|p' "${LOCAL_CSV_PATH}" > "$incl_4"

        cat "$incl_1" "$incl_2" "$incl_3" "$incl_4" > "${LOCAL_CSV_PATH}" 
        rm "$incl_1" "$incl_2" "$incl_3" "$incl_4"


        ## WRITE BELOW YOUR EXCLUSION RULES
        # sed -i '\|perldoc[.]perl[.]org/5.*|d' ${LOCAL_CSV_PATH}
    done

}


indexing_rules(){
    start_row="$1"

    ## Iterate through each link of the documentation
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
       download_fromlist_waitretry ${DOWNLOAD_LINK} 0.05 2 ${start_row}
    done
}

arranging_rules(){

    echo "This is a parent documentation"
    echo "Because of its size and/or organization,"
    echo " it is meant to be splitted into different sub documentations"
    echo " it is only for Spidering and Indexing"
    echo " <docu>-parent"
    echo " <docu>-subdocuOne"
    echo " <docu>-subdocuTwo"
    echo " ................ "
    echo " <docu>-subdocuN"

}

parsing_rules(){

    echo "This is a parent documentation"
    echo "Because of its size and/or organization,"
    echo " it is meant to be splitted into different sub documentations"
    echo " it is only for Spidering and Indexing"
    echo " <docu>-parent"
    echo " <docu>-subdocuOne"
    echo " <docu>-subdocuTwo"
    echo " ................ "
    echo " <docu>-subdocuN"

}


writting_rules(){

    echo "This is a parent documentation"
    echo "Because of its size and/or organization,"
    echo " it is meant to be splitted into different sub documentations"
    echo " it is only for Spidering and Indexing"
    echo " <docu>-parent"
    echo " <docu>-subdocuOne"
    echo " <docu>-subdocuTwo"
    echo " ................ "
    echo " <docu>-subdocuN"

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
