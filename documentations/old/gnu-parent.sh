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
#https://www.gnu.org
https://gcc.gnu.org
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

## PARSING ARGUMENTS
## ------------------------------------
# (do not touch)
while getopts ":siap" opt; do
    case ${opt} in
        s)
            spidering_rules
            ;;
        i)
            # Check if a start row number was provided
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                start_row="$2"
                shift
            fi
            indexing_rules "$start_row"
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
