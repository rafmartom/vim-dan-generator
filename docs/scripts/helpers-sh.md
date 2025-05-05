# helpers.sh

Helper functions in use on vim-dan-generator.

## Overview

author: rafmartom <rafmartom@gmail.com>

## Index

* [perform_install](#performinstall)
* [perform_update](#performupdate)
* [perform_spider](#performspider)
* [perform_index](#performindex)
* [perform_arrange](#performarrange)
* [perform_parse](#performparse)
* [perform_remove](#performremove)
* [delete_index](#deleteindex)
* [process_paths](#processpaths)
* [install_autoload](#installautoload)
* [perform_patch](#performpatch)
* [update_tags](#updatetags)
* [update_vim](#updatevim)
* [decho](#decho)
* [update_csv_field](#updatecsvfield)
* [decimal_to_alphanumeric](#decimaltoalphanumeric)
* [rellink_to_danlinkfrom](#rellinktodanlinkfrom)
* [parse_dan_seealso](#parsedanseealso)
* [rename_lone_index](#renameloneindex)
* [deestructuring_dir_tree](#deestructuringdirtree)
* [getItemsNLevelDir](#getitemsnleveldir)
* [find_same_name_sibling_directory](#findsamenamesiblingdirectory)
* [estimate_docu_weight](#estimatedocuweight)
* [get_split_files](#getsplitfiles)
* [get_split_files_partial](#getsplitfilespartial)
* [delete_duplicate_header_files](#deleteduplicateheaderfiles)
* [unused_snippets](#unusedsnippets)
* [standard_spider](#standardspider)
* [download_fromlist](#downloadfromlist)
* [download_fromlist_waitretry](#downloadfromlistwaitretry)
* [standard_index](#standardindex)
* [write_header](#writeheader)
* [write_html_docu_multirule](#writehtmldocumultirule)
* [write_ext_modeline](#writeextmodeline)

## External_subroutines

Sub-routines that are called by external files
They are mainly called by the main file
Thus they are triggered by the main stages of the Dan Documentation Generation

### perform_install

Peforms a local installation of an already generated documentation

#### Output on stdout

* Return Description

### perform_update

Updates the local file of a certain documentation, keeping when possible the dan-highlighted lines

#### Output on stdout

* Return Description

### perform_spider

Performs the spidering stage of a given documentation:
- For "vim-dan" spidering means the process of gathering all the links of the Files that are going to make the 
documentation topics.
It creates .csv file with all the links to be downloaded in /index-links/<site>.csv.bz2

Note that Child documentations dont have spidering_rules:
- Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
- Child documentations only have : arranging_rules and parsing_rules 

- The spidering rules are specific to each documentation and are defined in
/documentations/docu-name.sh:spidering_rules()
The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
already established ruleset available /documentations/template.sh:
In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
If there are issues in any of the stages, then you may need to adapt these rules.

#### Output on stdout

* Return Description

### perform_index

Performs the indexing stage of a given documentation
- For "vim-dan" indexing is the process of downloading each and every file of the documentation.
By following a link-list like the ones created on the spidering process the download can be
paused, halted and resumed other day.
The files will be downloaded on ${VIMDAN_DIR}/${DOCU_NAME}/downloaded
The indexing process can also take place directly, without a prior spider.

Note that Child documentations dont have indexing_rules:
- Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
- Child documentations only have : arranging_rules and parsing_rules 

- The indexing rules are specific to each documentation and are defined in
/documentations/docu-name.sh:indexing_rules()
The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
already established ruleset available /documentations/template.sh:
In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
If there are issues in any of the stages, then you may need to adapt these rules.

#### Output on stdout

* Return Description

### perform_arrange

Performs the arranging process of a given documentation
- For "vim-dan" arranging is the process of moving, and deleting of the files that have been download in the Index.
On the early versions of "vim-dan" this stage was more important, now thanks to the evolution of the algorithm there 
is no need to perform as many actions.
Actualy some actions are not desirable, such as moving files from one subdir to other will probably break the link parsing functionalities. 
This process creates a backup of the index that in case the rule-set is wrong, you can use without having to re-index it.
${VIMDAN_DIR}/${DOCU_NAME}/downloaded-bk
After that, it deletes files that are not relevant for the documentation that have been downloaded.
In many cases if the documentation is only made of one DOWNLOAD_LINK (as many are) it is useful to bring down all the subdirectories from original the host directory deleting this.
At the end it cleans the duplicates.

Note that Parent documentations dont have arranging_rules:
- Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
- Child documentations only have : arranging_rules and parsing_rules 

- The arranging rules are specific to each documentation and are defined in
/documentations/docu-name.sh:arranging_rules()
The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
already established ruleset available /documentations/template.sh:
In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
If there are issues in any of the stages, then you may need to adapt these rules.

#### Output on stdout

* Return Description

### perform_parse

Performs the parsing and writting stage of a given documentation
- For "vim-dan" parsing means, obtaining the necessary text from each downloaded file, such as File "Titles", and Content
, taking off the rest of the redudant information that each file may have such as navigation bars footers etc...
In the most common of the cases are .html files with different Selectors, some matches the Titles, some matches the content.
Other stage of parsing involves processing the links.
On the writting stage there will be the creation of an interactive TOC
To then the appending of each File Relevant Content. All in the `.dan` format.
At the end of the writting process there is a cleanup process, for yet some string regularities that couldn't be filtered on the previous process (it typically involve sed commands)
To then create the different modelines needed for the functioning of the `.dan` format.

Once the file has been generated, it will install all the vim-dan files locally if they are not installed.

Note that parent documentations dont have parsing_rules:
- Parent documentations (the ones named -parent.sh )only have : spidering_rules and indexing_rules  
- Child documentations only have : arranging_rules and parsing_rules 

- The parsing rules are specific to each documentation and are defined in
/documentations/docu-name.sh:parsing_rules()
The fact that the ruleset is defined on a per documentation basis gives you the ability to create your own.
Each documentation may have its own quirks, but the bast majority of sites will work nicely with the
already established ruleset available /documentations/template.sh:
In case of creating a new documentation from the scratch start from this file, changing just the DOWNLOAD_LINK.
If there are issues in any of the stages, then you may need to adapt these rules.

#### Output on stdout

* Return Description

### perform_remove

It will remove a certain dan documentation localy. It will also remove the dan files.
For this last reason is not recommended to use it, as the dan files are one per documentation just delete it manualy.

#### Output on stdout

* Return Description

### delete_index

Delete the Indexed files for a certain documentation.
Good to save up space once the documentation has been parsed, the index files are not longer needed.
Mind that if you are creating a new documentation and are defining a rule-set, if you are unsure that 
Some rules may be changed it is better to keep it.

#### Output on stdout

* Return Description

## Internal_subroutines

Subroutines that are triggered automatically by other function
Note for minimal boilerplate these functions:
- Are going to use shared variables
- Are not going to have type checking
Thus they wont be moveable from this file without re-writting

### process_paths

Generate shared-variables for use across the script
Mostly related to filepaths that are processed through the minimal
Arguments needed

### install_autoload

Installs the vim autoload dan file

### perform_patch

It attempts to update an outdated dan-file with (X) annotations with a new-one.
It maw casuse conflicts, it is recommendable not to mix new versions of dan files with old ones

### update_tags

Update the local tags file for the current documentation

### update_vim

It install/replaces the vim configuration files needed for dan functionalities.

## Cross-Project Utilities

Utility functions that are usable in other projects

### decho

decho Prints a debug message if DEBUG mode is enabled.

#### Options

* $* Strings to output as the debug message

#### Output on stdout

* Outputs the message to stderr if DEBUG is set to 'true'

### update_csv_field

Update a CSV field given a ROW_NAME for the first column and a COL_NAME for the header column.
If both ROW_NAME and COL_NAME match, the field will be updated with INPUT_STRING.
If the -n flag is used and ROW_NAME is not found, a new row will be added at the end of the CSV file.

Example CSV:
,notes,last_parsed,last_arranged
adobe-ae,,,,
patxie,,,,

Example usage:
update_csv_field -f "example.csv" -r "adobe-ae" -c "last_parsed" -i "now"

Result:
,notes,last_parsed,last_arranged
adobe-ae,,now,,
patxie,,,,

#### Options

* **-f \<CSV_FILENAME\>**

  The path to the CSV file to update.

* **-r \<ROW_NAME\>**

  The name of the row to update (matches the first column).

* **-c \<COL_NAME\>**

  The name of the column to update (matches the header row).

* **-i \<INPUT_STRING\>**

  The new value to insert into the specified field.

* **-n**

  Add a new row if ROW_NAME is not found in the CSV file.

#### Output on stdout

* No direct output. The CSV file is modified in place.

### decimal_to_alphanumeric

Converts a decimal number to a base-62 alphanumeric string.
This function maps decimal numbers to a custom base-62 encoding using the characters 0-9, a-z, and A-Z.
It is useful for generating short, unique identifiers from numeric values.

#### Arguments

* **$1** (<num>): The decimal number to convert.

#### Output on stdout

* The base-62 alphanumeric representation of the input number.

## Deprecated Functions

The following functions are no longer used in this project
Although it is worth keeping, as they may be useful again.
Or they are well written algorithms worth to be re-checked

### rellink_to_danlinkfrom

Transforms a relative HTML link such as /guidance/living-in-europe
into & @guidance-)living-in-europe.html@ living-in-europe &

### parse_dan_seealso

Parses an HTML file to generate an in-file HTML list of "danlinkfrom"-formatted links.
This function is used during the arrangement process and cannot use `cut-dirs`. It appends a list of
filtered links to the specified HTML file, wrapped in a `.dan-seealso` div.

The function extracts `href` attributes from elements matching the given CSS selector and filters
them based on include paths. If no include paths are provided, all relative links are included.

Example usage:
parse_dan_seealso "./downloaded/spain.html" ".govuk-link attr{href}" "government/collections" "guidance"

This will parse the `href` attributes from elements with the class `.govuk-link` and include only
those links that start with `/government/collections` or `/guidance`.

#### Arguments

* **$1** (<file>): The path to the HTML file to process.
* **$2** (<selector>): The CSS selector to extract links (e.g., ".govuk-link attr{href}").
* **...** (<includes>): Optional list of include paths to filter links (e.g., "government/collections").

#### Output on stdout

* Appends an HTML list of filtered links to the input file.

### rename_lone_index

Renames lone `index.html` files to match their parent directory names and moves them one level up.
This function is useful for restructuring downloaded HTML files where `index.html` files are nested in subdirectories.
For example:
- Input:  www.zaproxy.org/docs/alerts/0/index.html
- Output: www.zaproxy.org/docs/alerts/0.html

If the function creates a file named `${DOCU_PATH}/downloaded.html`, it moves it back to `${DOCU_PATH}/downloaded/index.html`.

#### Options

* $DOCU_PATH The base directory containing the downloaded files.

#### Output on stdout

* No direct output. Files are renamed and moved in place.

### deestructuring_dir_tree

Flattens a directory tree by moving files from nested subdirectories to their parent directories.
This function renames files to include their parent directory names, effectively "de-structuring" the directory hierarchy.

For example:
- Input:  www.zaproxy.org/docs/desktop/addons/access-control-testing/contextoptions.html
- Output: www.zaproxy.org/docs/desktop/addons/access-control-testing-contextoptions.html

The function iterates up to 15 times to ensure all nested files are moved. After flattening, it deletes any empty directories.

#### Options

* $DOCU_PATH The base directory containing the downloaded files.

#### Output on stdout

* No direct output. Files are moved and renamed in place, and empty directories are deleted.

### getItemsNLevelDir

Lists files or directories that are N levels below a specified subdirectory.
This function searches for items (files or directories) at a specific depth relative to a given subdirectory.
It supports optional recursion to include items in all subdirectories below the specified level.

#### Arguments

* **$1** (<items>): The type of items to search for: "f" for files, "d" for directories.
* **$2** (<level>): The depth (number of levels) below the specified subdirectory to search.
* **$3** (<directory>): The name of the subdirectory to search within (e.g., "Global_Objects").
* **$4** (<recursion>): Whether to include items in all subdirectories below the specified level: "yes" or "no".

#### Output on stdout

* Prints the paths of matching files or directories.

### find_same_name_sibling_directory

Finds files with a given extension that have a sibling directory of the same name.
This function searches for files with the specified extension in a directory and checks if there
is a corresponding directory with the same name (excluding the extension). If such a directory
exists, the file path is printed. The function processes subdirectories recursively.

#### Arguments

* **$1** (<dir>): The directory to search in.
* **$2** (<ext>): The file extension to search for (e.g., "html").

#### Output on stdout

* Prints the paths of files that have a sibling directory with the same name.

### estimate_docu_weight

Estimates the total plaintext size of documentation files by calculating the difference between HTML size and HTML boilerplate overhead.
This function calculates the "HTML headroom" (boilerplate overhead) for a single HTML file and extrapolates it to all HTML files in the directory.
It then subtracts the total headroom from the total HTML size to estimate the plaintext size of the documentation.

The function outputs:
- HTML headroom for a single file.
- Total number of HTML files.
- Total headroom for all files.
- Total HTML size in bytes.
- Estimated plaintext size in bytes and megabytes.

#### Options

* $DOCU_PATH The base directory containing the downloaded HTML files.

#### Output on stdout

* Prints the estimated plaintext size of the documentation in bytes and megabytes.

### get_split_files

Splits documentation files into a specified number of parts of approximately equal size.
This function calculates the size of each split and identifies the files where the splits should occur.
It assumes that the documentation files are sorted alphabetically and will be processed in that order.

The function outputs the filenames where each split occurs and the size of each split.

#### Arguments

* **$1** (<no_splits>): The number of splits to create.
* **$2** (<path>): The directory containing the HTML files to split.

#### Output on stdout

* Prints the split points (filenames) and the size of each split.

### get_split_files_partial

Splits a subset of documentation files into a specified number of parts of approximately equal size.
This function is similar to `get_split_files`, but it operates on a subset of files between `file_start` and `file_finnish`.
It calculates the size of each split and identifies the files where the splits should occur.
The function assumes that the documentation files are sorted alphabetically and will be processed in that order.

The function outputs the filenames where each split occurs and the size of each split.

#### Arguments

* **$1** (<no_splits>): The number of splits to create.
* **$2** (<path>): The directory containing the HTML files to split.
* **$3** (<file_start>): The starting file (inclusive) for the subset of files to process.
* **$4** (<file_finnish>): The ending file (inclusive) for the subset of files to process.

#### Output on stdout

* Prints the split points (filenames) and the size of each split.

### delete_duplicate_header_files

Deletes files with duplicate headers in a directory structure.
This function searches for files with the same header (extracted using the `.head-ltitle` CSS selector)
and removes duplicates, keeping only one instance of each unique header.
It is designed to work with a directory structure where files are organized in subdirectories.

#### Options

* $DOCU_PATH The base directory containing the files to process.

#### Output on stdout

* Prints the paths of deleted files.

### unused_snippets

A function to store codeblocks that are not used

## Spidering Stage Utilities

Standard Spidering Subroutines implemented across different documentations

### standard_spider

Performs an inte

#### Options

* **-l \<DOWNLOAD_LINK\>**

  Option Description

#### Output on stdout

* Return Description

## Indexing Stage Utilities

Standard Indexing Subroutines implemented across different documentations

### download_fromlist

download_fromlist Function Description
Out of a <websiteLinks>.csv created from standard_spider()
Download each link
- Updating the .csv with status code
- Download it to DOCU_PATH/downloaded

#### Options

* **-l \<DOWNLOAD_LINK\>**

  Option Description

#### Output on stdout

* Return Description

### download_fromlist_waitretry

Out of a <websiteLinks>.csv created from standard_spider()
Download each link
- Updating the .csv with status code
- Download it to DOCU_PATH/downloaded

#### Options

* **-w \<WAIT\>**

  Seconds to wait per link

* **-r \<WAIT_RETRY\>**

  Seconds to wait per unsuccesful download

* -l <DOWNLOAD_LINK>

#### Output on stdout

* Return Description

### standard_index

standard_index Function Description

#### Options

* **-l \<DOWNLOAD_LINK\>**

  Option Description

#### Output on stdout

* Return Description

## Parsing Stage Utilities

Standard Arraging Subroutines shared across different documentations

### write_header

Write the vim-dan generic header

### write_html_docu_multirule

write_html_docu_multirule Function Description
Similar as write_docu_multirule() but simplified, just to input html tags such as
write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body"
For understanding the code , there are not comments but just the added functionality ones
from write_docu_multirule()
It needs ${DOCU_NAME} to be setted
It needs ${DOCU_PATH} to be setted

#### Example

```bash
write_html_docu_multirule -f "head title" -b "div.guide-content" -b "body" -cp -fm "tail -n +6 
```

#### Options

* **-L**

  [PANDOC_FILTER] Add a pandoc filter (optional)

* **-c**

  [WRAP_COLUMNS] Inidicate no of columns for the output to be wrapped to (default non-wrap)

* -f <TITLE_SELECTOR>... Specify a title html selector (repeat -f to specify multiple posible selectors)
* -b <BODY_SELECTOR>... Specify a body html selector (repeat -b to specify multiple posible selectors)
* -fm [FILE_MANGLING] Add some string manipulation commands to filter with the whole document afterwards (optional)

### write_ext_modeline

Create a dan modeline for the different syntaxes that show in the file

