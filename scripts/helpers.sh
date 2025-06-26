#!/bin/bash 
# @file helpers.sh
# @brief Helper functions in use on vim-dan-generator.
# @description
#   author: rafmartom <rafmartom@gmail.com>



## ----------------------------------------------------------------------------
# @section External_subroutines


function perform_filter() {

    echo "Filtering vim-dan ${DOCU_NAME} on $CURRENT_DIR/../index-links/"
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh "-f"



    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_filtered" -i $(date +"%Y%m%d_%H%M%S") -n

}

# @description Sub-routines that are called by external files
#   They are mainly called by the main file
#   Thus they are triggered by the main stages of the Dan Documentation Generation


# @description Performs the spidering stage of a given documentation:
#   - For "vim-dan" spidering means the process of gathering all the links of the Files that are going to make the 
#   documentation topics.
#       It creates .csv file with all the links to be downloaded in /index-links/<site>.csv.bz2
#
#  Note that Child documentations dont have spidering_rules:
#      - Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
#      - Child documentations only have : arranging_rules and parsing_rules 
#
#   - The spidering rules are specific to each documentation and are defined in
#        /documentations/docu-name.sh:spidering_rules()
#   The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
#   Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
#   already established ruleset available /documentations/template.sh:
#   In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
#   If there are issues in any of the stages, then you may need to adapt these rules.
# @stdout Return Description
# @example perform_spider -n -p 
function perform_spider() {

    echo "Spidering vim-dan ${DOCU_NAME} on $CURRENT_DIR/../index-links/"
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh "-s"

    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_spidered" -i $(date +"%Y%m%d_%H%M%S") -n

}

# @description Performs the indexing stage of a given documentation
#   - For "vim-dan" indexing is the process of downloading each and every file of the documentation.
#   By following a link-list like the ones created on the spidering process the download can be
#     paused, halted and resumed other day.
#   The files will be downloaded on ${VIMDAN_DIR}/${DOCU_NAME}/downloaded
#   The indexing process can also take place directly, without a prior spider.
#
#  Note that Child documentations dont have indexing_rules:
#      - Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
#      - Child documentations only have : arranging_rules and parsing_rules 
#
#   - The indexing rules are specific to each documentation and are defined in
#        /documentations/docu-name.sh:indexing_rules()
#   The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
#   Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
#   already established ruleset available /documentations/template.sh:
#   In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
#   If there are issues in any of the stages, then you may need to adapt these rules.
# @stdout Return Description
# @example perform_index -n -p 
function perform_index() {
    START_ROW=${1}


    echo "Indexing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh "-x" ${START_ROW}

    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_indexed" -i $(date +"%Y%m%d_%H%M%S") -n


}

# @description Performs the arranging process of a given documentation
#   - For "vim-dan" arranging is the process of moving, and deleting of the files that have been download in the Index.
#   On the early versions of "vim-dan" this stage was more important, now thanks to the evolution of the algorithm there 
#   is no need to perform as many actions.
#   Actualy some actions are not desirable, such as moving files from one subdir to other will probably break the link parsing functionalities. 
#  This process creates a backup of the index that in case the rule-set is wrong, you can use without having to re-index it.
#   ${VIMDAN_DIR}/${DOCU_NAME}/downloaded-bk
#   After that, it deletes files that are not relevant for the documentation that have been downloaded.
#   In many cases if the documentation is only made of one DOWNLOAD_LINK (as many are) it is useful to bring down all the subdirectories from original the host directory deleting this.
#   At the end it cleans the duplicates.
#
#  Note that Parent documentations dont have arranging_rules:
#      - Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
#      - Child documentations only have : arranging_rules and parsing_rules 
#
#   - The arranging rules are specific to each documentation and are defined in
#        /documentations/docu-name.sh:arranging_rules()
#   The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
#   Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
#   already established ruleset available /documentations/template.sh:
#   In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
#   If there are issues in any of the stages, then you may need to adapt these rules.
# @stdout Return Description
# @example perform_arrange -n -p 
function perform_arrange() {

    echo "Arranging vim-dan ${DOCU_NAME} files on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh "-a"

    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_arranged" -i $(date +"%Y%m%d_%H%M%S") -n

}



# @description Performs the writting stage of a given documentation
#   - For "vim-dan" parsing means, obtaining the necessary text from each downloaded file, such as File "Titles", and Content
#    , taking off the rest of the redudant information that each file may have such as navigation bars footers etc...
#    In the most common of the cases are .html files with different Selectors, some matches the Titles, some matches the content.
#    Other stage of parsing involves processing the links.
#    On the writting stage there will be the creation of an interactive TOC
#    To then the appending of each File Relevant Content. All in the `.dan` format.
#    At the end of the writting process there is a cleanup process, for yet some string regularities that couldn't be filtered on the previous process (it typically involve sed commands)
#   To then create the different modelines needed for the functioning of the `.dan` format.
#
#   Once the file has been generated, it will install all the vim-dan files locally if they are not installed.
#
#  Note that parent documentations dont have parsing_rules:
#      - Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
#      - Child documentations only have : arranging_rules and parsing_rules 
#
#   - The parsing rules are specific to each documentation and are defined in
#        /documentations/docu-name.sh:parsing_rules()
#   The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
#   Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
#   already established ruleset available /documentations/template.sh:
#   In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
#   If there are issues in any of the stages, then you may need to adapt these rules.
# @stdout Return Description
# @example perform_write -n -p 
function perform_write() {

    echo "Writting vim-dan ${DOCU_NAME} on ${VIMDAN_DIR}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh "-w"

    mv ${MAIN_TOUPDATE} ${MAIN_FILE}
#    perform_patch

    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_written" -i $(date +"%Y%m%d_%H%M%S") -n
}



function perform_parse() {

    echo "Parsing vim-dan ${DOCU_NAME} on ${VIMDAN_DIR}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh "-p"

    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_parsed" -i $(date +"%Y%m%d_%H%M%S") -n

}



# @description Performs the tagging stage of a documentation
function perform_tags() {
    
    echo "Generating tags of ${DOCU_NAME} on ${VIMDAN_DIR}/ ..."

    ctags --options=NONE --options=${CURRENT_DIR}/ctags-rules/dan.ctags --sort=no --tag-relative=always -f ${VIMDAN_DIR}/.tags${DOCU_NAME} ${MAIN_FILE} 

    ## Cleaning duplicates of nested tags
    #
    # See issue https://github.com/universal-ctags/ctags/issues/4253
    #
    # Block links and in-line links have collitions ,
    #   cause in-line links generate both a relative (f)
    #
    #   for instance check the collision of :tag f with :tag e#f
    # f	js-cheerio.dan	/^See <L=e#f><\/L><I=f>$/;"	i	line:133	language:dantags	regex:e
    # e#f	js-cheerio.dan	/^See <L=e#f><\/L><I=f>$/;"	i	line:133	language:dantags	regex:e
    # f	js-cheerio.dan	/^<B=f>Function: contains()$/;"	b	line:3569	language:dantags
    #
    # When Doing :tag f you want to go to
    # f	js-cheerio.dan	/^<B=f>Function: contains()$/;"	b	line:3569	language:dantags
    #
    # Instead vim will go to the firstone found
    # f	js-cheerio.dan	/^See <L=e#f><\/L><I=f>$/;"	i	line:133	language:dantags	regex:e
    # Which is in fact :tag e#f
    
    sed -i -E '/^[a-zA-Z0-9]+\t.*\tregex:[a-zA-Z0-9]+$/d' ${VIMDAN_DIR}/.tags${DOCU_NAME}


    # Logging that into the documentation-status file
    update_csv_field -f "$CURRENT_DIR/documentation-status.csv" -r "${DOCU_NAME}" -c "last_tagged" -i $(date +"%Y%m%d_%H%M%S") -n
}

## EOF EOF EOF External_subroutines
## ----------------------------------------------------------------------------







## ----------------------------------------------------------------------------
# @section Internal_subroutines
# @description Subroutines that are triggered automatically by other function
#   Note for minimal boilerplate these functions:
#    - Are going to use shared variables
#    - Are not going to have type checking
#    Thus they wont be moveable from this file without re-writting 



# @description Generate shared-variables for use across the script
#   Mostly related to filepaths that are processed through the minimal
#   Arguments needed
function process_paths() {
    export MAIN_TOUPDATE="${VIMDAN_DIR}/${DOCU_NAME}-toupdate.dan"
    export MAIN_FILE="${VIMDAN_DIR}/${DOCU_NAME}.dan"
    export DOCU_PATH="${VIMDAN_DIR}/${DOCU_NAME}"
}

# @description Installs the vim autoload dan file
function install_autoload() {
    if [ ! -f ${VIM_RTP_DIR}/autoload/dan.vim ]; then
        echo "Installing autoload ..."
        [ ! -d ${VIM_RTP_DIR}/autoload ] && mkdir -p ${VIM_RTP_DIR}/autoload 
        cp ${CURRENT_DIR}/autoload/dan.vim ${VIM_RTP_DIR}/autoload/
    fi
}

# @description It attempts to update an outdated dan-file with (X) annotations with a new-one.
#   It maw casuse conflicts, it is recommendable not to mix new versions of dan files with old ones
function perform_patch() {
    echo "Patching the documentation..."
    # Patching the localdocu
    # If performed for the first-time just use the new index
    if [ -e ${MAIN_FILE} ]; then
        cp ${MAIN_FILE} ${MAIN_FILE}-bk
        diff <(sed 's/ (X)$//g' ${MAIN_FILE}) ${MAIN_TOUPDATE} | patch ${MAIN_FILE}
        rm ${MAIN_TOUPDATE}
    else
        mv ${MAIN_TOUPDATE} ${MAIN_FILE}
    fi
}

# @description Update the local tags file for the current documentation
function update_tags() {
    echo "Updating the tag file..."
    ctags --options=NONE --options=${CURRENT_DIR}/ctags-rules/dan.ctags --tag-relative=always -f ${VIMDAN_DIR}/.tags${DOCU_NAME} ${MAIN_FILE} 
    [ ! -d "${HOME}/.ctags.d" ] && mkdir -p "${HOME}/.ctags.d"
    cp ${CURRENT_DIR}/ctags-rules/dan.ctags ${HOME}/.ctags.d/

}

