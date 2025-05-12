#!/bin/bash 
# @file vim-dan-generator
# @brief Launcher file for vim-dan-generator documentation creation tool.
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -f "${CURRENT_DIR}/.vimdan_config" ]]; then
    source "${CURRENT_DIR}/.vimdan_config"
else
    echo "[Error] Please create your own ./vim-dan-generator/.vimdan_config file" >&2
    echo "In which you need to define the following variables:" >&2
    echo "export VIMDAN_DIR=\"/path/to/vimdan/files\"" >&2
    echo "export VIM_RTP_DIR=\"${HOME}/.vim\"" >&2
    return 
fi

source "$CURRENT_DIR/scripts/helpers.sh"


# Gathering all the documentations available
declare -a documentations_array

mapfile -t documentations_array < <(find $CURRENT_DIR/documentations/ -type f -name "*.sh" -exec basename {} .sh \; | sort )


## EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section PROCESSING_ARGUMENTS
# @description Description

# Function to check if the documentation exists
documentation_exists() {
    local documentation="$1"
    for f in "${documentations_array[@]}"; do
        [[ "$f" == "$documentation" ]] && return 0
    done
    return 1
}

# Parse command-line options
if [[ $# -lt 1 ]]; then
    echo "Select a documentation. Available documentations are:"
    for f in "${documentations_array[@]}"; do
        echo "${f}"
    done
    exit 1
fi

# Check if the first argument is a valid documentation
documentation="$1"
shift
if ! documentation_exists "$documentation"; then
    echo "Invalid documentation. Available documentations are:"
    for f in "${documentations_array[@]}"; do
        echo "${f}"
    done
    exit 1
fi


# Processing the global vars
export DOCU_NAME=$(basename ${documentation} '.sh')
process_paths

## EOF EOF EOF PROCESSING_ARGUMENTS 
## ----------------------------------------------------------------------------



## ----------------------------------------------------------------------------
# @section SELECTING_ACTION

while getopts ":sfx:apwth" opt; do
    case ${opt} in
        s) perform_spider ;;
        f) perform_filter ;;
        x) 
            if [[ -n "$OPTARG" && "$OPTARG" =~ ^[0-9]+$ ]]; then
                perform_index "$OPTARG"
            else
                echo "Error: -x requires a numeric row number" >&2
                exit 1
            fi
            ;;
        a) perform_arrange ;;
        p) perform_parse ;;
        w) perform_write ;;
        t) perform_tags ;;
        h) 
            echo "Usage: $0 [-s] [-f] [-x ROW] [-a] [-p] [-w] [-t] [-h]"
            echo ""
            echo "Options:"
            echo "  -s    Spider documentation (collect links)"
            echo "  -f    Filter spidered results"
            echo "  -x ROW Index documentation at specific ROW number"
            echo "  -a    Arrange documentation files"
            echo "  -p    Parse documentation content"
            echo "  -w    Write processed output"
            echo "  -t    Generate tags/metadata"
            echo "  -h    Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -s -f       # Spider and filter docs"
            echo "  $0 -x 42       # Index row 42"
            echo "  $0 -a -p -w    # Arrange, parse, and write"
            exit 0
            ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

## EOF EOF EOF SELECTING_ACTION 
## ----------------------------------------------------------------------------
