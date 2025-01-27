#!/bin/bash


## USER TRIGGERED ACTIONS
## ------------------------------------
perform_install(){
    [ ! -d "${DOCU_PATH}" ] && mkdir -p "${DOCU_PATH}"
    echo "Installing vim-dan ${DOCU_NAME} into ${DOCU_PATH}/ ..."

    # If installation directory doesnt exist create
    if [ -e "$DOCU_PATH" ]; then
        mkdir -p $DOCU_PATH
    fi

    # If the file is compressed extract
    if [ -e "$CURRENT_DIR"/ready-docus/main."${DOCU_NAME}dan.bz2" ]; then
        echo "There is compression file"
        bunzip2 -kc "$CURRENT_DIR"/ready-docus/main."${DOCU_NAME}dan.bz2" > ${DOCU_PATH}/main-toupdate.${DOCU_NAME}dan
    else 
        cp $CURRENT_DIR/ready-docus/main.${DOCU_NAME}dan ${DOCU_PATH}/main-toupdate.${DOCU_NAME}dan
    fi
    perform_patch
    updating_tags
    updating_vim
    install_autoload
}
perform_update(){
    echo "Updating vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    echo "Note!! . In order for this to have any effect you previously should have updated the repository"
    cp $CURRENT_DIR/ready-docus/${DOCU_NAME}.dan ${DOCU_PATH}/${DOCU_NAME}-toupdate.dan
    perform_patch
    updating_tags
    updating_vim
    install_autoload
}

perform_index(){
    echo "Indexing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh ${DOCU_PATH} "-i"
}

perform_parse(){
    echo "Parsing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh ${DOCU_PATH} "-p"
    perform_patch
    updating_tags
    updating_vim
    install_autoload
}

perform_arrange(){
    echo "Arranging vim-dan ${DOCU_NAME} files on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/documentations/${DOCU_NAME}.sh ${DOCU_PATH} "-a"
}

perform_remove(){
    echo "Removing vim-dan ${DOCU_NAME} off ${DOCU_PATH}/ ..."
    rm -r ${DOCU_PATH}
    rm ${VIM_RTP_DIR}/ftdetect/dan.vim 
    rm ${VIM_RTP_DIR}/after/ftplugin/dan.vim 
    rm ${VIM_RTP_DIR}/syntax/dan.vim 
    rm ${VIM_RTP_DIR}/autoload/dan.vim 
}
delete_index() {
    echo "Deleting previous Index ..."
    rm -r ${DOCU_PATH}/downloaded
}
install_autoload() {
    if [ ! -f ${VIM_RTP_DIR}/autoload/dan.vim ]; then
        echo "Installing autoload ..."
        [ ! -d ${VIM_RTP_DIR}/autoload ] && mkdir -p ${VIM_RTP_DIR}/autoload 
        cp ${CURRENT_DIR}/autoload/dan.vim ${VIM_RTP_DIR}/autoload/
    fi
}
## EOF EOF EOFF USER TRIGGERED ACTIONS
## ------------------------------------


