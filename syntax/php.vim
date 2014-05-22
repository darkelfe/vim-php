" Vim syntax file for PHP
" Language:		PHP 4 / 5
" Maintainer:	Julien Rosset <jul.rosset@gmail.com>
"
" URL:			https://github.com/darkelfe/vim-php
" Version:		0.0.1

if version < 600 || exists("b:current_syntax")
	finish
endif

runtime! syntax/html.vim
unlet b:current_syntax

" Initialize options {{{
function! s:DefineOption (name, value)
	if exists('b:php_'.a:name)
		return b:{'php_'.a:name}
	elseif exists('g:php_'.a:name)
		return g:{'php_'.a:name}
	else
		return a:value
	endif
endfunction

	" Fold {{{
let s:fold_root     = s:DefineOption('fold_root', 0)
let s:fold_comments = s:DefineOption('fold_comments', 1)
let s:fold_classes  = s:DefineOption('fold_classes', 1)
	" }}}

delfunction s:DefineOption
" }}}

syntax case match

runtime! syntax/php_contents.vim

" ROOT: <?php ... ?> {{{
if s:fold_root
	syntax region phpRoot fold contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
else
	syntax region phpRoot      contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
endif
" }}}

" ERROR: {{{
syntax match phpError contained /\S.*$/
" }}}
" COMMENTS:	// ou /* ... */ {{{
syntax match phpComment contained #//.*$#

if s:fold_comments
	syntax region phpComment fold contained keepend extend start=#/\*# end=#\*/#
else
	syntax region phpComment      contained keepend extend start=#/\*# end=#\*/#
endif

syntax cluster phpClRoot add=phpComment

	" Automatic comment block {{{
function! s:DefineCustomCommentBlock (name, next)
	execute 'syntax match '.a:name.' contained nextgroup='.a:next.' skipwhite skipempty #//.*$#'

	if s:fold_comments
		execute 'syntax region '.a:name.' fold contained nextgroup='.a:next.' skipwhite skipempty contained keepend extend start=#/\*# end=#\*/#'
	else
		execute 'syntax region '.a:name.'      contained nextgroup='.a:next.' skipwhite skipempty contained keepend extend start=#/\*# end=#\*/#'
	endif
	
	execute 'highlight link '.a:name.' phpComment'
endfunction
	" }}}
" }}}
" ENDS: {{{
	" END OF INSTRUCTION: {{{
call s:DefineCustomCommentBlock('phpSemicolonComment', 'phpSemicolon')

syntax match phpSemicolon contained nextgroup=phpComments skipwhite /;/
highlight link phpSemicolon phpOperator

syntax cluster phpClSemicolon contains=phpSemicolonComment,phpSemicolon
	" }}}
" }}}

" NAMESPACE: namespace foo\bar {{{
	" {{{
syntax keyword phpNamespace contained nextgroup=phpNamespaceName,phpNamespaceComment skipwhite skipempty namespace
syntax match phpNamespaceName contained nextgroup=@phpClSemicolon skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

call s:DefineCustomCommentBlock('phpNamespaceComment', 'phpNamespaceName')

syntax cluster phpClRoot add=phpNamespace
highlight link phpNamespace phpStructure
	" }}}

	" USE: {{{
syntax keyword phpNamespaceUse contained nextgroup=phpNamespaceUseName,phpNamespaceUseComment skipwhite skipempty use
syntax match phpNamespaceUseName contained contains=@phpClExtensionClasses nextgroup=@phpClNamespaceUse skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/
" TODO phpNamespaceUseName match @phpClExtensionClasses only as root class

		" use Foo\Bar {{{
syntax cluster phpClNamespaceUse contains=@phpClSemicolon
		" }}}
		" use Foo\Bar as FooBar {{{
syntax keyword phpNamespaceUseAs contained nextgroup=phpNamespaceUseAsName,phpNamespaceUseAsComment skipwhite skipempty as
syntax match phpNamespaceUseAsName contained nextgroup=@phpClNamespaceUse skipwhite skipempty /\h\w*/

syntax cluster phpClNamespaceUse add=phpNamespaceUseAs
highlight link phpNamespaceUseAs phpStructure
		" }}}
		" use Foo\Bar, ... {{{