# @description It install/replaces the vim configuration files needed for dan functionalities.
function update_vim() {
    echo "Updating vim files..."
    [ ! -d "${VIM_RTP_DIR}/ftdetect" ] && mkdir -p "${VIM_RTP_DIR}/ftdetect"
    cp ${CURRENT_DIR}/ft-detection/dan.vim  ${VIM_RTP_DIR}/ftdetect/
    [ ! -d "${VIM_RTP_DIR}/after/ftplugin" ] && mkdir -p "${VIM_RTP_DIR}/after/ftplugin"
    cp ${CURRENT_DIR}/linking-rules/dan.vim ${VIM_RTP_DIR}/after/ftplugin/dan.vim
    [ ! -d "${VIM_RTP_DIR}/syntax" ] && mkdir -p "${VIM_RTP_DIR}/syntax"
    cp ${CURRENT_DIR}/syntax-rules/dan.vim  ${VIM_RTP_DIR}/syntax/
}


## EOF EOF EOF Internal_subroutines 
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section Cross-Project Utilities
# @description Utility functions that are usable in other projects


# @description Reads a file in reverse (from last line to first) to find the first occurrence of a <B=${BUID}> pattern.
# @arg $1 string The path to the file to search.
# @stdout Outputs a space-separated string: ${BUID} line_no (the matched BUID and its original line number).
# @exitcode 0 If a match is found.
# @exitcode 1 If no match is found.
# @example
#   result=($(get_match_from_last "/path/to/file"))
#   buid="${result[0]}"
#   line_no="${result[1]}"
#   echo "BUID: $buid"
#   echo "Line Number: $line_no"
get_match_from_last() {
    local file=$1
    local total_lines
    total_lines=$(wc -l < "$file")

    # Capture BUID and reverse line number from the reversed file
    read -r buid reverse_nr < <(tac "$file" | awk '
        match($0, /^<B=([a-zA-Z0-9]+)>/, arr) {
            print arr[1], NR
            exit
        }')

    if [[ -n "$buid" && -n "$reverse_nr" ]]; then
        local line_no=$((total_lines - reverse_nr + 1))
        echo "$buid $line_no"
        return 0
    else
        return 1
    fi
}

#get_match_from_last "/home/fakuve/downloads/vim-dan/cppreference-toupdate.dan"
#
#result=($(get_match_from_last "/home/fakuve/downloads/vim-dan/cppreference-toupdate.dan"))
#buid="${result[0]}"
#line_no="${result[1]}"
#
#echo "BUID: $buid"
#echo "Line Number: $line_no"



# @description A check for the writing process. Checks if a ${DOCU}-toupdate.dan file exists and extracts the last partial write.
# @stdout Outputs an array with ($file $line_no) to be fed to ${paths_linkto[$file]}.
# @exitcode 0 If a match is found.
# @exitcode 1 If no match is found.
# @example
#   read -r file line_no <<< "$(get_writting_toupdate)"
#   some_command "${paths_linkto[$file]}" "$line_no"
function get_writting_toupdate() {
    echo "Checking for previous partial write on ${MAIN_TOUPDATE} ..." >&2

    # Try to get the match from the last <B=...>
    if ! result=($(get_match_from_last "$MAIN_TOUPDATE")); then
        return 1  # No match found
    fi

    buid="${result[0]}"
    line_no="${result[1]}"

    # Lookup file path from CSV based on BUID
    file=$(awk -F, -v buid="$buid" 'NR > 1 && $6 == buid {print $1; exit}' "$links_index_csv" | sed 's/["'\''"]//g')

    echo "$file $buid $line_no"
}


# @description decho Prints a debug message if DEBUG mode is enabled.
# @arg $* Strings to output as the debug message
# @stdout Outputs the message to stderr if DEBUG is set to 'true'
# @example DEBUG=true
# @example decho "Value of var is: $var"
function decho() {
    if [[ "$DEBUG" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}


# @description Update a CSV field given a ROW_NAME for the first column and a COL_NAME for the header column.
# If both ROW_NAME and COL_NAME match, the field will be updated with INPUT_STRING.
# If the -n flag is used and ROW_NAME is not found, a new row will be added at the end of the CSV file.
#
# Example CSV:
#   ,notes,last_parsed,last_arranged
#   adobe-ae,,,,
#   patxie,,,,
#
# Example usage:
#   update_csv_field -f "example.csv" -r "adobe-ae" -c "last_parsed" -i "now"
#
# Result:
#   ,notes,last_parsed,last_arranged
#   adobe-ae,,now,,
#   patxie,,,,
#
# @option -f <CSV_FILENAME> The path to the CSV file to update.
# @option -r <ROW_NAME> The name of the row to update (matches the first column).
# @option -c <COL_NAME> The name of the column to update (matches the header row).
# @option -i <INPUT_STRING> The new value to insert into the specified field.
# @option -n Add a new row if ROW_NAME is not found in the CSV file.
# @stdout No direct output. The CSV file is modified in place.
# @example update_csv_field -f "example.csv" -r "adobe-ae" -c "last_parsed" -i "now"
# @example update_csv_field -f "example.csv" -r "new-row" -c "notes" -i "added" -n
function update_csv_field() {
    ## PARSING FUNCTION ARGUMENTS ------------------------
    ## ---------------------------------------------------
    local OPTIND=1
    # Initialize variables
    CSV_FILENAME=""
    ROW_NAME=""
    COL_NAME=""
    INPUT_STRING=""
    NEW_ROW=""

    while getopts "f:r:c:i:n" opt; do
        case "${opt}" in
            f) CSV_FILENAME="${OPTARG}" ;;
            r) ROW_NAME="${OPTARG}" ;;
            c) COL_NAME="${OPTARG}" ;;
            i) INPUT_STRING="${OPTARG}" ;;
            n) NEW_ROW=1 ;;  # Flag to indicate a new row should be added if ROW_NAME is not found
            *)
                echo "Usage: update_csv_field -f CSV_FILENAME -r ROW_NAME -c COL_NAME -i INPUT_STRING [-n]" >&2
                echo "Example: update_csv_field -f CSV_FILENAME -r ROW_NAME -c COL_NAME -i INPUT_STRING [-n]" >&2
                return 1
                ;;
        esac
    done
    # Variable check
    if [[ -z "${CSV_FILENAME}" || -z "${ROW_NAME}" || -z "${COL_NAME}" || -z "${INPUT_STRING}" ]]; then
        echo "Error: update_csv_field requires -f CSV_FILENAME -r ROW_NAME -c COL_NAME -i INPUT_STRING" >&2
        return 1
    fi
    ## PARSING FUNCTION ARGUMENTS ------------------------
    ## EOF EOF EOF EOF------------------------------------

    TMP_FILE=$(mktemp)
    dos2unix "${CSV_FILENAME}" 2> /dev/null

    awk -F',' -v OFS=',' -v row_name="$ROW_NAME" -v col_name="$COL_NAME" -v input_string="$INPUT_STRING" -v new_row="$NEW_ROW" '
    NR==1 {
        for (i=1; i<=NF; i++) if ($i == col_name) col=i;
        total_cols=NF;  # Store total number of columns
        print;
        next;
    }
    $1 == row_name && col {
        $col = input_string;
        found_row=1;
    }
    { print }
    END {
        if (new_row == 1 && !found_row && col) {
            printf "%s", row_name;
            for (i=2; i<=total_cols; i++) {
                if (i == col) {
                    printf ",%s", input_string;
                } else {
                    printf ",";
                }
            }
            printf "\n";
        }
    }' "$CSV_FILENAME" > "$TMP_FILE" && mv "$TMP_FILE" "$CSV_FILENAME"

    [ -f "$TMP_FILE" ] && rm -f "$TMP_FILE"
}