## AUTOMATIC ACTIONS
## ------------------------------------
perform_patch(){
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

updating_tags() {
    echo "Updating the tag file..."
    ctags --options=NONE --options=${CURRENT_DIR}/ctags-rules/dan.ctags --tag-relative=always -f ${DOCU_PATH}/tags ${MAIN_FILE} 
    [ ! -d "${HOME}/.ctags.d" ] && mkdir -p "${HOME}/.ctags.d"
    cp ${CURRENT_DIR}/ctags-rules/dan.ctags ${HOME}/.ctags.d/
}
updating_vim() {
    echo "Updating vim files..."
    [ ! -d "${VIM_RTP_DIR}/ftdetect" ] && mkdir -p "${VIM_RTP_DIR}/ftdetect"
    cp ${CURRENT_DIR}/ft-detection/dan.vim  ${VIM_RTP_DIR}/ftdetect/
    [ ! -d "${VIM_RTP_DIR}/after/ftplugin" ] && mkdir -p "${VIM_RTP_DIR}/after/ftplugin"
    cp ${CURRENT_DIR}/linking-rules/dan.vim ${VIM_RTP_DIR}/after/ftplugin/dan.vim
    [ ! -d "${VIM_RTP_DIR}/syntax" ] && mkdir -p "${VIM_RTP_DIR}/syntax"
    cp ${CURRENT_DIR}/syntax-rules/dan.vim  ${VIM_RTP_DIR}/syntax/
}
## EOF EOF EOF AUTOMATIC ACTIONS
## ------------------------------------




## FUNCTIONS TO BE USED ON ARRANGING STAGE
## ------------------------------------

function rename_lone_index () {
    ## Rename lone index.html to subdir folder and place this file a level down
    ## For instance
    ## www.zaproxy.org/docs/alerts/
    ## www.zaproxy.org/docs/alerts/0/index.html
    ## should become
    ## www.zaproxy.org/docs/alerts/0.html


    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/" -type f -name "index.html")
    for file in "${files_array[@]}"; do
        parent="$(basename "$(dirname ${file})")"
        dirname=$(dirname ${file})
        ext=${file##*.}
        mv ${file} "$dirname/../$parent.$ext";
    done
}

function deestructuring_dir_tree() {
    ## Search on a dir, place the files nested in a subdir, on the dir below
    ## Rename them to ${subdir}file.ext

    ## For instance check in
    ## www.zaproxy.org/docs/desktop/addons/
    ##
    ## there is gonna be files such as
    ## www.zaproxy.org/docs/desktop/addons/access-control-testing/contextoptions.html
    ##
    ## make it
    ## www.zaproxy.org/docs/desktop/addons/access-control-testing-contextoptions.html



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

## EOF EOF EOF FUNCTIONS TO BE USED ON ARRANGING STAGE
## ------------------------------------





## FUNCTIONS TO BE USED ON INDEXING/PARSING
## ------------------------------------
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


set -x
echo "content_parsing : ${content_parsing}" >&2 ## DEBUGGING

        eval "$content_parsing" < "$path" > "$content_dump"
set +x
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


function write_html_docu_multirule() {
    ## Similar as write_docu_multirule() but simplified, just to input html tags such as
    #   write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body"

    ## For understanding the code , there are not comments but just the added functionality ones
    # from write_docu_multirule()
    # 
    # Example of usage
    #
    # write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body" -cp


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
      -w)
        wrap_on=true
        shift
        ;;
      -cp)
        codeblock_prompt=true
        shift
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

  ## First create the title array
  title_array=()
  for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions, add as many as needed
    found_selector=""
    for title_parsing in "${title_parsing_array[@]}"; do
      # Formulating command
      cmd="pup -i 0 --pre '${title_parsing}' | pandoc -f html -t plain --wrap=none"

      title=$(eval "$cmd" < "$file" | sed ':a;N;$!ba;s/\n/ /g')
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



    ## Initiating variables for codeblock_prompt
    if [[ "$codeblock_prompt" == true ]]; then
        scr_choice_1=$(mktemp)
        scr_choice_2=$(mktemp)
        scr_choice_3=$(mktemp)
        csv_path="$CURRENT_DIR/../ext-csv/${DOCU_NAME}.csv"
        [ ! -f "$csv_path" ] && mkdir -p "$(dirname "$csv_path")"
        scr_global_current_cb=$(mktemp)
        scr_csv_iterator_needs_catchup=$(mktemp)
    fi


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




        # Formulating command
    
        # Initial cmd
        cmd="pup -i 0 --pre '${content_parsing}' | pandoc -f html -t plain -o ${content_dump}"


        ## Adding wrap_option
        wrap_option=" --wrap=none"  # Default to no wrapping
        [[ "$wrap_on" == true ]] && wrap_option=" --wrap=auto"
        cmd+="${wrap_option}"


        ## Adding codeblock_prompt
        [[ "$codeblock_prompt" == true ]] && cmd+=" -V scr_choice_1=${scr_choice_1} -V scr_choice_2=${scr_choice_2} -V scr_choice_3=${scr_choice_3} -V csv_path=${csv_path} -V scr_global_current_cb=${scr_global_current_cb} -V file_processed=\"${filename}\" -V scr_csv_iterator_needs_catchup=${scr_csv_iterator_needs_catchup} -L $(realpath ${CURRENT_DIR}/../pandoc-filters/codeblock-prompt.lua)"


        
        ## Adding the custom pandoc filters
        if [[ ${#pandoc_filters_array[@]} -gt 0 ]]; then
            for pandoc_filter in "${pandoc_filters_array[@]}"; do
#                cmd+="-L \"$(realpath \"${CURRENT_DIR}/../pandoc-filters/${pandoc_filter}\")\""
                cmd+=" -L ${pandoc_filter}"
            done
        fi

        eval "$cmd" < "$path"

        if [ 1 -lt $(stat -c %s "${content_dump}") ]; then
            cat ${content_dump} >> "${MAIN_TOUPDATE}"
            break
        fi


        # Default case for parsing , if none of the rules return a non-zero string
        if [ -z "$found_selector" ]; then
           cat ${path} | pandoc -f html -t plain >> "${MAIN_TOUPDATE}"
        fi

    done

    echo "" >> "${MAIN_TOUPDATE}"                        ## ADDING A LINE BREAK
    printf '%s\n' "$(printf '%.0s-' {1..80})" >> "${MAIN_TOUPDATE}"
    printf '%s\n' "$(printf '%.0sX' {1..80})" >> "${MAIN_TOUPDATE}"
    printf '%s\n' "$(printf '%.0s-' {1..80})" >> "${MAIN_TOUPDATE}"

    rm "$content_dump"


  done
}


write_ext_modeline() {
    ## Gathering different syntax blocks in the file
    mapfile -t ext_array < <(grep -o -P '^```(\w+)$' ${MAIN_TOUPDATE} | sed 's/^```//' | sort | uniq -c | sort -nr | awk '{print $2}' )

    ext_string=$(IFS=, ; echo "${ext_array[*]}")

    ## Preparing the vim modeline
    modeline="&@ g:dan_ext_list = \"$ext_string\" @&"

    ## Prepending the modeline to the document
    sed -i "11i ${modeline}" ${MAIN_TOUPDATE}
}


function getItemsNLevelDir() {
# This function will print out all the files that are N Levels below a certain
#   Subdirectory
#           - items: (f for files, d for directories , man find)
#           - level: Int, How many levels below you want to check
#           - directory : subdirectory to check, must be found below the current
#                           path. Just a string with the directory name no "/"
#           - recursion : it will check for items on all the subdirectories b
#                           below
#           i.e:  getItemsNLevelDir "f" "1" "Global_Objects" "no"   will 
#                   List all the direct children files of Global_Objects subdir
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

find_same_name_sibling_directory() {
# For a certain extension, it gives you the file path of the ones that have
#   a sibling folder of the same name
#       i.e: find_same_name_sibling_directory '.' 'html'
    local dir="$1"
    local ext="$2"
    # Find all .EXT files in the directory
    ext_files=$(find "$dir" -maxdepth 1 -type f -name "*.${ext}" -printf "%f\n")
    
    # Loop through EXT files
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
## EOF EOF EOF FUNCTIONS TO BE USED ON INDEXING/PARSING
## ------------------------------------



estimate_docu_weight() {
## Data for indexing, estimating bytes per file
#--------------------
# There are two methods to estimate the aproximated bytes of the documentation.
#   - calculate an html to plaintext ratio , multiply it by number of files
#   - calculate a html_headroom for one file (so the HTML boiler plate
#       that is gonna appear always in each files.
#       The rest should be pure plain text.
#       Get this headroom for the number of files (total_headroom)
#       and substract it to the total size in html
#   Both methods are wrong, it is best the firstone

## Number below may not be representative due to disparity of text on files


mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

# Get plaintext size
plaintext_size=$(cat "${files_array[0]}" | pup -i 0 --pre 'article div.devsite-article-body' | pandoc -f html -t plain --wrap=none | wc -c)

# Get HTML file size
html_size=$(stat -c%s "${files_array[0]}")

html_headroom=$((${html_size} - ${plaintext_size}))

echo "HTML headroom: ${html_headroom}"

# get the total number of html files
num_files=$(find "${DOCU_PATH}/downloaded" -maxdepth 1 -type f -name "*.html" | wc -l)

echo "number of html files: ${num_files}"

total_headroom=$((${html_headroom} * ${num_files}))
echo "Total Headroom: ${total_headroom}"

html_size=$(du -sb "${DOCU_PATH}/downloaded" | awk '{print $1}')
echo "html size: ${html_size}"

bytes_total_docu=$((${html_size} - ${total_headroom}))

#$(echo "scale=2; $total_html_size * $plaintext_html_ratio" | bc)


### Calculate the plaintext-to-HTML size ratio (use bc for float division)
##plaintext_html_ratio=$(echo "scale=4; $plaintext_size / $html_size" | bc)
##
##echo ${plaintext_html_ratio}
##echo "Plaintext to HTML ratio: ${plaintext_html_ratio}"

### get the total number of html files
##num_files=$(find "${docu_path}/downloaded" -maxdepth 1 -type f -name "*.html" | wc -l)
##
##echo "number of html files: ${num_files}"
##
### Estimate total plaintext size across all HTML files
##total_html_size=$(find "${DOCU_PATH}/downloaded" -maxdepth 1 -type f -name "*.html" -exec stat -c%s {} + | awk '{s+=$1} END {print s}')

# Estimate total plaintext size across all files
#bytes_total_docu=$(echo "scale=2; $total_html_size * $plaintext_html_ratio" | bc)
# Convert total plaintext bytes to megabytes
bytes_total_docu_mb=$(echo "scale=2; $bytes_total_docu / 1048576" | bc)

echo "Total documentation bytes (estimated plaintext): ${bytes_total_docu} bytes"
echo "Total documentation size (estimated plaintext) in MB: ${bytes_total_docu_mb} MB"
}



## Splitting documentation in different parts of even size
##
## This algorithm will give me the filename for the splits of even size
## and the size of each split , for a certain number of splits given

## We will be assuming that the documentation is sorted and is
## gonna be parsed sorted alphabetically

get_split_files(){

no_splits=$1
path=$2

html_size=$(du -sb "${path}/" | awk '{print $1}')

mapfile -t files_array < <(find "${path}/" -type f -name "*.html" | sort -V )
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

#get_split_files 3 "${DOCU_PATH}/downloaded" ""




# Similar to previousone , but we will truncate the find to 
# file_start
# file_finnish
get_split_files_partial(){

no_splits=$1
path=$2
file_start=$3
file_finnish=$3

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


#get_split_files 3 "${DOCU_PATH}/downloaded" "${DOCU_PATH}/downloaded/cloud.google.com-)java-)docs.html" "${DOCU_PATH}/downloaded/cloud.google.com-)java-)getting-started-)session-handling-with-firestore.html"



# Snippets functions not to be executed !!
# They are just snippets used on the codebase
indexing_snippets() {
    echo 'Function not to execute' # Dont delete this line



}

arranging_snippets() {
    echo 'Function not to execute' # Dont delete this line

## Making a backup
cp -r "${DOCU_PATH}/downloaded" "${DOCU_PATH}/downloaded-bk"

## Moving down the host directory
mv "${DOCU_PATH}/downloaded/cloud.google.com/"* "${DOCU_PATH}/downloaded/"


# Find all the directories that have either a ./docs/ subdir or ./docs.html , the rest delete them
# ---------------------------------------------------------------------------
# Path to the parent directory
PARENT_DIR="${DOCU_PATH}/downloaded/"

# Find all subdirectories
find "$PARENT_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r DIR; do
    # Check if the directory contains 'docs' or 'docs.html'
    if ! find "$DIR" -type d -name "docs" -print -quit | grep -q '.' &&
       ! find "$DIR" -type f -name "docs.html" -print -quit | grep -q '.'; then
        # If neither 'docs' nor 'docs.html' is found, delete the directory
        echo "Deleting directory: $DIR"
        rm -rf "$DIR"
    fi
done
# ---------------------------------------------------------------------------


# Remove the files that are at depth 1 (they are not explicative)
find "${DOCU_PATH}/downloaded/" -maxdepth 1 -type f -exec rm -f {} +



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



## RENAME LONE INDEX.HTML
## ------------------------------------------------------------------------
## Rename lone index.html to subdir folder and place this file a level down
## For instance
## www.zaproxy.org/docs/alerts/
## www.zaproxy.org/docs/alerts/0/index.html
## should become
## www.zaproxy.org/docs/alerts/0.html


mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/" -type f -name "index.html")
for file in "${files_array[@]}"; do
    parent="$(basename "$(dirname ${file})")"
    dirname=$(dirname ${file})
    ext=${file##*.}
    mv ${file} "$dirname/../$parent.$ext";
done

## EOF EOF EOF RENAME LONE INDEX.HTML
## ------------------------------------------------------------------------

## DEESTRUCTURING THE DIRECTORY TREE
## ------------------------------------------------------------------------
## Search on a dir, place the files nested in a subdir, on the dir below
## Rename them to ${subdir}file.ext

## For instance check in
## www.zaproxy.org/docs/desktop/addons/
##
## there is gonna be files such as 
## www.zaproxy.org/docs/desktop/addons/access-control-testing/contextoptions.html
##
## make it 
## www.zaproxy.org/docs/desktop/addons/access-control-testing-contextoptions.html



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
## EOF EOF EOF DEESTRUCTURING THE DIRECTORY TREE
## ------------------------------------------------------------------------





# ALGORITHM TO DELETE SAME HEADER FILES
# -------------------------------------------------
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
# EOF EOF EOF ALGORITHM TO DELETE SAME HEADER FILES
# -------------------------------------------------




## ALGORITHM TO SPLIT DOCU
# -------------------------------------------------
    ## Because this documentation is really big
    ## Need to split files into different docu sections
            ##    Section 1: 0-9  and A to E
            ##    Section 2: F to J
            ##    Section 3: K to O
            ##    Section 4: P to T
            ##    Section 5: U to Z
    echo "Splitting files into different docu sections ..."
    [ ! -d "${DOCU_PATH}/../man-debiane/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debiane/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[0-9A-Ea-e]* ${DOCU_PATH}/../man-debiane/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debianj/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debianj/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[F-Jf-j]* ${DOCU_PATH}/../man-debianj/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debiano/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debiano/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[K-Ok-o]* ${DOCU_PATH}/../man-debiano/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debiant/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debiant/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[P-Tp-t]* ${DOCU_PATH}/../man-debiant/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debianz/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debianz/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[U-Zu-z]* ${DOCU_PATH}/../man-debianz/downloaded/
## EOF EOF EOF ALGORITHM TO SPLIT DOCU
# -------------------------------------------------



}

parsing_snippets() {
    echo 'Function not to execute' # Dont delete this line

    sed -e '/^\[\]$/d' \

}

