au BufRead,BufNewFile *.react-nativedan set filetype=react-nativedan
"au BufRead,BufNewFile *.react-nativedan silent! call dan#Refreshloclist()

" Initializing variables for unified dan syntax
let g:syntax_executed_no = 0

let g:dan_lang_accumulated_list = []

let g:dynamicLookupDict = {}
let g:danFilesSourced = []
