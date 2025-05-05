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

while getopts ":iupsxradth" opt; do
    case ${opt} in
        i)
            perform_install
            ;;
        u)
            perform_update
            ;;
        p)
            perform_parse
            ;;
        s)
            perform_spider
            ;;
        x)
            perform_index
            ;;
        r)
            perform_remove
            ;;
        a)
            perform_arrange
            ;;
        t)
            updating_tags
            ;;
        d)
            delete_index
            ;;
        h | *)
            echo "Usage: $0 [documentation] [-i] [-u] [-p] [-s] [-x] [-r] [-t] [-d] [-h] [-a]"
            echo "Options:"
            echo "  -i  Install Docu"
            echo "  -u  Update Docu"
            echo "  -p  Parse Docu"
            echo "  -s  Spider Docu"
            echo "  -x  Index Docu"
            echo "  -r  Remove Docu"
            echo "  -t  Updating Tags"
            echo "  -d  Delete Index"
            echo "  -a  Arraging Docu files"
            echo "  -h  Help"
            exit 0
            ;;
    esac
done

## EOF EOF EOF SELECTING_ACTION 
## ----------------------------------------------------------------------------
