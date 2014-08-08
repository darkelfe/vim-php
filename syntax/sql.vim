" Vim syntax file for SQL
" Language:		SQL standard / Support for drivers specifics
" Maintainer:	Julien Rosset <jul.rosset@gmail.com>
"
" URL:			https://github.com/darkelfe/vim-highlight
" Version:		0.0.1

if version < 600 || exists("b:current_syntax")
	finish
endif

" Initialize options {{{
function! s:DefineOption (name, value)
	if exists('b:sql_'.a:name)
		return b:{'sql_'.a:name}
	elseif exists('g:sql_'.a:name)
		return g:{'sql_'.a:name}
	else
		return a:value
	endif
endfunction

let s:driver = s:DefineOption('driver', '')

let s:case_sensitive = s:DefineOption('case_sensitive', 0)

delfunction s:DefineOption
" }}}

" Case matching {{{
if s:case_sensitive
	syntax case match
else
	syntax case ignore
endif
" }}}
" Driver specifics include {{{
"if s:driver != ''
"	source! sql/s:driver.vim
"endif
" }}}

" ERROR: {{{
syntax match sqlError /.\+/
" }}}

" SELECT: {{{
syntax keyword sqlSelect nextgroup=@sqlClSelectContentGeneral skipwhite skipempty SELECT

	" DISTINCT: {{{
syntax keyword sqlSelectDistinct nextgroup=@sqlClSelectContent skipwhite skipempty DISTINCT
syntax cluster sqlClSelectContentGeneral add=sqlSelectDistinct

highlight link sqlSelectDistinct sqlFunction
	" }}}

	" Values: {{{
		" Constant: {{{
			" Number: {{{
syntax match sqlSelectNumber nextgroup=@sqlClSelectContentNex skipwhite skipempty /[0-9]\+\(\.[0-9]\+\)\?/
syntax cluster sqlSelectContent add=sqlSelectNumber

highlight link sqlSelectNumber sqlNumber
			" }}}
			" String: {{{
				" Single Quote: {{{
syntax region sqlSelectStringSingle nextgroup=@sqlClSelectContentNext skipwhite skipempty matchgroup=sqlSelectStringSingleDelimiter start=/'/ skip=/\\'/ end=/'/
syntax cluster sqlClSelectString add=sqlSelectStringSingle

highlight link sqlSelectStringSingle          sqlSelectString
highlight link sqlSelectStringSingleDelimiter sqlSelectStringDelimiter
				" }}}
				" Double Quote: {{{
syntax region sqlSelectStringDouble nextgroup=@sqlClSelectContentNext skipwhite skipempty matchgroup=sqlSelectStringDoubleDelimiter start=/"/ skip=/\\"/ end=/"/
syntax cluster sqlClSelectString add=sqlSelectStringDouble

highlight link sqlSelectStringDouble          sqlSelectString
highlight link sqlSelectStringDoubleDelimiter sqlSelectStringDelimiter
				" }}}

syntax cluster sqlSelectContent add=@sqlSelectString

highlight link sqlSelectString          sqlString
highlight link sqlSelectStringDelimiter sqlStringDelimiter
			" }}}
		" }}}
		" Column: {{{
syntax region sqlSelectColumnEscaped nextgroup=@sqlClSelectContentNext skipwhite skipempty transparent oneline contains=sqlSelectColumnName matchgroup=sqlEscape start=/`/ end=/`/
syntax cluster sqlClSelectContent add=sqlSelectColumnEscaped

syntax match sqlSelectColumnName nextgroup=@sqlClSelectContentNext skipwhite skipempty contained /\h\w*/
syntax cluster sqlClSelectContent add=sqlSelectColumnName

highlight link sqlSelectColumnName sqlColumnName
		" }}}
		" Functions: {{{
syntax keyword sqlSelectFunction nextgroup=sqlSelectFunctionGroup skipwhite skipempty count sum min max
		" }}}
	" }}}
	" Values Separator: {{{
syntax match sqlSelectContentComma nextgroup=@sqlClSelectContent skipwhite skipempty /,/
syntax cluster sqlClSelectContentNext add=sqlSelectContentComma

highlight link sqlSelectContentComma sqlComma
	" }}}

syntax cluster sqlClSelectContentGeneral add=@sqlClSelectContent

highlight link sqlSelect sqlStructure
" }}}
" INTO: {{{
syntax keyword sqlInto nextgroup=@sqlClIntoContent skipwhite skipempty INTO

	" Variable: {{{
syntax match sqlIntoVarName nextgroup=@sqlClIntoContentNext skipwhite skipempty contained /\h\w*/
syntax cluster sqlClIntoContent add=sqlIntoVarName
	" }}}
	" Variable Separator: {{{
syntax match sqlIntoContentComma nextgroup=@sqlClIntoContent skipwhite skipempty /,/
syntax cluster sqlClIntoContentNext add=sqlIntoContentComma

highlight link sqlIntoContentComma sqlComma
	" }}}

syntax cluster sqlClSelectContentNext add=sqlInto

highlight link sqlInto sqlStructure
" }}}
" FROM: {{{
syntax keyword sqlFrom nextgroup=@sqlClFromContent skipwhite skipempty FROM

	" Table: {{{
syntax match sqlFromTable nextgroup=@sqlClFromContentNext skipwhite skipempty contained /\h\w*/
syntax cluster sqlClFromContent add=sqlFromTable
	" }}}

syntax cluster sqlClSelectContentNext add=sqlFrom

highlight link sqlFrom sqlStructure
" }}}

" COLORS: {{{
highlight link sqlComma				Operator
highlight link sqlError				Error
highlight link sqlEscape			Special
highlight link sqlFunction			Function
highlight link sqlNumber			Number
highlight link sqlString			String
highlight link sqlStringDelimiter	sqlString
highlight link sqlStructure			Structure

highlight link sqlNone				Todo
highlight link sqlColumnName		sqlNone
highlight link sqlIntoVarName		sqlNone
highlight link sqlFromTable			sqlNone
" }}}

