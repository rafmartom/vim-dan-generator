#!/bin/bash 
# @file git-lfs
# @brief vim-dan ruleset file for documentation on git-lfs
# @description
#   author: rafmartom <rafmartom@gmail.com>


## ----------------------------------------------------------------------------
# @section SCRIPT_VAR_INITIALIZATION

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOWNLOAD_LINKS=(
)

## EOF EOF EOF SCRIPT_VAR_INITIALIZATION 
## ----------------------------------------------------------------------------




## ----------------------------------------------------------------------------
# @section ACTION_DEFINITION
# @description Ruleset for each individual stage of vim-dan

spidering_rules(){

    echo "No spidering in this documentation.Jump to indexing"

}


filtering_rules() {

    echo "No filtering in this documentation.Jump to indexing"

}

indexing_rules(){

    git clone https://github.com/git-lfs/git-lfs ${DOCU_PATH}/downloaded/git-lfs

}

arranging_rules(){

    # DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------
    # Add below statments regarding to arranging_rules that are specific for this documentation

    # Example, you want to remove the blog section that has been indexed
    # rm -r ${DOCU_PATH}/downloaded/blog

    # If there is only one DOWNLOAD_LINK , (so one hostname), unnest the files

    #find "${DOCU_PATH}/downloaded" -mindepth 1 -not -path "${DOCU_PATH}/downloaded/docs/man" -not -path "${DOCU_PATH}/downloaded/docs/man/*" -exec rm -rf {} +
    mv "${DOCU_PATH}/downloaded/git-lfs/docs/man" "${DOCU_PATH}/downloaded"
    rm -rf "${DOCU_PATH}/downloaded/git-lfs" 

    # EOF EOF EOF DOCUMENTATION SPECIFIC RULES
    # ---------------------------------------------------------------------------


    ## Files cleanup

    ## Clean up the duplicate files
    # Keeping the least nested one
   # jdupes -r -N -d ${DOCU_PATH}/downloaded/


    ## Modifying documents
}


parsing_rules(){

    echo "No Parsing in this Documentation"

}

writting_rules(){

    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.adoc" | sort -V)

    ## First create the title array
    title_array=()
    for file in "${files_array[@]}"; do
        title=$(basename "$file" | sed 's/\.adoc$//' )
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


    write_header
    echo "" >> "$MAIN_TOUPDATE"  ## Adding a line break
    write_toc



    content_dump=$(mktemp /dev/shm/vim-dan-content_dump-XXXXXX.dan)

    file_no=1

    for path in "${files_array[@]}"; do

        filename=$(echo "${path#${DOCU_PATH}/downloaded}")
        file=$(echo $file | sed 's|^\.||')


        buid=$(decimal_to_alphanumeric ${file_no})



    content=$(
        printf '%s\n' "$(for ((i=1; i<=${wrap_columns:-80}; i++)); do printf '='; done)"
        echo "<B="${buid}">${paths_linkto[$path]}"
        echo "& ${paths_linkto[$path]} &"
        echo "${paths_linkto[$path]}" | figlet
    )


    echo "$content" > "${content_dump}"

    asciidoctor -b docbook5 -o - "$path" | pandoc -f docbook -t plain >> "${content_dump}"

    echo "</B>" >> "${content_dump}"

    ## Cleanup Command
    tr -cd '[:print:]\t\n ' < "${content_dump}" > "${content_dump}.new"

    if [[ -s "${content_dump}".new ]]; then
        mv -f -- "${content_dump}".new "${content_dump}";
    fi
    ## EOF EOF cleanup command


    ctags --options=NONE \
          --options=${CURRENT_DIR}/../ctags-rules/dan.ctags \
          --sort=no \
          --append=yes \
          --tag-relative=no \
          -f ${VIMDAN_DIR}/.tags${DOCU_NAME} \
              ${content_dump}
        
    cat ${content_dump} >> "${MAIN_TOUPDATE}"
    file_no=$((file_no + 1))


    done

    ## Cleaning tags file

    ## Deleting the header lines that are not leading lines
    sed -i '27,$ {/^!_/d}' ${VIMDAN_DIR}/.tags${DOCU_NAME}
    ## Ammending filename on tags file
    sed -i "s|${content_dump}|${DOCU_NAME}.dan|" ${VIMDAN_DIR}/.tags${DOCU_NAME}
    ## Cleaning duplicates of nested tags
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
