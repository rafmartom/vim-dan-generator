au BufRead,BufNewFile *.dan set filetype=dan
"au BufRead,BufNewFile *.react-nativedan silent! call dan#Refreshloclist()

" Initializing variables for unified dan syntax
let g:syntax_executed_no = 0

let g:dan_kw_question_no = 0
let g:dan_kw_nontext_no = 0
let g:dan_kw_linenr_no = 0
let g:dan_kw_warningmsg_no = 0
let g:dan_kw_colorcolumn_no = 0
let g:dan_kw_underlined_no = 0
let g:dan_kw_preproc_no = 0
let g:dan_kw_comment_no = 0
let g:dan_kw_identifier_no = 0
let g:dan_kw_ignore_no = 0
let g:dan_kw_statement_no = 0
let g:dan_kw_cursorline_no = 0
let g:dan_kw_tabline_no = 0


let g:dan_lang_accumulated_list = []

let g:dynamicLookupDict = {}
let g:danFilesSourced = []
