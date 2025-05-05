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
https://pypi.org
)
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS

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

indexing_rules(){

    ## Iterate through each link of the documentation
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')
        set -x
        node "$CURRENT_DIR/../scripts/download_from_list_wait_retry_pupp.js" --docu-path ${DOCU_PATH}/downloaded/ --csv-path $CURRENT_DIR/../index-links/${ntfs_filename}.csv.bz2 -w 3 -wr 80
        set +x
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
