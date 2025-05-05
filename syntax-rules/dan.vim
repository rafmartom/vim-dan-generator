" Vim syntax file
" Current Maintainer: freddieventura (https://github.com/freddieventura)
" Syntax referred to vim-dan Documents 
" More info https://github.com/freddieventura/vim-dan

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

if has("folding")
    setlocal foldmethod=marker
    set foldcolumn=3
endif

" BASIC DAN SYNTAX ITEMS
" ---------------------------------------------------------
" Link to tags
if has("conceal")
  setlocal cole=2 cocu=nc
endif

" Link Source
syn region danLinkSource start="<L=[[:alnum:]#]\+>" end="</L>" contains=danLinkSourceOTag,danLinkSourceCTag oneline keepend

hi def link danLinkSource ColorColumn


syn match danLinkSourceOTag contained "<L=[[:alnum:]#]\+>" conceal
syn match danLinkSourceCTag contained "</L>" conceal


" Block Link Target
syn region danBlockLinkTarget start="<B=[[:alnum:]]\+>" end="$" contains=danBlockLinkTargetTag oneline keepend

hi def link danBlockLinkTarget String

syn match danBlockLinkTargetTag contained "<B=[[:alnum:]]\+>" conceal


" Inline Link Target

syn region danInlineLinkTarget start="<I=[[:alnum:]]\+>" end="$" contains=danInlineLinkTargetTag oneline keepend

syn match danInlineLinkTargetTag contained "<I=[[:alnum:]]\+>" conceal







" Links from
syn region danLinkfromEntry start="&" end="&" contains=danLinkfromAmper,danLinkFromParentName oneline keepend

if has("conceal")
  syn match danLinkfromAmper contained "&" conceal
  syn match danInlineLinkfromChars "%\$.*%\$" conceal
