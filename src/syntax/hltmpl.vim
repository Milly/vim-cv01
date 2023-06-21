" File: src/syntax/hltmpl.vim
" Description: Syntax for Colorscheme template
" Author: Milly
" License: MIT
" --------------------------------------------------------------------------

if get(b:, 'current_syntax', '') isnot# 'vim'
  finish
endif

syn keyword genCommand File EndFile A Hi containedin=vimUsrCmd
syn region genEval matchgroup=genEvalBrackets start=/${/ end=/}/
      \ containedin=ALL contains=TOP keepend
syn keyword genHelperVar fgNone bgNone sNone sBold sItalic sReverse sUndercurl sUnderline

hi! default link genCommand SpecialChar
hi! default link genEvalBrackets SpecialChar
hi! default link genHelperVar Structure
