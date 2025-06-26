#!/bin/bash 
# @file py-pi
# @brief vim-dan ruleset file for documentation on py-pi
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOWNLOAD_LINKS=(
https://pypi.org
)

## EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section ACTION_DEFINITION
# @description Ruleset for each individual stage of vim-dan

spidering_rules(){

    echo "The instructions for creating the .csv for this documentation are shown in the source-code"
    echo "We couldn't add this programatically as it involves the usage of 3rd party packages "
    echo "Using engines that are not in the scope of vim-dan-generator" 
    echo "Please check the commented lines in the source code to peform a fresh spider"

    ## We are using the repository https://github.com/hugovk/top-pypi-packages
    ##    to get the name of the 15,000 most downloaded packages in pypi.org
    ##  git clone https://github.com/hugovk/top-pypi-packages
    ##
    ##  $ mv 
    ##  $ unzip 2025.02.zip
    ##  $ readlink -f top-pypi-packages-2025.02/top-pypi-packages-30-days.csv 
    ##  GET THAT PATH AND USE IT BELOW FOR input_file
    

        # Input CSV file
        input_file="/home/fakuve/downloads/top-pypi-packages-2025.02/top-pypi-packages-30-days.csv"
        # Output file
        output_file="$CURRENT_DIR/../index-links/https___pypi.org.csv"

        # Skip the first line (header) and process the rest
        tail -n +2 "$input_file" | awk -F',' '{print "https://pypi.org/project/" $2 ",-1"}' | tr -d '"' > "$output_file"

        echo "Conversion complete. Saved as $output_file"



      # Compressing the file
      bzip2 "$CURRENT_DIR/../index-links/https___pypi.org.csv"

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
        #incl_1=$(mktemp); sed -n '\|perldoc[.]perl[.]org/|p' "${LOCAL_CSV_PATH}" > "$incl_1"
        #incl_2=$(mktemp); sed -n '\|nodejs[.]org/en/guides/|p' "${LOCAL_CSV_PATH}" > "$incl_2"

        #cat "$incl_1" > "${LOCAL_CSV_PATH}"
        #rm "$incl_1"

        ## WRITE BELOW YOUR EXCLUSION RULES
        #sed -i '\|perldoc[.]perl[.]org/5.*|d' ${LOCAL_CSV_PATH}
    done

}


indexing_rules(){
    start_row="$1"

    mkdir -p ${DOCU_PATH}/downloaded/project
    node "$CURRENT_DIR/../scripts/run_pupp-py-pi.js" -r "${start_row}"

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