syntax match phpNamespaceUseComma contained nextgroup=phpNamespaceUseName,phpNamespaceUseCommaComment skipwhite skipempty /,/

syntax cluster phpClNamespaceUse add=phpNamespaceUseComma
highlight link phpNamespaceUseComma phpOperator
		" }}}

syntax cluster phpClNamespaceUse add=phpNamespaceUseNameComment

call s:DefineCustomCommentBlock('phpNamespaceUseComment', 		'phpNamespaceUseName')
call s:DefineCustomCommentBlock('phpNamespaceUseNameComment', 	'@phpClNamespaceUse')
call s:DefineCustomCommentBlock('phpNamespaceUseAsComment', 	'phpNamespaceUseAsName')
call s:DefineCustomCommentBlock('phpNamespaceUseCommaComment', 	'phpNamespaceUseName')

syntax cluster phpClRoot add=phpNamespaceUse
highlight link phpNamespaceUse phpStructure
	" }}}
" }}}
" CLASS: {{{
	" Definition {{{
		" [abstract] class myFoo {{{
syntax keyword phpClassAbstract contained nextgroup=phpClass,phpClassAbstractComment skipwhite skipempty abstract
syntax keyword phpClass contained nextgroup=phpClassName,phpClassComment skipwhite skipempty class

syntax match phpClassName contained nextgroup=@phpClClass skipwhite skipempty /\h\w*/

highlight link phpClass			phpStructure
highlight link phpClassAbstract	phpStructure

syntax cluster phpClRoot add=phpClass,phpClassAbstract
		" }}}
		" extends Foo\Bar {{{
syntax keyword phpClassExtends contained nextgroup=phpClassExtendsName,phpClassExtendsComment skipwhite skipempty extends
syntax match phpClassExtendsName contained contains=@phpClExtensionClasses nextgroup=@phpClClassExtends skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

highlight link phpClassExtends	phpStructure

syntax cluster phpClClass add=phpClassExtends
		" }}}
		" implements \Foo\Bar {{{
			" implements + <class name>
syntax keyword phpClassImplements contained nextgroup=phpClassImplementsName,phpClassImplementsComment skipwhite skipempty implements
syntax match phpClassImplementsName contained contains=@phpClExtensionClasses nextgroup=@phpClClassImplements skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

highlight link phpClassImplements	phpStructure

syntax cluster phpClClass	add=phpClassImplements
syntax cluster phpClExtends	add=phpClassImplements

			" , XXX if present
syntax match phpClassImplementsComma contained nextgroup=phpClassImplementsName,phpClassImplementsCommaComment skipwhite skipempty /,/

highlight link phpNamespaceUseComma phpOperator

syntax cluster phpClClassImplements add=phpClassImplementsComma
		" }}}
		" <class block> {{{
if s:fold_classes
	syntax region phpClassBlock fold contains=@phpClClassContent matchgroup=phpClassBlockBounds start=/{/ end=/}/
else
	syntax region phpClassBlock      contains=@phpClClassContent matchgroup=phpClassBlockBounds start=/{/ end=/}/
endif

highlight link phpClassBlockBounds	phpOperator

syntax cluster phpClClass			add=phpClassBlock
syntax cluster phpClClassExtends	add=phpClassBlock
syntax cluster phpClClassImplements	add=phpClassBlock
		" }}}

syntax cluster phpClClass			add=phpClassNameComment
syntax cluster phpClClassExtends	add=phpClassExtendsNameComment
syntax cluster phpClClassImplements	add=phpClassImplementsNameComment

call s:DefineCustomCommentBlock('phpClassAbstractComment',		'phpClass')
call s:DefineCustomCommentBlock('phpClassComment',			'phpClassName')
call s:DefineCustomCommentBlock('phpClassNameComment',		'@phpClClass')
call s:DefineCustomCommentBlock('phpClassExtendsComment',		'phpClassExtendsName')
call s:DefineCustomCommentBlock('phpClassExtendsNameComment',	'@phpClClassExtends')
call s:DefineCustomCommentBlock('phpClassImplementsComment',		'phpClassImplementsName')
call s:DefineCustomCommentBlock('phpClassImplementsNameComment',	'@phpClClassImplements')
call s:DefineCustomCommentBlock('phpClassImplementsCommaComment',	'phpClassImplementsName')
	" }}}

	" Class content {{{
