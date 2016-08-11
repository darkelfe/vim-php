" Vim syntax file for SQL
" Language:     SQL standard / Support for drivers specifics
" Maintainer:   Julien Rosset <jul.rosset@gmail.com>
"
" URL:          https://github.com/vim-highlight/sql/
" Version:      0.0.1

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

let s:vim_highlight = {}
let s:vim_highlight.options {}
let s:vim_highlight.options.core = {}

function s:vim_highlight.options.core.getOption (name, defaultValue)
    if exists('b:sql_'.a:name)
        return b:{'sql_'.a:name}
    elseif exists('g:sql_'.a:name)
        return g:{'sql_'.a:name}
    else
        return a:defaultValue
    endif
endfunction

function s:vim_highligt.options.core.boolOption (options, name)
    let l:str = ''

    if has_key(a:options, a:name)
        if type(a:options.a:name) == type(0)
            if a:options.a:name == 1
                let l:str = l:str.' '.a:name
            endif
        endif
    endif

    return l:str
endfunction
function s:vim_highligt.options.core.listOption (options, name)
    let l:str = ''

    if has_key(a:options, a:name)
        if type(a:options.a:name) == type('')
            if len(a:options.a:name) > 0
                let l:str = l:str.' '.a:name.'='.a:options.a:name
            endif
        elseif type(a:options.a:name == type([]))
            if count(a:options.a:name) > 0
                let l:str = l:str.' '.a:name.'='.join(a:options.a:name, ',')
            endif
        endif
    endif

    return l:str
endfunction

function s:vim_highlight.options.core.commonToString (options)
    let l:str = ''

    let l:str = l:str.boolOption(a:options, 'contained')
    let l:str = l:str.listOption(a:options, 'containedin')
    let l:str = l:str.listOption(a:options, 'nextgroup')
    let l:str = l:str.boolOption(a:options, 'transparent')
    let l:str = l:str.boolOption(a:options, 'skipwhite')
    let l:str = l:str.boolOption(a:options, 'skipnl')
    let l:str = l:str.boolOption(a:options, 'skipempty')

    return l:str
endfunction
function s:vim_highlight.options.core.keywordToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)

    return l:str
endfunction
function s:vim_highlight.options.core.matchToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)
    let l:str = l:str.listOption(a:options, 'contains')
    let l:str = l:str.boolOption(a:options, 'fold')
    let l:str = l:str.boolOption(a:options, 'display')
    let l:str = l:str.boolOption(a:options, 'extend')
    
    let l:str = l:str.boolOption(a:options, 'excludenl')

    return l:str
endfunction
function s:vim_highlight.options.core.regionToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)
    let l:str = l:str.listOption(a:options, 'contains')
    let l:str = l:str.boolOption(a:options, 'oneline')
    let l:str = l:str.boolOption(a:options, 'fold')
    let l:str = l:str.boolOption(a:options, 'display')
    let l:str = l:str.boolOption(a:options, 'extend')
    
    let l:str = l:str.listOption(a:options, 'matchgroup')
    let l:str = l:str.boolOption(a:options, 'keepend')
    let l:str = l:str.boolOption(a:options, 'extend')
    let l:str = l:str.boolOption(a:options, 'excludenl')

    return l:str
endfunction



" Initialize options {{{
let s:driver         = s:DefineOption('driver'        , '')
let s:case_sensitive = s:DefineOption('case_sensitive',  0)
" }}}

" Case matching {{{
if s:case_sensitive
    syntax case match
else
    syntax case ignore
endif
" }}}


let s:core = { prefix: '' }

function core.matchOptions (options)
    let l:str = ''

    if has_key(a:options, 'contains') && len(a:options.contains) > 0
        let l:str = l:str.' contains='.a:options.contains
    endif

    return l:str
endfunction

function core.match (name, regex, options) dict
    execute 'syntax match '.self.prefix.a:name.' '.a:regex
endfunction

let s:core.prefix = 'sql'

syntax match sqlTableName /\c[a-z][a-z0-9_-]*/
highlight default link sqlTableName sqlIdentifier

syntax match sqlColumnName /\c[a-z][a-z0-9_-]*/
highlight default link sqlTableName sqlIdentifier

" FUNCTIONS: {{{
function s:common_table_expression ()
    syntax cluster sqlCommonTableExpression contains=


endfunction

function s:select_stmt ()
    syntax keyword sqlSelectStmtWith nextgroup=@sqlSelectStmtFollow skipwhite skipempty contained WITH
    highlight default link sqlSelectStmtWith sqlKeyword

    syntax keyword sqlSelectStmtRecursive nextgroup=@sqlSelectStmtCommonTableExpressionBloc skipwhite skipempty contained RECURSIVE
    highlight default link sqlSelectWithRecursive sqlKeyword

    syntax cluster sqlSelectWithCommonTableExpressionBloc contains=

    syntax cluster sqlSelectWithFollow contains=sqlSelectWithRecursive
endfunction
" }}}

" ERROR: {{{
syntax match sqlError /\S.*/
" }}}
    
" COMMENTS: {{{
syntax region sqlCommentOneline oneline start=#//# end=#$#
syntax region sqlCommentMultiline start=#/*# end=#*/#

syntax cluster sqlComment contains=sqlCommentOneline,sqlCommentMultiline
" }}}

" CLEAN: {{{
delfunction s:selectStmt
" }}}

" HIGHLIGHT: {{{
highlight default link sqlIdentifier    Identifier
highlight default link sqlError         Error
highlight default link sqlComment       Comment
" }}}

let b:current_syntax = "sql"