# @description Converts a decimal number to a base-62 alphanumeric string.
# This function maps decimal numbers to a custom base-62 encoding using the characters 0-9, a-z, and A-Z.
# It is useful for generating short, unique identifiers from numeric values.
#
# @arg $1 <num> The decimal number to convert.
# @stdout The base-62 alphanumeric representation of the input number.
# @example decimal_to_alphanumeric 12345  # Converts 12345 to a base-62 string
function decimal_to_alphanumeric() {
    local num=$1
    ALPHANUMERIC=($(echo {0..9} {a..z} {A..Z}))
    local base=${#ALPHANUMERIC[@]}
    local result=""

    while [ $num -gt 0 ]; do
        remainder=$((num % base))
        result="${ALPHANUMERIC[remainder]}$result"
        num=$((num / base))
    done

    echo "$result"
}


# @description Converts a base-62 alphanumeric string back to a decimal number.
# This reverses the encoding from `decimal_to_alphanumeric`, using characters 0-9, a-z, and A-Z.
#
# @arg $1 <str> The base-62 alphanumeric string to convert.
# @stdout The decimal number representation of the input string.
# @example alphanumeric_to_decimal "3d7"  # Converts base-62 string "3d7" back to decimal
function alphanumeric_to_decimal() {
    local str=$1
    local -a ALPHANUMERIC=({0..9} {a..z} {A..Z})
    local base=${#ALPHANUMERIC[@]}
    local -A lookup
    local result=0

    # Build lookup table: char -> value
    for i in "${!ALPHANUMERIC[@]}"; do
        lookup["${ALPHANUMERIC[$i]}"]=$i
    done

    local char
    for (( i = 0; i < ${#str}; i++ )); do
        char="${str:$i:1}"
        value=${lookup[$char]}
        if [[ -z "$value" ]]; then
            echo "Invalid character in input: $char" >&2
            return 1
        fi
        result=$((result * base + value))
    done

    echo "$result"
}


## EOF EOF EOF Cross-Project Utilities
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section Deprecated Functions
# @description The following functions are no longer used in this project
#   Although it is worth keeping, as they may be useful again.
#   Or they are well written algorithms worth to be re-checked


# @description Transforms a relative HTML link such as /guidance/living-in-europe
# into & @guidance-)living-in-europe.html@ living-in-europe &
rellink_to_danlinkfrom () {
    rel_link=$1
    linkto_prefix=$(echo "${rel_link}" | sed 's/^\///' | sed -E 's/(.*)(\.html)?$/\1.html/')
    linkto_title=$(basename "${rel_link}")
    danlinkfrom="& @${linkto_prefix}@ ${linkto_title} &"
    echo "${danlinkfrom}"
}


# @description Parses an HTML file to generate an in-file HTML list of "danlinkfrom"-formatted links.
# This function is used during the arrangement process and cannot use `cut-dirs`. It appends a list of
# filtered links to the specified HTML file, wrapped in a `.dan-seealso` div.
#
# The function extracts `href` attributes from elements matching the given CSS selector and filters
# them based on include paths. If no include paths are provided, all relative links are included.
#
# Example usage:
#   parse_dan_seealso "./downloaded/spain.html" ".govuk-link attr{href}" "government/collections" "guidance"
#
# This will parse the `href` attributes from elements with the class `.govuk-link` and include only
# those links that start with `/government/collections` or `/guidance`.
#
# @arg $1 <file> The path to the HTML file to process.
# @arg $2 <selector> The CSS selector to extract links (e.g., ".govuk-link attr{href}").
# @arg $@ <includes> Optional list of include paths to filter links (e.g., "government/collections").
# @stdout Appends an HTML list of filtered links to the input file.
# @example parse_dan_seealso "./downloaded/spain.html" ".govuk-link attr{href}" "government/collections" "guidance"
# @example parse_dan_seealso "./downloaded/spain.html" ".govuk-link attr{href}"  # Includes all relative links
parse_dan_seealso() {
    file=$1
    selector=$2
    shift 2  # Shift to move past the first two arguments

    # Convert the remaining arguments into an array
    includes=("$@")

    # Parse links
    temp_links=$(cat "${file}" | pup "${selector}")

    # Check if the temporary variable is not empty
    if [[ -n "$temp_links" ]]; then
        # De-structure the multiline string into an array
        links_array=()
        while IFS= read -r link; do
            links_array+=("$link")
        done <<< "$temp_links"
    fi

    # Filter the links according to the array of includes
    filtered_links=()

    for link in "${links_array[@]}"; do
        # Skip absolute URLs (external links)
        if [[ "$link" == http://* || "$link" == https://* ]]; then
            continue
        fi

        # If no includes are given, add all relative links
        if [[ ${#includes[@]} -eq 0 ]]; then
            filtered_links+=("$link")
            continue
        fi

        # Otherwise, check if the link starts with any of the allowed paths
        for pattern in "${includes[@]}"; do
            if [[ "$link" == /"$pattern"* ]]; then
                filtered_links+=("$link")
                break  # Stop checking other patterns once a match is found
            fi
        done
    done

    # Append the HTML content to the file
    cat <<EOF >> "$file"
<div class="dan-seealso">
    <p>DAN See Also Links:</p>
    <ul>
EOF

    # Loop through filtered links and append each link as a list item
    for filtered_link in "${filtered_links[@]}"; do
        cat <<EOF >> "$file"
        <li>$(rellink_to_danlinkfrom "${filtered_link}")</li>
EOF
    done

    # Close the HTML tags
    cat <<EOF >> "$file"
    </ul>
</div>
EOF
}


# @description Renames lone `index.html` files to match their parent directory names and moves them one level up.
# This function is useful for restructuring downloaded HTML files where `index.html` files are nested in subdirectories.
# For example:
#   - Input:  www.zaproxy.org/docs/alerts/0/index.html
#   - Output: www.zaproxy.org/docs/alerts/0.html
#
# If the function creates a file named `${DOCU_PATH}/downloaded.html`, it moves it back to `${DOCU_PATH}/downloaded/index.html`.
#
# @arg $DOCU_PATH The base directory containing the downloaded files.
# @stdout No direct output. Files are renamed and moved in place.
# @example rename_lone_index
rename_lone_index() {
    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/" -type f -name "index.html")
    for file in "${files_array[@]}"; do
        parent="$(basename "$(dirname ${file})")"
        dirname=$(dirname ${file})
        ext=${file##*.}
        mv ${file} "$dirname/../$parent.$ext";
    done

    # If last has created ${DOCU_PATH}/downloaded.html , put it back to downloaded/
    [ -f ${DOCU_PATH}/downloaded.html ] && mv ${DOCU_PATH}/downloaded.html ${DOCU_PATH}/downloaded/index.html
}

# @description Flattens a directory tree by moving files from nested subdirectories to their parent directories.
# This function renames files to include their parent directory names, effectively "de-structuring" the directory hierarchy.
#
# For example:
#   - Input:  www.zaproxy.org/docs/desktop/addons/access-control-testing/contextoptions.html
#   - Output: www.zaproxy.org/docs/desktop/addons/access-control-testing-contextoptions.html
#
# The function iterates up to 15 times to ensure all nested files are moved. After flattening, it deletes any empty directories.
#
# @arg $DOCU_PATH The base directory containing the downloaded files.
# @stdout No direct output. Files are moved and renamed in place, and empty directories are deleted.
# @example deestructuring_dir_tree
deestructuring_dir_tree() {
    # De-estructure all the directory hierarchy
    for i in {1..15}; do
        mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -mindepth 2 -type f)

        for file in "${files_array[@]}"; do
            parent="$(basename "$(dirname ${file})")"
            dirname=$(dirname ${file})
            mv ${file} "$dirname/../"${parent}"-)$(basename ${file})";
        done
    done

    # Pruning off the empty directories
    find "${DOCU_PATH}/downloaded/" -type d -empty -delete
}

function write_docu_multirule() {
  ## MULTI-FILE PARSING WITH MULTI-RULE
  ## Parsing into an associative array each title and path
  ## With this we can:
  ##      - Create an ordered automated index linkFrom
  ##      - Append each topic content with a linkTo and a figlet header
  ##
  ## Also, there are different parsing rules (multi-rule)
  ##      - Meaning they will be applied to each file sequentially
  ##      - Upon one parsing rule returning non-zero, that parsed title will be added
  ## Example of usage
  ##
  ## write_docu_multirule -f "pup -i 0 --pre 'head title' | pandoc -f html -t plain" \
  ##                      -b "pup -i 0 --pre 'div.guide-content' | pandoc -f html -t plain" \
  ##                      -b "pup -i 0 --pre 'body' | pandoc -f html -t plain"


  local title_parsing_array=()
  local content_parsing_array=()

  ## Parse options for title and body rules
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -f)
        if [[ -n "$2" ]]; then
          title_parsing_array+=("$2")
          shift 2
        else
          echo "Error: Missing argument for -f" >&2
          return 1
        fi
        ;;
      -b)
        if [[ -n "$2" ]]; then
          content_parsing_array+=("$2")
          shift 2
        else
          echo "Error: Missing argument for -b" >&2
          return 1
        fi
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  ## Finding all HTML files within a specific directory, sorted in version order
  mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

  ## First create the title array
  title_array=()
  for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions, add as many as needed
    found_selector=""
    for title_parsing in "${title_parsing_array[@]}"; do
      # Making sure that the titles don't have line breaks
      title=$(eval "$title_parsing" < "$file" | sed ':a;N;$!ba;s/\n/ /g')
      if [ -n "$title" ]; then
        found_selector=true
        break
      fi
    done

    # Default case for parsing, if none of the rules return a non-zero string
    if [ -z "$found_selector" ]; then
      title=$(basename "$file" | cut -f 1 -d '.')
    fi

    # Append the title to the title_array
    title_array+=("$title")
  done

  ## Creating an associative array to map titles to file paths
  declare -A paths_linkto

  # Iterate through the indices of 'files_array'
  for index in "${!files_array[@]}"; do
    file="${files_array[$index]}"
    title="${title_array[$index]}"
    paths_linkto["$file"]="$title"
  done

  # Create the linkFrom index header using figlet
  echo "index" | figlet >> "$MAIN_TOUPDATE"
  prev_dirs_array=()

  ## Splitting directories from filenames and building nested lists
  for file in "${files_array[@]}"; do

    filename=$(basename "$file")
    unset dirs_array
    remaining_file="$filename"

    for ((i=0; i<25; i++)); do
      if [[ "$remaining_file" =~ ([^\)]+)-\)(.+) ]]; then
        dirs_array[i]="${BASH_REMATCH[1]}"
        remaining_file="${BASH_REMATCH[2]}"
      else
        dirs_array[i]="$remaining_file"
        break
      fi
    done

    ## In order to create from this
    ##"workspace-)cse-)reference-)wrap"
    ##"workspace-)cse-)reference-)wrap-private-key"
    ##"workspace-)events-)docs-)release-notes"
    ##
    ## to this
    ##- workspace
    ##    - cse
    ##        - reference
    ##            - wrap
    ##            - wrap-private-key
    ##    - events
    ##        - docs
    ##            -release-notes
    ##
    ## We need to check dirs_array member by member and see what is the indentation
    ## index in which the directory structure differs
    ##
    ##
    ## defining dirs_arrays
    ## defining prev_dirs_array
    ##      Comparing them we calculate
    ##      first_discrepancy_level
    ##          the nesting level at which dirst_array and prev_dirs_array differ
    ##
    ## for instance
    ##     prev_dirst_array=( "workspace" "cse" "reference" "wrap-private-key")
    ##     dirs_array=( "workspace" "events" "docs" "release-notes")
    ##     first_discrepancy_level=2
    ## knowing that file_nesting_level will be determined by length of dirs_array
    ##   file_nesting_level=${#dirs_array[@]}
    ##
    ## And having 3 printing expressions
    ##
    ##
    ## # printing indentation tabs for a certain current_nesting_level
    ## for ((i=1 ; i<=${current_nesting_level}; i++)); do
    ##     for ((j=1; j<${i}; j++)); do
    ##         echo -ne "\t" >> ${MAIN_TOUPDATE}
    ##     done
    ## done
    ##
    ## # printing a linkto bulletpoint
    ## echo -ne "- & @${filename}@ ${paths_linkto[${file}]} &\n" >> ${MAIN_TOUPDATE}
    ##
    ## # printing a subdir bullet point
    ## echo -ne "- ${dirs_array[(${current_nesting_level})]}\n" >> ${MAIN_TOUPDATE}
    ##
    ## Iterating on the filelist
    ##     calculate first_discrepancy_level for each dirs_array in compare with prev_dirs_array
    ## Then for each file we will need to be iterating on each current_nesting_level
    ## # Provided that file_nesting_level=${#dirs_array[@]}
    ##      we iterate from first_discrepancy_level to file_nesting_level
    ##      setting each iteration as current_nesting_level
    ##      Starting from current_nesting_level=first_discrepancy_level
    ##      # printing indetation tabs for a certain current_nesting_level
    ##          if indentantion_nesting_level -eq to file_nesting_level
    ##          then we
    ##          # printing a linkto bulletpoint
    ##          otherwise
    ##          # printing a subdir bullet point
    ## Note: Base of index variables
    ##  first_discrepancy_level , base 0
    ##  file_nesting_level , base 1 , (converting to base 0)


    ## Compare current directory structure with the previous one to determine nesting
    for ((i=0; i<${#dirs_array[@]}; i++)); do
      if [ "${dirs_array[$i]}" != "${prev_dirs_array[$i]}" ]; then
        first_discrepancy_level=$i
        break
      fi
    done

    file_nesting_level=${#dirs_array[@]}
    file_nesting_level=$((file_nesting_level - 1))

    ## Iterating through nested levels and formatting output with indentation
    for ((current_nesting_level=first_discrepancy_level; current_nesting_level<=file_nesting_level; current_nesting_level++)); do

      for ((i=0; i<=current_nesting_level; i++)); do
        for ((j=0; j<i; j++)); do
          echo -ne "\t" >> "$MAIN_TOUPDATE"
        done
      done

      if [[ $current_nesting_level -eq $file_nesting_level ]]; then
        echo -ne "- & @${filename}@ ${paths_linkto[$file]} &\n" >> "$MAIN_TOUPDATE"
      else
        echo -ne "- ${dirs_array[($current_nesting_level)]}\n" >> "$MAIN_TOUPDATE"
      fi
    done

    prev_dirs_array=("${dirs_array[@]}")
  done

  echo "" >> "$MAIN_TOUPDATE"  ## Adding a line break

  ## Parsing and appending content, using Multi-rule
  for path in "${files_array[@]}"; do

    filename=$(basename "$path")
    echo "# ${filename} #" >> "$MAIN_TOUPDATE"
    echo "& ${paths_linkto[$path]} &" >> "$MAIN_TOUPDATE"
    echo "${paths_linkto[$path]}" | figlet >> "$MAIN_TOUPDATE"

    for content_parsing in "${content_parsing_array[@]}"; do
        # Create content parsing array
        content_dump=$(mktemp)
        found_selector=""


        eval "$content_parsing" < "$path" > "$content_dump"
        if [ 1 -lt $(stat -c %s "${content_dump}") ]; then

            echo "FOUND SELECTOR" >&2
            cat ${content_dump} >> "$MAIN_TOUPDATE"
            break
        fi


        # Default case for parsing , if none of the rules return a non-zero string
        if [ -z "$found_selector" ]; then
           cat ${path} | pandoc -f html -t plain > "$content_dump"
        fi

    done
  done
}


# @description Lists files or directories that are N levels below a specified subdirectory.
# This function searches for items (files or directories) at a specific depth relative to a given subdirectory.
# It supports optional recursion to include items in all subdirectories below the specified level.
#
# @arg $1 <items> The type of items to search for: "f" for files, "d" for directories.
# @arg $2 <level> The depth (number of levels) below the specified subdirectory to search.
# @arg $3 <directory> The name of the subdirectory to search within (e.g., "Global_Objects").
# @arg $4 <recursion> Whether to include items in all subdirectories below the specified level: "yes" or "no".
# @stdout Prints the paths of matching files or directories.
# @example getItemsNLevelDir "f" "1" "Global_Objects" "no"  # Lists direct children files of "Global_Objects"
# @example getItemsNLevelDir "d" "2" "Global_Objects" "yes" # Lists directories 2 levels below "Global_Objects" with recursion
function getItemsNLevelDir() {
    items=$1
    level=$2
    directory=$3
    recursion=$4
    regex="[A-Za-z0-9_/.-]*${directory}"

    for (( i=2; i<((${level} + 1)); i++ )); do
        echo ${i};
        regex+="\/[A-Za-z0-9_-]*"
    done

    if [ ${recursion} == 'yes' ]; then
        regex+="\/[A-Za-z0-9_/.-]*"
    else
        regex+="\/[A-Za-z0-9_.-]*"
    fi

    echo ${regex}
    find ./ -type ${items} -regex ${regex}
}

# @description Finds files with a given extension that have a sibling directory of the same name.
# This function searches for files with the specified extension in a directory and checks if there
# is a corresponding directory with the same name (excluding the extension). If such a directory
# exists, the file path is printed. The function processes subdirectories recursively.
#
# @arg $1 <dir> The directory to search in.
# @arg $2 <ext> The file extension to search for (e.g., "html").
# @stdout Prints the paths of files that have a sibling directory with the same name.
# @example find_same_name_sibling_directory '.' 'html'  # Finds .html files with sibling directories in the current directory
function find_same_name_sibling_directory() {
    local dir="$1"
    local ext="$2"
    # Find all .EXT files in the directory
    ext_files=$(find "$dir" -maxdepth 1 -type f -name "*.${ext}" -printf "%f\n")
    # Loop through EXT files for ext_file in $ext_files; do
    for ext_file in $ext_files; do
        # Check if there's a corresponding directory with the same name
        if [ -d "${dir}/${ext_file%.*}" ]; then
            echo "${dir}/${ext_file}"
        fi
    done

    # Recursively process subdirectories
    subdirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d)
    for subdir in $subdirs; do
        find_same_name_sibling_directory "$subdir" "$ext"
    done
}

# @description Estimates the total plaintext size of documentation files by calculating the difference between HTML size and HTML boilerplate overhead.
# This function calculates the "HTML headroom" (boilerplate overhead) for a single HTML file and extrapolates it to all HTML files in the directory.
# It then subtracts the total headroom from the total HTML size to estimate the plaintext size of the documentation.
#
# The function outputs:
#   - HTML headroom for a single file.
#   - Total number of HTML files.
#   - Total headroom for all files.
#   - Total HTML size in bytes.
#   - Estimated plaintext size in bytes and megabytes.
#
# @arg $DOCU_PATH The base directory containing the downloaded HTML files.
# @stdout Prints the estimated plaintext size of the documentation in bytes and megabytes.
# @example estimate_docu_weight  # Estimates the plaintext size of documentation in ${DOCU_PATH}/downloaded
function estimate_docu_weight() {
    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

    # Get plaintext size
    plaintext_size=$(cat "${files_array[0]}" | pup -i 0 --pre 'article div.devsite-article-body' | pandoc -f html -t plain --wrap=none | wc -c)

    # Get HTML file size
    html_size=$(stat -c%s "${files_array[0]}")

    html_headroom=$((${html_size} - ${plaintext_size}))

    echo "HTML headroom: ${html_headroom}"

    # Get the total number of HTML files
    num_files=$(find "${DOCU_PATH}/downloaded" -maxdepth 1 -type f -name "*.html" | wc -l)

    echo "Number of HTML files: ${num_files}"

    total_headroom=$((${html_headroom} * ${num_files}))
    echo "Total Headroom: ${total_headroom}"

    html_size=$(du -sb "${DOCU_PATH}/downloaded" | awk '{print $1}')
    echo "HTML size: ${html_size}"

    bytes_total_docu=$((${html_size} - ${total_headroom}))

    # Convert total plaintext bytes to megabytes
    bytes_total_docu_mb=$(echo "scale=2; $bytes_total_docu / 1048576" | bc)

    echo "Total documentation bytes (estimated plaintext): ${bytes_total_docu} bytes"
    echo "Total documentation size (estimated plaintext) in MB: ${bytes_total_docu_mb} MB"
}


# @description Splits documentation files into a specified number of parts of approximately equal size.
# This function calculates the size of each split and identifies the files where the splits should occur.
# It assumes that the documentation files are sorted alphabetically and will be processed in that order.
#
# The function outputs the filenames where each split occurs and the size of each split.
#
# @arg $1 <no_splits> The number of splits to create.
# @arg $2 <path> The directory containing the HTML files to split.
# @stdout Prints the split points (filenames) and the size of each split.
# @example get_split_files 3 "${DOCU_PATH}/downloaded"  # Splits files in ${DOCU_PATH}/downloaded into 3 parts
function get_split_files() {
    no_splits=$1
    path=$2

    html_size=$(du -sb "${path}/" | awk '{print $1}')

    mapfile -t files_array < <(find "${path}/" -type f -name "*.html" | sort -V)
    acumulated_size=0
    chunk_size=$((${html_size} / ${no_splits}))
    split_count=0

    for file in "${files_array[@]}"; do
        current_filesize=$(stat -c%s "${file}")
        acumulated_size=$((${acumulated_size} + ${current_filesize}))

        if [[ ${acumulated_size} -gt ${chunk_size} ]]; then
            split_count=$((${split_count} + 1))
            echo "Split no: ${split_count} split at file: ${file}"
            acumulated_size=0
            if [[ $((${split_count} + 1)) -eq ${no_splits} ]]; then
                break
            fi
        fi
    done
}

# @description Splits a subset of documentation files into a specified number of parts of approximately equal size.
# This function is similar to `get_split_files`, but it operates on a subset of files between `file_start` and `file_finnish`.
# It calculates the size of each split and identifies the files where the splits should occur.
# The function assumes that the documentation files are sorted alphabetically and will be processed in that order.
#
# The function outputs the filenames where each split occurs and the size of each split.
#
# @arg $1 <no_splits> The number of splits to create.
# @arg $2 <path> The directory containing the HTML files to split.
# @arg $3 <file_start> The starting file (inclusive) for the subset of files to process.
# @arg $4 <file_finnish> The ending file (inclusive) for the subset of files to process.
# @stdout Prints the split points (filenames) and the size of each split.
# @example get_split_files_partial 3 "${DOCU_PATH}/downloaded" "cloud.google.com-java-docs.html" "cloud.google.com-java-getting-started-session-handling-with-firestore.html"
function get_split_files_partial() {
    no_splits=$1
    path=$2
    file_start=$3
    file_finnish=$4

    html_size=$(du -sb "${path}/" | awk '{print $1}')

    mapfile -t files_array < <(
        find "${path}/" -type f -name "*.html" | sort -V | \
        sed -n "/$file_start/,/$file_finnish/p"
    )
    acumulated_size=0
    chunk_size=$((${html_size} / ${no_splits}))
    split_count=0

    for file in "${files_array[@]}"; do
        current_filesize=$(stat -c%s "${file}")
        acumulated_size=$((${acumulated_size} + ${current_filesize}))

        if [[ ${acumulated_size} -gt ${chunk_size} ]]; then
            split_count=$((${split_count} + 1))
            echo "Split no: ${split_count} split at file: ${file}"
            acumulated_size=0
            if [[ $((${split_count} + 1)) -eq ${no_splits} ]]; then
                break
            fi
        fi
    done
}

# @description Deletes files with duplicate headers in a directory structure.
# This function searches for files with the same header (extracted using the `.head-ltitle` CSS selector)
# and removes duplicates, keeping only one instance of each unique header.
# It is designed to work with a directory structure where files are organized in subdirectories.
#
# @arg $DOCU_PATH The base directory containing the files to process.
# @stdout Prints the paths of deleted files.
# @example delete_duplicate_header_files  # Removes duplicate files in ${DOCU_PATH}/downloaded/bookworm/
function delete_duplicate_header_files() {
    for dir in "$DOCU_PATH"/downloaded/bookworm/*/; do
        mapfile -td '' files < <(find "$dir" -type f -name '*' -print0)

        if (( "${#files[@]}" > 1 )); then
            for file in "${files[@]}"; do
                title=$(pup .head-ltitle < "$file")

                for fileb in "${files[@]}"; do
                    if [[ $file != "$fileb" ]]; then
                        if [[ $title == "$(pup .head-ltitle < "$fileb")" ]]; then
                            printf 'progname: Removing Duplicate: %s\n' "$fileb"
                            rm -f -- "$fileb"
                        fi
                    fi
                done
            done
        fi
    done
}

# @description A function to store codeblocks that are not used 
function unused_snippets() {
    rename -f "s/ /_/g" ${DOCU_PATH}/downloaded/**/*.*
    rename "s/\*/asterisk/g" ${DOCU_PATH}/downloaded/**/*.*

    # Removing non-exFAT compatible filename files
    #      not needed if index has --restrict-file-names=windows
    find ./ -type f -regex "\(.*\?.*\|.*\%.*\)" -exec rm {} \;



    ## Removing duplicates and other clutter
    find ${DOCU_PATH}/downloaded -not -path "${DOCU_PATH}/downloaded/bookworm/*" -delete
    find ${DOCU_PATH}/downloaded -type f -name 'index.html' -delete

    ## Removing other languages other than english
    find . -type f \( -name "*.html" ! -name "*en.html" \) -exec rm {} \;
    find ${DOCU_PATH}/downloaded -type f \( -name "*.html" ! -name "*en.html" \) -exec rm {} \;

}


## EOF EOF EOF Deprecated Functions 
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section Spidering Stage Utilities
# @description Standard Spidering Subroutines implemented across different documentations

# @description Performs an inte
# @stdout Return Description
# @example standard_spider -l 
function standard_spider() {

    ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')
    ## If there is an existing link-list, make a backup of it
    if [ -f "$CURRENT_DIR/../index-links/${ntfs_filename}.csv" ]; then
        echo "A previous link-list has been found, making a backup of the old-one" >&2
        cp "$CURRENT_DIR/../index-links/${ntfs_filename}.csv" "$CURRENT_DIR/../index-links/${ntfs_filename}-bk.csv"
    fi

    echo "Spidering a new link-list" >&2
    echo "This may take a while, and has to be done in one go" >&2
    echo "Consider doing this using a VPS ..." >&2


    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
      --force-html \
    `## Download Options` \
      --spider \
    `## Directory Options` \
      --no-directories \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
    `## HTTPS Options` \
      --no-check-certificate \
      --https-only \
    `## Recursive Retrieval Options` \
      --recursive --level=inf \
      --delete-after \
    `## Recursive Accept/Reject Options` \
      --reject-regex '.*?hel=.*|.*?hl=.*|.*[%&=?].*|\\\"' \
      --reject '*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.mp4,*.gif,*.webp,*.ico,*.woff,*.woff2,*.ttf,*.pdf,*.java,*.sql,*.jar,*.zip,*.GIF,*.PNG,*.svgz,*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.tar,*.pcap,*.pcapng,*.lua,*.msi,*.exe,*.gz,*.csl,*.text,*.tex' \
      "${DOWNLOAD_LINK}" 2>&1  \
        | grep '^--' | awk '{ print $3 }' | awk '{ print "\"" $0 "\",-1" }' > /dev/shm/${ntfs_filename}.csv

        cat /dev/shm/${ntfs_filename}.csv | sort -u > "$CURRENT_DIR/../index-links/${ntfs_filename}.csv"
        rm /dev/shm/${ntfs_filename}.csv

    # Compressing the file
    bzip2 "$CURRENT_DIR/../index-links/${ntfs_filename}.csv"


}

##      --accept '*.html,*.htm' \
##      --reject '*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.mp4,*.gif,*.webp,*.ico,*.woff,*.woff2,*.ttf,*.pdf,*.java,*.sql,*.jar,*.zip,*.GIF,*.PNG,*.svgz,*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.tar,*.pcap,*.pcapng,*.lua,*.msi,*.exe,*.gz,*.csl,*.text,*.tex' \


## EOF EOF EOF Spidering Stage Utilities 
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
# @section Indexing Stage Utilities
# @description Standard Indexing Subroutines implemented across different documentations


# @description download_fromlist Function Description
# Out of a <websiteLinks>.csv created from standard_spider()
#      Download each link
#          - Updating the .csv with status code
#          - Download it to DOCU_PATH/downloaded
# @option -l <DOWNLOAD_LINK> Option Description
# @stdout Return Description
# @example download_fromlist -l 
function download_fromlist() {
    ## PARSING FUNCTION ARGUMENTS ------------------------
    local OPTIND=1
    # Initialize variables
    DOWNLOAD_LINK=""

    while getopts "l:" opt; do
        case "${opt}" in
            a) DOWNLOAD_LINK="${OPTARG}" ;;
            *)
                echo "Usage: download_fromlist -l DOWNLOAD_LINK" >&2
                echo "Example: download_fromlist -l DOWNLOAD_LINK" >&2
                return 1
                ;;
        esac
    done
    # Variable check
    if [[ -z "${DOWNLOAD_LINK}" ]]; then
        echo "Error: download_fromlist requires -l DOWNLOAD_LINK" >&2
        return 1
    fi
    ## EOF EOF EOF PARSING FUNCTION ARGUMENTS -------------



}


# @description 
# Out of a <websiteLinks>.csv created from standard_spider()
#      Download each link
#          - Updating the .csv with status code
#          - Download it to DOCU_PATH/downloaded
# @stdout Return Description
# @example download_fromlist_waitretry 
function download_fromlist_waitretry() {
    DOWNLOAD_LINK=$1
    WAIT=$2
    WAIT_RETRY=$3
    START_ROW=${4:-1}  # Use $4 if provided, default to 1

    ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')

    ## Create downloaded directory if it doesn't exists
    [ ! -d "${DOCU_PATH}/downloaded" ] && mkdir -p "${DOCU_PATH}/downloaded"

    ## Check if a local csv has been copied, if not copy the one from the repository 
    LOCAL_CSV_PATH="${DOCU_PATH}/${ntfs_filename}.csv"
    if [ ! -f ${DOCU_PATH}/${ntfs_filename}.csv ]; then
        echo "No previous local csv has been found" >&2
        echo "Starting the index from the scratch ..." >&2
        bunzip2 -kc "$CURRENT_DIR/../index-links/${ntfs_filename}.csv.bz2" > "${LOCAL_CSV_PATH}"
#        cp "$CURRENT_DIR/../index-links/${ntfs_filename}.csv" "${LOCAL_CSV_PATH}"
    else
        echo "Resuming a previous download ..." >&2
    fi


    ## We are iterating through the .csv line by line
    total_lines=$(wc -l < ${LOCAL_CSV_PATH} ) 

    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59"


    ## Advance to the first ,0 found in the .csv
    # adjust START_ROW to the first line_no with a pending download ,-1 given an already existent START_ROW
#    START_ROW=$(awk -v start_row="${START_ROW}" 'NR >= start_row && /,(-1|[1-8])$/ { print NR; exit }' "${LOCAL_CSV_PATH}" )
    START_ROW=$(awk -v start_row="${START_ROW}" 'NR >= start_row && /,(-1|[1-5]|7)$/ { print NR; exit }' "${LOCAL_CSV_PATH}" )



    ## Set the starting row number, with a boundary check
    row_no=${START_ROW}

    while [ "$row_no" -le "$total_lines" ]; do
        row=$(sed -n "${row_no}p" "${LOCAL_CSV_PATH}" )  # Extract the specific row number $row_no

        ## Parsing url and exit_status
        url=$(echo "$row" | csvtool col 1 - | sed 's/^"\(.*\)"$/\1/')
        exit_status=$(echo "$row" | csvtool col 2 -)

        
        ## If the file hasnt been attempted to download yet
        if [ "$exit_status" -ne 0 ] && [ "$exit_status" -ne 8  ] && [ "$exit_status" -ne 6  ]; then 
#        if [ "$exit_status" -ne 0 ] && [ "$exit_status" -ne 6  ]; then 
# --execute robots=off --user-agent=${user_agent}
            dirpath=$(echo "$url" | sed 's|https://||;s|/[^/]*$||')
            filename=$(basename "$url")

            ## If the file doesnt exist locally
            if [ ! -f ${DOCU_PATH}/downloaded/${dirpath}/${url} ]; then
                wget -nc --adjust-extension --directory-prefix=${DOCU_PATH}/downloaded/${dirpath} ${url} > /dev/null 2>&1
                wget_status=${?}
            else ## File was already downloaded,update the wget_status
                echo "Found the file locally, despite not been in the list : ${url}" >&2
                wget_status="0"
            fi

            if [[ "$wget_status" -eq 4 || "$wget_status" -eq 8 ]]; then
                echo "Wget failed with Network (4) or Server Error (8)"
#                echo "There was a server error"
                echo "Cooling it down and retrying after the wait_retry : ${WAIT_RETRY}"
                sleep ${WAIT_RETRY} 
            fi

            if [ "$wget_status" -eq 0 ]; then
                sleep ${WAIT}
            fi

            ## Update in-place the row of the file with the new wget_status
            row="\"${url}\",${wget_status}"

            echo "Updated row : ${row}" >&2
            echo "Completed ${row_no} out of ${total_lines}" >&2

            sed -i "${row_no}c\\${row}" "${LOCAL_CSV_PATH}"
        fi
            ((row_no++))
    done



}



# @description
# Out of a <websiteLinks>.csv created from standard_spider()
#      Download each link
#          - Updating the .csv with status code
#          - Download it to DOCU_PATH/downloaded
# @stdout Return Description
# @example download_fromlist_waitretry_curl
function download_fromlist_waitretry_curl() {
    DOWNLOAD_LINK=$1
    WAIT=$2
    WAIT_RETRY=$3
    START_ROW=${4:-1}  # Use $4 if provided, default to 1

    ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')

    ## Create downloaded directory if it doesn't exists
    [ ! -d "${DOCU_PATH}/downloaded" ] && mkdir -p "${DOCU_PATH}/downloaded"

    ## Check if a local csv has been copied, if not copy the one from the repository
    LOCAL_CSV_PATH="${DOCU_PATH}/${ntfs_filename}.csv"
    if [ ! -f ${DOCU_PATH}/${ntfs_filename}.csv ]; then
        echo "No previous local csv has been found" >&2
        echo "Starting the index from the scratch ..." >&2
        bunzip2 -kc "$CURRENT_DIR/../index-links/${ntfs_filename}.csv.bz2" > "${LOCAL_CSV_PATH}"
#        cp "$CURRENT_DIR/../index-links/${ntfs_filename}.csv" "${LOCAL_CSV_PATH}"
    else
        echo "Resuming a previous download ..." >&2
    fi


    ## We are iterating through the .csv line by line
    total_lines=$(wc -l < ${LOCAL_CSV_PATH} )

    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59"


    ## Advance to the first ,0 found in the .csv
    # adjust START_ROW to the first line_no with a pending download ,-1 given an already existent START_ROW
#    START_ROW=$(awk -v start_row="${START_ROW}" 'NR >= start_row && /,(-1|[1-8])$/ { print NR; exit }' "${LOCAL_CSV_PATH}" )
    START_ROW=$(awk -v start_row="${START_ROW}" 'NR >= start_row && /,(-1|[1-5]|7)$/ { print NR; exit }' "${LOCAL_CSV_PATH}" )



    ## Set the starting row number, with a boundary check
    row_no=${START_ROW}

    while [ "$row_no" -le "$total_lines" ]; do
        row=$(sed -n "${row_no}p" "${LOCAL_CSV_PATH}" )  # Extract the specific row number $row_no

        ## Parsing url and exit_status
        url=$(echo "$row" | csvtool col 1 - | sed 's/^"\(.*\)"$/\1/')
        exit_status=$(echo "$row" | csvtool col 2 -)


        ## If the file hasnt been attempted to download yet
        if [ "$exit_status" -ne 0 ] && [ "$exit_status" -ne 8  ] && [ "$exit_status" -ne 6  ]; then
#        if [ "$exit_status" -ne 0 ] && [ "$exit_status" -ne 6  ]; then
            dirpath=$(echo "$url" | sed 's|https://||;s|/[^/]*$||')
            filename=$(basename "$url")

            curl -L --fail --create-dirs -o "${DOCU_PATH}/downloaded/${dirpath}/${filename}" "$url" > /dev/null 2>&1
            wget_status=${?}

            if [ "$wget_status" -eq 0 ]; then
                echo "Succesfull download, waiting...: ${url}"
                sleep ${WAIT}
            else
                echo "Curl detected some error"
                sleep ${WAIT_RETRY}
                echo "Cooling it down and retrying after the wait_retry : ${WAIT_RETRY}"
            fi


            ## Update in-place the row of the file with the new wget_status
            row="\"${url}\",${wget_status}"

            echo "Updated row : ${row}" >&2
            echo "Completed ${row_no} out of ${total_lines}" >&2

            sed -i "${row_no}c\\${row}" "${LOCAL_CSV_PATH}"
        fi
            ((row_no++))
    done



}



# @description standard_index Function Description
# @option -l <DOWNLOAD_LINK> Option Description
# @stdout Return Description
# @example standard_index -l 
function standard_index() {
    ## PARSING FUNCTION ARGUMENTS ------------------------
    local OPTIND=1
    # Initialize variables
    DOWNLOAD_LINK=""

    while getopts "l:" opt; do
        case "${opt}" in
            l) DOWNLOAD_LINK="${OPTARG}" ;;
            *)
                echo "Usage: standard_index -l DOWNLOAD_LINK" >&2
                echo "Example: standard_index -l DOWNLOAD_LINK" >&2
                return 1
                ;;
        esac
    done
    # Variable check
    if [[ -z "${DOWNLOAD_LINK}" ]]; then
        echo "Error: standard_index requires -l DOWNLOAD_LINK" >&2
        return 1
    fi
    ## EOF EOF EOF PARSING FUNCTION ARGUMENTS -------------

        wget \
        `##tBasic Startup Options` \
          --execute robots=off \
        `## Loggin and Input File Options` \
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
          --recursive --level=inf \
        `## Recursive Accept/Reject Options` \
          --no-parent \
          --reject '*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.mp4,*.gif,*.webp,*.ico,*.woff,*.woff2,*.ttf,*.pdf,*.java,*.sql,*.jar,*.zip,*.GIF,*.PNG,*.svgz,*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt,*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*.json,*.css,*.png,*.xml,*.txt' \
          --reject-regex '.*?hel=.*|.*?hl=.*|.*[%&=?].*|\\\"' \
          --page-requisites \
          ${DOWNLOAD_LINK}

}


## EOF EOF EOF Indexing Stage Utilities 
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section Arranging Stage Utilities
# @description Standard Arraging Subroutines shared across different documentations



## EOF EOF EOF Arranging Stage Utilities 
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section Parsing Stage Utilities
# @description Standard Parsing Subroutines shared across different documentations

prepocess_LinkSources() {
    ## PARSING FUNCTION ARGUMENTS ------------------------
    ## ---------------------------------------------------
    local OPTIND=1
    # Initialize variables
    DOCU_NAME=""
    BUID_CSV=""

    while getopts "a:z:z:z:z:z:z:z:z:z:z:z:z:z:" opt; do
        case "${opt}" in
            a) DOCU_NAME="${OPTARG}" ;;
            a) BUID_CSV="${OPTARG}" ;;
            *)
                echo "Usage: prepocess_LinkSources -a DOCU_NAME -z BUID_CSV" >&2
                echo "Example: prepocess_LinkSources -a DOCU_NAME -z BUID_CSV" >&2
                return 1
                ;;
        esac
    done
    # Variable check
    if [[ -z "${DOCU_NAME}" || -z "${BUID_CSV}" ]]; then
        echo "Error: prepocess_LinkSources requires -a DOCU_NAME -z BUID_CSV" >&2
        return 1
    fi
    ## PARSING FUNCTION ARGUMENTS ------------------------
    ## EOF EOF EOF EOF------------------------------------



}

# @description Write the TOC of the documentation
function write_toc() {

    # Create the link source toc header using figlet
    echo "TOC" | figlet >> "$MAIN_TOUPDATE"
    prev_dirs_array=()

    ## Splitting directories from filenames and building nested lists
    file_no=1
    for file in "${files_array[@]}"; do
        filename=$(echo ".${file#${DOCU_PATH}/downloaded}" | sed 's|^\.||')
        unset dirs_array
        remaining_file=$(echo "$filename" | sed 's|^/||')

        for ((i=0; i<25; i++)); do
            if [[ "$remaining_file" =~ ([^/]+)/(.+) ]]; then
                dirs_array[i]="${BASH_REMATCH[1]}"
                remaining_file="${BASH_REMATCH[2]}"
            else
                dirs_array[i]="$remaining_file"
                break
            fi
        done

        ## Compare current directory structure with the previous one to determine nesting
        for ((i=0; i<${#dirs_array[@]}; i++)); do
            if [ "${dirs_array[$i]}" != "${prev_dirs_array[$i]}" ]; then
                first_discrepancy_level=$i
                break
            fi
        done

        ## dirsy_array will have length 1 when file_nesting_level=0 etc.. , decrease it
        file_nesting_level=$((${#dirs_array[@]} - 1))

        ## Iterating through nested levels and formatting output with indentation
        for ((current_nesting_level=first_discrepancy_level; current_nesting_level<=file_nesting_level; current_nesting_level++)); do
            for ((i=0; i<current_nesting_level; i++)); do
                echo -ne "\t" >> "$MAIN_TOUPDATE"
            done

            if [[ $current_nesting_level -eq $file_nesting_level ]]; then
                unsanitized_title=$(echo ${paths_linkto[$file]} | sed -e 's/\\"/"/g' -e 's/\\\x27/\x27/g')
                echo "<L=$(decimal_to_alphanumeric ${file_no})>${unsanitized_title}</L>" >> "$MAIN_TOUPDATE"
            else
                echo -ne "- ${dirs_array[($current_nesting_level)]}\n" >> "$MAIN_TOUPDATE"
            fi
        done

        prev_dirs_array=("${dirs_array[@]}")
        file_no=$((file_no + 1))

    done



}


# @description Write the vim-dan generic header
function write_header() {
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from :" >> ${MAIN_TOUPDATE}
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        echo " - ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    done 
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}
}
    

function parse_html_docu_multirule() {
    ## PARSING FUNCTION ARGUMENTS ------------------------
    local title_parsing_array=()
    local content_parsing_array=()
    local pandoc_filters_array=()

    ## Parse options for title and body rules
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -f)
                if [[ -n "$2" ]]; then
                    title_parsing_array+=("$2")
                    shift 2
                else
                    echo "Error: Missing argument for -f" >&2
                    return 1
                fi
                ;;
            -b)
                if [[ -n "$2" ]]; then
                    content_parsing_array+=("$2")
                    shift 2
                else
                    echo "Error: Missing argument for -b" >&2
                    return 1
                fi
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done
    ## EOF EOF EOF PARSING FUNCTION ARGUMENTS -------------

    ## IMPLICIT DEPENDENCY CHECKS -------------------------
    if [[ -z "$DOCU_NAME" || -z "$DOCU_PATH"  ]]; then
        echo "Error: Missing a implicit dependency, {DOCU_NAME} or {DOCU_PATH}" >&2
        return 1
    fi
    ## ----------------------------------------------------

    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

    ## First create the title array
    title_array=()
    for file in "${files_array[@]}"; do
        # (Multi-rule) Parsing functions, add as many as needed
        found_selector=""
        for title_parsing in "${title_parsing_array[@]}"; do
            # Formulating command
            cmd="pup -i 0 --pre '${title_parsing}' | pandoc -f html -t plain --wrap=none"

            title=$(eval "$cmd" < "$file" \
                    | sed -e ':a;N;$!ba;s/\n/ /g' \
                    | sed -e 's/ ¶//g' \
                    | sed -e 's/¶//g' \
                    | sed -e "s/['\"]/\\\\\0/g" \
#                    | sed -e 's/\$/DollarSign/g' \
#                    | sed -e "s/'\''/SingleQuote/g" \
#                    | sed -e 's/(/OpenParen/g' \
#                    | sed -e 's/)/CloseParen/g' \
#                    | sed -e 's/;/SemiColon/g' \
#                    | sed -e 's/\*/Asterisk/g' \
            )
            if [ -n "$title" ]; then
                found_selector=true
                break
            fi
        done

        # Default case for parsing, if none of the rules return a non-zero string
        if [ -z "$found_selector" ]; then
            title=$(basename "$file" | sed 's/\.html$//' )
        fi

        # Append the title to the title_array
        title_array+=("$title")
    done

    ## Creating an associative array to map titles to file paths
    declare -A paths_linkto

    # Iterate through the indices of 'files_array'
    for index in "${!files_array[@]}"; do
        file="${files_array[$index]}"
        title="${title_array[$index]}"
        paths_linkto["$file"]="$title"
    done

    ## [LINKS-INDEXING] --------------------------------------------------
    file_no=1
    ## [LINKS-INDEXING] Placing header on links-target-index.csv
    links_index_csv="/dev/shm/${DOCU_NAME}-links-parsed.csv"

    ## A file to ensure that the selector has produced any output (has been found)
    content_dump_check=$(mktemp /dev/shm/vim-dan-content_dump_check-XXXXXX.dan)

    echo "rel_path,is_anchor,pandoc_data_type,label,anchor_id,buid,iid,in_use" > "${links_index_csv}"


    for file in "${files_array[@]}"; do

        filename="${file#${DOCU_PATH}/downloaded}"
#echo "[DEBUG] relative_path : ${relative_path}" ## DEBUGGING


        ## [LINKS-TARGET-INDEXING] Indexing all anchor links to links-target-index.csv
        for content_parsing in "${content_parsing_array[@]}"; do

        ## Sanitizing filenames
        # See: GitHub Issue #2 (https://github.com/rafmartom/vim-dan-generator/issues/2)
        ##sane_title=$(sed -e 's/\$/dollarSign/g' \
        ##        -e "s/'/SingleQuote/g" \
        ##        -e 's/\\(/OpenParen/g' \
        ##        -e 's/\\)/CloseParen/g' \
        ##        -e 's/;/SemiColon/g' \
        ##        <<<"${paths_linkto[$file]}")
        title=${paths_linkto[$file]}

            cmd=$(cat <<EOF
            sed 's/role="main"/role="maine"/g' | pup -i 0 --pre '${content_parsing}'\
            | pandoc -f html -t plain -o "${content_dump_check}" \
            -L $(realpath ${CURRENT_DIR}/../pandoc-filters/no-permalinks-writing.lua) \
            -L $(realpath ${CURRENT_DIR}/../pandoc-filters/indexing-links-target.lua) \
            -V file_processed="${filename}" -V links_index_csv=${links_index_csv} \
            -V parsed_title="${title}" -V file_no=${file_no}
 
EOF
)

            eval "$cmd" < "$file"

            ## Selector check break clausule
            if [ 1 -lt $(stat -c %s "${content_dump_check}") ]; then
                break
            fi
        done

    file_no=$((file_no + 1))
    done
    ## EOF EOF EOF [LINKS-INDEXING] ---------------------------------------

    ## [INUSE-LINKS-INDEXING] ------------------------------------------------------

    file_no=1
    ## Now need to populate the last column of the csv, in_use
    ## Before the writting stage we need to known what links (either source, and target)
    ## Are going to be used, so in the link targets and the link sources are formed accordingly
    ## Note : this step is necessary to be done previous to the writting, otherwise we could not
    ##      recognise what link target is in_use while writting it and cannot be putting a
    ##      link target in all the html elements with id
    for file in "${files_array[@]}"; do
        filename="${file#${DOCU_PATH}/downloaded}"

        for content_parsing in "${content_parsing_array[@]}"; do


            cmd=$(cat <<EOF
            sed 's/role="main"/role="maine"/g' | pup -i 0 --pre '${content_parsing}' \
            | pandoc -f html -t plain -o "${content_dump_check}" \
            -L $(realpath ${CURRENT_DIR}/../pandoc-filters/no-permalinks-writing.lua) \
            -L $(realpath ${CURRENT_DIR}/../pandoc-filters/inuse-links-indexing.lua) \
            -V docu_path=${DOCU_PATH} -V file_processed="${filename}" -V links_index_csv=${links_index_csv}
EOF
)


            eval "$cmd" < "$file"

            ## Selector check break clausule
            if [ 1 -lt $(stat -c %s "${content_dump_check}") ]; then
                break
            fi
        done
    file_no=$((file_no + 1))
    done
 ## EOF EOF EOF [INUSE-LINKS-INDEXING] ------------------------------------------
 ## Move the file from RAM memory to the disk

    mv "${links_index_csv}" "$CURRENT_DIR/../links-parsed/${DOCU_NAME}-links-parsed.csv"
    rm "${content_dump_check}"


}


# @description write_html_docu_multirule Function Description
# Similar as write_docu_multirule() but simplified, just to input html tags such as
#   write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body"
#  For understanding the code , there are not comments but just the added functionality ones
# from write_docu_multirule()
# It needs ${DOCU_NAME} to be setted
# It needs ${DOCU_PATH} to be setted
# @option -f <TITLE_SELECTOR>... Specify a title html selector (repeat -f to specify multiple posible selectors)
# @option -b <BODY_SELECTOR>... Specify a body html selector (repeat -b to specify multiple posible selectors)
# @option -L [PANDOC_FILTER] Add a pandoc filter (optional)
# @option -fm [FILE_MANGLING] Add some string manipulation commands to filter with the whole document afterwards (optional)
# @option -c [WRAP_COLUMNS] Inidicate no of columns for the output to be wrapped to (default non-wrap)
# @example 
#   write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body" -cp -fm "tail -n +6 
function write_html_docu_multirule() {
    ## PARSING FUNCTION ARGUMENTS ------------------------
    local title_parsing_array=()
    local content_parsing_array=()
    local pandoc_filters_array=()

    ## Parse options for title and body rules
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -f)
                if [[ -n "$2" ]]; then
                    title_parsing_array+=("$2")
                    shift 2
                else
                    echo "Error: Missing argument for -f" >&2
                    return 1
                fi
                ;;
            -b)
                if [[ -n "$2" ]]; then
                    content_parsing_array+=("$2")
                    shift 2
                else
                    echo "Error: Missing argument for -b" >&2
                    return 1
                fi
                ;;
            -L)
                if [[ -n "$2" ]]; then
                    pandoc_filters_array+=("$2")
                    shift 2
                fi
                ;;
            -cd)
                if [[ -n "$2" ]]; then
                    codeblock_default_filetype="$2"
                    shift 2
                else
                    echo "Error: Missing argument for -cd" >&2
                    return 1
                fi
                ;;
            -cp)
                codeblock_prompt=true
                shift
                ;;
            -il)
                inline_links=true
                shift
                ;;
            -n)
                if [[ -n "$2" ]]; then
                    DOCU_NAME="$2"
                    shift 2
                else
                    echo "Error: Missing argument for -n" >&2
                    return 1
                fi
                ;;
            -p)
                if [[ -n "$2" ]]; then
                    DOCU_PATH="$2"
                    shift 2
                else
                    echo "Error: Missing argument for -p" >&2
                    return 1
                fi
                ;;
            -fm)
                if [[ -n "$2" ]]; then
                    file_mangling="$2"
                    shift 2
                else
                    echo "Error: Missing argument for -fm" >&2
                    return 1
                fi
                ;;
            -c)  # New option for columns
                if [[ -n "$2" ]]; then
                    wrap_columns="$2"
                    shift 2
                else
                    echo "Error: Missing argument for -c" >&2
                    return 1
                fi
                ;;
            -cc)
                if [[ -n "$2" ]]; then
                    cleanup_command="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done
    ## EOF EOF EOF PARSING FUNCTION ARGUMENTS -------------

    ## IMPLICIT DEPENDENCY CHECKS -------------------------
    if [[ -z "$DOCU_NAME" || -z "$DOCU_PATH"  ]]; then
        echo "Error: Missing a implicit dependency, {DOCU_NAME} or {DOCU_PATH}" >&2
        return 1
    fi
    ## ----------------------------------------------------

    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

    ## First create the title array
    title_array=()
    for file in "${files_array[@]}"; do
        # (Multi-rule) Parsing functions, add as many as needed
        found_selector=""
        for title_parsing in "${title_parsing_array[@]}"; do
            # Formulating command
            cmd="pup -i 0 --pre '${title_parsing}' | pandoc -f html -t plain --wrap=none"

            title=$(eval "$cmd" < "$file" \
                    | sed -e ':a;N;$!ba;s/\n/ /g' \
                    | sed -e 's/ ¶//g' \
                    | sed -e 's/¶//g' \
                    | sed -e "s/['\"]/\\\\\0/g" \
#                    | sed -e 's/\$/DollarSign/g' \
#                    | sed -e "s/'\''/SingleQuote/g" \
#                    | sed -e 's/(/OpenParen/g' \
#                    | sed -e 's/)/CloseParen/g' \
#                    | sed -e 's/;/SemiColon/g' \
#                    | sed -e 's/\*/Asterisk/g' \
            )
            if [ -n "$title" ]; then
                found_selector=true
                break
            fi
        done

        # Default case for parsing, if none of the rules return a non-zero string
        if [ -z "$found_selector" ]; then
            title=$(basename "$file" | sed 's/\.html$//' )
        fi

        # Append the title to the title_array
        title_array+=("$title")

    done

    ## Creating an associative array to map titles to file paths
    declare -A paths_linkto

    # Iterate through the indices of 'files_array'
    for index in "${!files_array[@]}"; do
        file="${files_array[$index]}"
        title="${title_array[$index]}"
        paths_linkto["$file"]="$title"
    done


    ## Checking for existence of links_index_csv
    links_index_csv="$(realpath "$CURRENT_DIR/../links-parsed/${DOCU_NAME}-links-parsed.csv")"
    if [ ! -f "${links_index_csv}" ]; then
        echo "${links_index_csv} hasn't been found, please perform parse" >&2
        exit 1        
    fi
    

    if [ -f "${MAIN_TOUPDATE}" ]; then
        echo "A previous ${MAIN_TOUPDATE} has been found, doing checks to resume previous writting" >&2

            if  result=($(get_writting_toupdate )); then
                file="${result[0]}"
                buid="${result[1]}"
                line_no="${result[2]}"

                # Delete until line_no to end of file
                head -n "$((line_no - 1))" "$MAIN_TOUPDATE" > /tmp/temp-vim-dan.dan && mv /tmp/temp-vim-dan.dan "$MAIN_TOUPDATE"
            else
                write_toc
            fi
    else
        # If it didnt find the file remove any pending tag file may be
        [[ -f ${VIMDAN_DIR}/.tags${DOCU_NAME}  ]] && rm -r ${VIMDAN_DIR}/.tags${DOCU_NAME}

        write_header
        echo "" >> "$MAIN_TOUPDATE"  ## Adding a line break
        write_toc
    fi


    ## Initiating variables for codeblock_prompt
    if [[ "$codeblock_prompt" == true ]]; then
        scr_choice_1=$(mktemp /dev/shm/scr_choice_1.XXXXXX)
        scr_choice_2=$(mktemp /dev/shm/scr_choice_2.XXXXXX)
        scr_choice_3=$(mktemp /dev/shm/scr_choice_3.XXXXXX)
        csv_path="$CURRENT_DIR/../ext-csv/${DOCU_NAME}.csv"
        [ ! -f "$csv_path" ] && mkdir -p "$(dirname "$csv_path")"
        scr_global_current_cb=$(mktemp /dev/shm/scr_global_current_cb.XXXXXX)
        scr_csv_iterator_needs_catchup=$(mktemp /dev/shm/scr_csv_iterator_needs_catchup.XXXXXX)
    fi

    ## Checking for a resumed writting
    if [[ -n "$buid" ]]; then
        file_no=$(alphanumeric_to_decimal ${buid})
        found_file=false
    else
        file_no=1
        found_file=true
    fi 

    content_dump_nohead=$(mktemp /dev/shm/vim-dan-content_dump_nohead-XXXXXX.dan)
    content_dump=$(mktemp /dev/shm/vim-dan-content_dump-XXXXXX.dan)


    ## Parsing and appending content, using Multi-rule
    for path in "${files_array[@]}"; do

        filename=$(echo "${path#${DOCU_PATH}/downloaded}")
        file=$(echo $file | sed 's|^\.||')


        if [[ -n "$file" && $found_file == false ]]; then
            if [[ "$filename" == "$file" ]]; then
                found_file=true
            else
                continue  # skip until we find the match
            fi

        fi



        # Generating buid sequencially
        buid=$(decimal_to_alphanumeric ${file_no})
        # @todo Checking buid against target-links-index.csv


