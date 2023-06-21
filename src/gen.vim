#!vim -Nu
" File: src/gen.vim
" Description: Colorscheme file generator
" Author: Milly
" License: MIT
" --------------------------------------------------------------------------

" Init: {{{1

if &compatible isnot# 0
  set nocompatible
endif

let s:is_batch = len(split(execute('scriptnames'), "\n")) is# 1
let s:src_dir = expand('<sfile>:p:h')
let s:project_dir = expand('<sfile>:p:h:h')

function! s:_reset() abort
  let s:_sp_called = 0
  let s:_sp_with_cterm = v:true
  let s:_last_sp_called = 0
  let s:_sp_objs = []
  let s:_lines = []
endfunction
call s:_reset()

" Highlight Helper: {{{1

function! s:SP(c) abort
  let s:_sp_called += 1
  if s:_sp_with_cterm
    return printf('ctermul=%s guisp=%s', a:c[0], a:c[1])
  else
    return printf('guisp=%s', a:c[1])
  endif
endfunction

let s:FG = {c -> printf('ctermfg=%s guifg=%s', c[0], c[1])}
let s:BG = {c -> printf('ctermbg=%s guibg=%s', c[0], c[1])}
let s:Style = {s -> printf('cterm=%s gui=%s', s, s)}

let s:_helpers = {
\ 'FG': s:FG,
\ 'BG': s:BG,
\ 'Style': s:Style,
\ 'SP': function('s:SP'),
\ 'fgNone': s:FG(['NONE', 'NONE']),
\ 'bgNone': s:BG(['NONE', 'NONE']),
\ 'sNone': s:Style('NONE'),
\ 'sBold': s:Style('bold'),
\ 'sItalic': s:Style('italic'),
\ 'sReverse': s:Style('reverse'),
\ 'sUndercurl': s:Style('undercurl'),
\ 'sUnderline': s:Style('underline'),
\}

" Generator Command: {{{1

function! s:_append(line, obj) abort
  let prefix = ''
  if s:_sp_called
    if s:_last_sp_called is# 0
      let s:_sp_objs = [a:obj]
      call add(s:_lines, 'if s:has_ctermul')
      let prefix = '  '
    elseif s:_last_sp_called is# s:_sp_called
      let s:_sp_with_cterm = v:false
      call add(s:_lines, 'else')
      call extend(s:_lines, map(s:_sp_objs, {_, v -> '  ' .. v.getline()}))
      call add(s:_lines, 'endif')
      let s:_sp_called = 0
      let s:_sp_with_cterm = v:true
    else
      call add(s:_sp_objs, a:obj)
      let prefix = '  '
    endif
    let s:_last_sp_called = s:_sp_called
  endif
  call add(s:_lines, prefix .. a:line)
endfunction

function! s:_eval(s, context) abort
  call extend(l:, a:context)
  return eval(a:s)
endfunction

function! s:_eval_string(s, context) abort
  return substitute(a:s, '${.\{-}}',
        \ {v -> printf('%s', s:_eval(v[0][2:-2], a:context))}, 'g')
endfunction

function! s:_eval_line(line, context) abort
  let line = s:_eval_string(a:line, a:context)
  if line is# ''
    return ''
  endif
  let foldmarker = matchstr(line, '[^{]\zs{\{3}\d\?$')
  let body = line[0 : -1 - len(foldmarker)]
  let body = substitute(body, '^|', ' ', '')
  let [body, bar] = (split(body, '\s\+\ze-*$') + [''])[:1]
  if bar isnot# ''
    let bar = range(75 - len(body) - len(foldmarker))
          \ ->map({-> '-'})->join('')
  endif
  let sep = bar is# '' && foldmarker is# '' ? '' : ' '
  return body .. sep .. bar .. foldmarker
endfunction

function! s:_eval_line_method() dict abort
  return s:_eval_line(self.line, self.context)
endfunction

function! s:_eval_args(args, context) abort
  return copy(a:args)->map({_, v -> s:_eval(v, a:context)})
        \ ->join()->s:_eval_string(a:context)
endfunction

function! s:_eval_args_method() dict abort
  return s:_eval_args(self.args, self.context)
endfunction

function! s:_new_file(name, context) abort
  let a:context.gen_file_name = s:_eval_args([a:name], a:context)
  let s:_lines = []
endfunction

function! s:_flush_file(context) abort
  call s:_append('', {})
  let s:_lines = s:_lines[0:-2]
  let fpath = s:project_dir .. '/' .. a:context.gen_file_name
  call mkdir(fnamemodify(fpath, ':h'), 'p')
  call writefile(s:_lines, fpath)
  unlet a:context.gen_file_name
endfunction

function! s:_append_line(line, context) abort
  let obj = {
  \ 'line': a:line,
  \ 'context': a:context,
  \ 'getline': function('s:_eval_line_method'),
  \}
  call s:_append(obj.getline(), obj)
endfunction

function! s:_append_args(args, context) abort
  let obj = {
  \ 'args': a:args,
  \ 'context': a:context,
  \ 'getline': function('s:_eval_args_method'),
  \}
  call s:_append(obj.getline(), obj)
endfunction

command! -buffer -nargs=1 File call s:_new_file(<q-args>, l:)
command! -buffer -nargs=0 EndFile call s:_flush_file(l:)
command! -buffer -nargs=? A call s:_append_line(<q-args>, l:)
command! -buffer -nargs=* Hi call s:_append_args(["'hi'", <f-args>], l:)

" Generate Files: {{{1

function! s:load_script(file) abort
  return readfile(a:file)->join("\n")
        \ ->substitute('\n\s*\\', '', 'g')->split("\n")
endfunction

function s:_generate_file(template) abort
  let l:gen_colorscheme_template = 1
  call s:_reset()
  call extend(l:, s:_helpers)
  echomsg s:load_script(s:src_dir .. '/defs.vim')->execute()
  call extend(l:, l:gen_palette)
  echomsg s:load_script(a:template)->execute()
endfunction

let v:errmsg = ''
try
  call glob('<sfile>:h/templates/**.vim', 1, 1)
        \ ->map({_, template -> s:_generate_file(template)})
catch
  let v:errmsg = 'Error in template: ' .. v:exception .. ' (at ' .. v:throwpoint .. ')'
  echohl ErrorMsg
  echomsg v:errmsg
  echohl None
finally
  delcommand File
  delcommand EndFile
  delcommand A
  delcommand Hi
endtry

" Post: {{{1

if s:is_batch
  if empty(v:errmsg)
    q
  else
    cq
  endif
endif