syntax cluster phpClClassContent add=phpComment

		" CONSTANT: const FOO = 'bar'; {{{
syntax keyword phpClassConst contained nextgroup=phpClassConstName,phpClassConstComment skipwhite skipempty const
syntax match phpClassConstName contained nextgroup=@phpClAffectationSimple skipwhite skipempty /\(\h\|_\)\w*/

call s:DefineCustomCommentBlock('phpClassConstComment','phpClassConstName')

highlight link phpClassConst	phpStructure

syntax cluster phpClClassContent add=phpClassConst,phpError
		" }}}
	" }}}
" }}}

" AFFECTATION: = XXX {{{
	" = {{{ 
call s:DefineCustomCommentBlock('phpAffectationSimpleComment',	'phpAffectationSimple')
call s:DefineCustomCommentBlock('phpAffectationComment',		'phpAffectation')

syntax match phpAffectationSimple contained nextgroup=@phpClAffectationValueSimple skipwhite skipempty /=/
syntax match phpAffectation       contained nextgroup=@phpClAffectationValue       skipwhite skipempty /=/

highlight link phpAffectationSimple	phpOperator
highlight link phpAffectation		phpOperator

syntax cluster phpClAffectationSimple add=phpAffectationSimple,phpAffectationSimpleComment
syntax cluster phpClAffectation       add=phpAffectation,phpAffectationComment
	" }}}
	" XXX {{{
syntax cluster phpClAffectationValueSimple add=@phpClNumber

syntax cluster phpClAffectationValue contains=@phpClAffectationValueSimple
	" }}}
" }}}

" NUMBER: {{{
	" SIGN: +- {{{
syntax match phpNumberSign contained nextgroup=@phpClNumberValue skipwhite skipempty /[+-]/

call s:DefineCustomCommentBlock('phpNumberSignComment','@phpClNumberValue')
syntax cluster phpClNumberValue add=phpNumberSignComment

highlight link phpNumberSign phpOperator
	" }}}

	" INTEGER: {{{
syntax match phpNumberIntegerCommon contained nextgroup=@phpClSemicolon skipwhite skipempty /[0-9]\+\(e[+-]\?[0-9]\+\)\?/
syntax match phpNumberIntegerBinary contained nextgroup=@phpClSemicolon skipwhite skipempty /0[bB][0-1]\+/
syntax match phpNumberIntegerOctal  contained nextgroup=@phpClSemicolon skipwhite skipempty /0[0-7]\+/
syntax match phpNumberIntegerHexa   contained nextgroup=@phpClSemicolon skipwhite skipempty /0[xX][0-9a-fA-F]\+/

highlight link phpNumberIntegerCommon	phpNumberInteger
highlight link phpNumberIntegerBinary	phpNumberInteger
highlight link phpNumberIntegerOctal	phpNumberInteger
highlight link phpNumberIntegerHexa		phpNumberInteger

syntax cluster phpClNumberInteger contains=phpNumberIntegerCommon,phpNumberIntegerBinary,phpNumberIntegerOctal,phpNumberIntegerHexa
	" }}}
	" DECIMAL: {{{
syntax match phpNumberDecimal contained nextgroup=@phpClSemicolon skipwhite skipempty /[0-9]\+\.[0-9]\+/

highlight link phpNumberDecimal phpNumber
	" }}}

highlight link phpNumberInteger	phpNumber

syntax cluster phpClNumberValue	add=@phpClNumberInteger,phpNumberDecimal
syntax cluster phpClNumber		contains=phpNumberSign,@phpClNumberValue
" }}}

" COLORS {{{
highlight link phpBounds		Debug
highlight link phpError			Error
highlight link phpComment		Comment
highlight link phpOperator		Operator
highlight link phpNumber		Number

highlight link phpStructure		Structure

highlight link phpExtensionConstants	Constant
highlight link phpExtensionFunctions	Function
highlight link phpExtensionClasses		Function
" }}}