# Create content in a variable
content=$(
    printf '%s\n' "$(for ((i=1; i<=${wrap_columns:-80}; i++)); do printf '='; done)"
    echo "<B="${buid}">${paths_linkto[$path]}"
    echo "&${paths_linkto[$path]}&"
    echo "${paths_linkto[$path]}" | figlet
)


echo "$content" >> "${content_dump}"


        found_selector=""

        for content_parsing in "${content_parsing_array[@]}"; do
            # Create content parsing array


            # Formulating command
            # Initial cmd
            


            cmd=$(cat <<EOF
            sed 's/role="main"/role="maine"/g' | pup -i 0 --pre '${content_parsing}' \
            | pandoc -f html -t plain -o ${content_dump_nohead} \
            -L $(realpath ${CURRENT_DIR}/../pandoc-filters/no-permalinks-writing.lua) \
            -V file_processed="${filename}" -V file_no="${file_no}"
EOF
)


            if [[ -n "$wrap_columns" ]]; then
                cmd+=" --columns=${wrap_columns}"
            else 
                cmd+=" --wrap=none"
            fi

            ## Adding codeblock_prompt
            [[ "$codeblock_prompt" == true ]] && cmd+=" -V scr_choice_1=${scr_choice_1} -V scr_choice_2=${scr_choice_2} -V scr_choice_3=${scr_choice_3} -V csv_path=${csv_path} -V scr_global_current_cb=${scr_global_current_cb} -V scr_csv_iterator_needs_catchup=${scr_csv_iterator_needs_catchup} -L $(realpath ${CURRENT_DIR}/../pandoc-filters/codeblock-prompt.lua)"


            ## Adding codeblock_default_filetype (shouldn't be used with codeblock_prompt)
            [[ -n "$codeblock_default_filetype" ]] && cmd+=" -V codeblock_default_filetype=${codeblock_default_filetype} -L $(realpath ${CURRENT_DIR}/../pandoc-filters/codeblock-default.lua)"


            ## Adding inline_links filter
            [[ "$inline_links" == true ]] && cmd+=" -V links_index_csv=${links_index_csv} -L $(realpath ${CURRENT_DIR}/../pandoc-filters/inline-links-writing.lua)"


            ## Adding the custom pandoc filters
            if [[ ${#pandoc_filters_array[@]} -gt 0 ]]; then
                for pandoc_filter in "${pandoc_filters_array[@]}"; do
                    cmd+=" -L ${pandoc_filter}"
                done
            fi

            eval "$cmd" < "$path"



            if [ 1 -lt $(stat -c %s "${content_dump_nohead}") ]; then

                eval "cat ${content_dump_nohead} | ${file_mangling} >> ${content_dump_nohead}"

                found_selector=true
                break
            fi

        done

        # Default case for parsing , if none of the rules return a non-zero string
        if [ -z "$found_selector" ]; then
            cmd="pandoc -f html -t plain"
            if [[ -n "$wrap_columns" ]]; then
                cmd+=" --columns=${wrap_columns}"
            else 
                cmd+=" --wrap=none"
            fi
            [[ -n "$file_mangling" ]] && cmd+=" | ${file_mangling}"
            eval "cat ${path} | ${cmd} >> ${content_dump_nohead}"
        fi

        echo "</B>" >> "${content_dump_nohead}"                        ## ADDING A LINE BREAK


        cat "${content_dump_nohead}" >> "${content_dump}"

        [[ -n "$cleanup_command" ]] && eval "$cleanup_command"


        # TUCKING IN THE IN-LINE LINKS AS MUCH AS POSSIBLE
        awk -f "$CURRENT_DIR"/../scripts/append-inline-links-prev.awk "${content_dump}" > /tmp/${DOCU_NAME}-tmp && mv /tmp/${DOCU_NAME}-tmp "${content_dump}"

        for ((i=1; i<=5; i++)); do
            awk -f "$CURRENT_DIR"/../scripts/pile-consecutive-inline-links.awk "${content_dump}" > /tmp/${DOCU_NAME}-tmp && mv /tmp/${DOCU_NAME}-tmp "${content_dump}"
        done

        ctags --options=NONE \
              --options=${CURRENT_DIR}/../ctags-rules/dan.ctags \
              --sort=no \
              --append=yes \
              --tag-relative=no \
              -f ${VIMDAN_DIR}/.tags${DOCU_NAME} \
              ${content_dump}

        # tail -n +$((no_empty_lines + 1)) ${content_dump} >> "${MAIN_TOUPDATE}"
        cat ${content_dump} >> "${MAIN_TOUPDATE}"
        truncate -s 0 "$content_dump_nohead"
        truncate -s 0 "$content_dump"


        file_no=$((file_no + 1))
    done


    ## Removing files used in RAM Memory
    rm -f "$scr_choice_1" "$scr_choice_2" "$scr_choice_3" \
      "$scr_global_current_cb" "$scr_csv_iterator_needs_catchup" "$content_dump"

    ## Cleaning tags file

    ## Deleting the header lines that are not leading lines
    sed -i '27,$ {/^!_/d}' ${VIMDAN_DIR}/.tags${DOCU_NAME}
    ## Ammending filename on tags file
    sed -i "s|${content_dump}|${DOCU_NAME}.dan|" ${VIMDAN_DIR}/.tags${DOCU_NAME}
    ## Cleaning duplicates of nested tags
##    sed -i -E '/^[a-zA-Z0-9]+\t.*\tregex:[a-zA-Z0-9]+$/d' ${VIMDAN_DIR}/.tags${DOCU_NAME}
#    sort -fV ${VIMDAN_DIR}/.tags${DOCU_NAME} -o ${VIMDAN_DIR}/.tags${DOCU_NAME}
#    sort -u ${VIMDAN_DIR}/.tags${DOCU_NAME} -o ${VIMDAN_DIR}/.tags${DOCU_NAME}
    sort -k1,1 -u ${VIMDAN_DIR}/.tags${DOCU_NAME} -o ${VIMDAN_DIR}/.tags${DOCU_NAME}



    tags_header=$(mktemp /dev/shm/vim-dan-tags_header-XXXXXX.dan)
    tags_body=$(mktemp /dev/shm/vim-dan-tags_body-XXXXXX.dan)

    # Extract tag headers
    grep '^!_TAG_' ${VIMDAN_DIR}/.tags${DOCU_NAME} > ${tags_header}

    # Extract tag entries (excluding tag headers)
    sed '/^!_TAG_/d' ${VIMDAN_DIR}/.tags${DOCU_NAME} > ${tags_body}

    # Combine
    cat ${tags_header} ${tags_body} > ${VIMDAN_DIR}/.tags${DOCU_NAME} && rm ${tags_header} ${tags_body}

    # Correct the tags file so to accept (X)

pattern=$(cat << 'EOF'
s/\$\/;"/\\( (X)\\)\\?\$\/;"/
EOF
)

    sed -i "${pattern}" ${VIMDAN_DIR}/.tags${DOCU_NAME}


}


# @description Create a dan modeline for the different syntaxes that show in the file
function write_ext_modeline() {
    ## Gathering different syntax blocks in the file
    mapfile -t ext_array < <(grep -o -P '^```(\w+)$' ${MAIN_TOUPDATE} | sed 's/^```//' | sort | uniq -c | sort -nr | awk '{print $2}' )

    ext_string=$(IFS=, ; echo "${ext_array[*]}")

    ## Preparing the vim modeline
    modeline="&@ g:dan_ext_list = \"$ext_string\" @&"

    ## Prepending the modeline to the document
    sed -i "11i ${modeline}" ${MAIN_TOUPDATE}
}

## EOF EOF EOF Parsing Stage Utilities 
## ----------------------------------------------------------------------------