"  syn match danLinkFromParentName contained "@[-./,=\"[:alnum:]_~) ]*@" conceal
  syn match danLinkFromParentName contained "@.*@" conceal
"  syn match danCodeDelimiter "```\w*$" conceal
else
  syn match danLinkfromAmper contained "&"
"  syn match danLinkFromParentName contained "@[-./,=\"[:alnum:]_~) ]*@"
  syn match danLinkFromParentName contained "@.*@"
endif

syn match danSectionDelim	"^===.*===\%(\s(X)\)\{,1}$" contains=danX
syn match danSectionDelim	"^---.*--\%(\s(X)\)\{,1}$" contains=danX

"hi def link danLinkfromEntry Identifier
hi def link danLinkfromEntry NonText
hi def link danLinkFromAmper Ignore
hi def link danLinkFromParentName Ignore

hi def link danSectionDelim PreProc

" Links to
syn match danLinktoEntry "^#\s.*\s#$" contains=danLinktoHash
syn match danLinktoEntryXed "^#\s.*\s#\%(\s(X)\)\{,1}$" contains=danLinktoHash,danX
syn match danLinktoHash contained "#" conceal
syn match danLinkMarker "\[+\]"

hi def link danLinktoHash Ignore
hi def link danLinktoEntry String
hi def link danLinktoEntryXed String
hi def link danLinkMarker SpecialKey

" (X) Annotation
syn match danX "(X)"

hi def link danX StatusLineTerm

" Method links
syn match danProperty "[A-Za-z][A-Za-z0-9\_\$]*\.[A-Za-z][A-Za-z0-9\_\$]*\(\s\|\n\|#\)" contains=danX,danLinktoHash
syn match danMethod "[A-Za-z][A-Za-z0-9\_\$]*\.[A-Za-z][A-Za-z0-9\_\$]*(.*)#\{,1}" contains=danX,danLinktoHash
hi def link danMethodLink	Identifier
hi def link danMethod Identifier
hi def link danProperty Statement


" Lists
syn match danListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contains=danMethod,danProperty,danEvent,danClass
hi def link danListMarker Statement

set tabstop=2
set shiftwidth=2
set expandtab
" ---------------------------------------------------------
" EOF EOF EOF EOF BASIC DAN SYNTAX ITEMS


" AUTOMATIC SYNTAX HIGHLIGHTING BY READING CUSTOM MODELINE
" --------------------------------------------------------
let g:syntax_executed_no += 1
if g:syntax_executed_no >= 1


    " SOURCING EACH INDIVIDUAL SYNTAX SPECIFIED IN THE MODELINE
    if exists('g:dan_ext_list')
        for vimsyntax in g:dan_ext_list
            " Include the corresponding syntax file
            execute 'syn include @dan' . vimsyntax . ' syntax/' . vimsyntax . '.vim'
            
            " Unset the current syntax (if needed)
            unlet b:current_syntax

            " Create the syntax region for the current language
            execute 'syn region ' . vimsyntax . ' start=/^```' . vimsyntax . '$/ms=e keepend end=/^```$/me=s-1 contains=@dan' . vimsyntax
        endfor
    endif
    


    " SYNTAX HIGHLIGH DIFFERENT KEYWORDS SPECIFIED IN THE MODELINE
    if exists('g:dan_kw_question_list')
        for dan_kw_question in g:dan_kw_question_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_question_' . dan_kw_question_no . ' "' . dan_kw_question . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_question_' . dan_kw_question_no ' Question'


            let g:dan_kw_question_no += 1
        endfor
    endif

    if exists('g:dan_kw_nontext_list')
        for dan_kw_nontext in g:dan_kw_nontext_list

            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_nontext_' . dan_kw_nontext_no . ' "' . dan_kw_nontext . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_nontext_' . dan_kw_nontext_no ' NonText'


            let g:dan_kw_nontext_no += 1
        endfor
    endif

    if exists('g:dan_kw_linenr_list')
        for dan_kw_linenr in g:dan_kw_linenr_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_linenr_' . dan_kw_linenr_no . ' "' . dan_kw_linenr . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_linenr_' . dan_kw_linenr_no ' LineNr'


            let g:dan_kw_linenr_no += 1
        endfor
    endif

    if exists('g:dan_kw_warningmsg_list')
        for dan_kw_warningmsg in g:dan_kw_warningmsg_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_warningmsg_' . dan_kw_warningmsg_no . ' "' . dan_kw_warningmsg . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_warningmsg_' . dan_kw_warningmsg_no ' WarningMsg'


            let g:dan_kw_warningmsg_no += 1
        endfor
    endif

    if exists('g:dan_kw_colorcolumn_list')
        for dan_kw_colorcolumn in g:dan_kw_colorcolumn_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_colorcolumn_' . dan_kw_colorcolumn_no . ' "' . dan_kw_colorcolumn . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_colorcolumn_' . dan_kw_colorcolumn_no ' ColorColumn'


            let g:dan_kw_colorcolumn_no += 1
        endfor
    endif

    if exists('g:dan_kw_underlined_list')
        for dan_kw_underlined in g:dan_kw_underlined_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_underlined_' . dan_kw_underlined_no . ' "' . dan_kw_underlined . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_underlined_' . dan_kw_underlined_no ' Underlined'


            let g:dan_kw_underlined_no += 1
        endfor
    endif

    if exists('g:dan_kw_preproc_list')
        for dan_kw_preproc in g:dan_kw_preproc_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_preproc_' . dan_kw_preproc_no . ' "' . dan_kw_preproc . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_preproc_' . dan_kw_preproc_no ' PreProc'


            let g:dan_kw_preproc_no += 1
        endfor
    endif

    if exists('g:dan_kw_comment_list')
        for dan_kw_comment in g:dan_kw_comment_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_comment_' . dan_kw_comment_no . ' "' . dan_kw_comment . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_comment_' . dan_kw_comment_no ' Comment'


            let g:dan_kw_comment_no += 1
        endfor
    endif

    if exists('g:dan_kw_identifier_list')
        for dan_kw_identifier in g:dan_kw_identifier_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_identifier_' . dan_kw_identifier_no . ' "' . dan_kw_identifier . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_identifier_' . dan_kw_identifier_no ' Identifier'


            let g:dan_kw_identifier_no += 1
        endfor
    endif

    if exists('g:dan_kw_ignore_list')
        for dan_kw_ignore in g:dan_kw_ignore_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_ignore_' . dan_kw_ignore_no . ' "' . dan_kw_ignore . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_ignore_' . dan_kw_ignore_no ' Ignore'


            let g:dan_kw_ignore_no += 1
        endfor
    endif

    if exists('g:dan_kw_statement_list')
        for dan_kw_statement in g:dan_kw_statement_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_statement_' . dan_kw_statement_no . ' "' . dan_kw_statement . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_statement_' . dan_kw_statement_no ' Statement'


            let g:dan_kw_statement_no += 1
        endfor
    endif

   if exists('g:dan_kw_cursorline_list')
        for dan_kw_cursorline in g:dan_kw_cursorline_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_cursorline_' . dan_kw_cursorline_no . ' "' . dan_kw_cursorline . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_cursorline_' . dan_kw_cursorline_no ' CursorLine'


            let g:dan_kw_cursorline_no += 1
        endfor
    endif

    if exists('g:dan_kw_tabline_list')
        for dan_kw_tabline in g:dan_kw_tabline_list
            " Substitute execute for echo if you want to troubleshoot the command
            execute 'syn match dan_kw_tabline_' . dan_kw_tabline_no . ' "' . dan_kw_tabline . '" ' . 'contains=danX'
            execute 'hi def link dan_kw_tabline_' . dan_kw_tabline_no ' TabLine'


            let g:dan_kw_tabline_no += 1
        endfor
    endif


endif
" --------------------------------------------------------
" --------------------------------------------------------
