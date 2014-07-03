" Some conventions used here were adapted from YouCompleteMe source code

if exists("g:loaded_ycm")
  finish
endif

let g:loaded_ycm = 1

let g:ycm_key_compile =
      \ get(g:, 'ycm_key_compile', '<c-d>')

let g:ycm_key_completion_begin =
      \ get(g:, 'ycm_key_completion_begin', '<c-space>')

let g:ycm_key_completion_next =
      \ get(g:, 'ycm_key_completion_next', ['<tab>', '<down>'])

let g:ycm_key_completion_prev =
      \ get(g:, 'ycm_key_completion_prev', ['<s-tab>', '<up>'])

let g:ycm_error_symbol =
      \ get(g:, 'ycm_error_symbol',
      \ get(g:, 'syntastic_error_symbol', '>>'))

let g:ycm_warning_symbol =
      \ get(g:, 'ycm_warning_symbol',
      \ get(g:, 'syntastic_warning_symbol', '>>'))


function! g:YcmSetup()
  call s:SetupKeys()
  call s:SetupEvents()
  call s:SetupSigns()
endfunction


function! s:SetupKeys()
  if !empty(g:ycm_key_compile)
    let invoke_key = g:ycm_key_compile
    silent! exe 'nnoremap <silent>' . invoke_key . ' :call ycm#BeginCompilation()<cr>'
  endif

  if !empty(g:ycm_key_completion_begin)
    let invoke_key = g:ycm_key_completion_begin

    if invoke_key ==# '<c-space>'
      let invoke_key = '<nul>'
    endif

    silent! exe 'inoremap ' . invoke_key . ' <c-r>=ycm#BeginCompletion()<cr>'
  endif

  for key in g:ycm_key_completion_next
    exe 'inoremap <expr>' . key . ' pumvisible() ? "\<c-n>" : "\' . key .'"'
  endfor

  for key in g:ycm_key_completion_prev
    exe 'inoremap <expr>' . key . ' pumvisible() ? "\<c-p>" : "\' . key .'"'
  endfor
endfunction

function! s:SetupEvents()
  augroup ycm
    autocmd!
    " autocmd BufRead,BufEnter,FileType * call s:OnBufferVisit()
    " autocmd BufUnload * call s:OnBufferUnload(expand('<afile>:p'))
    " autocmd CursorMovedI * call s:OnCursorMoved()
  augroup END
  " call s:OnBufferVisit()
endfunction

function! s:SetupSigns()
  let g:syntastic_cpp_checkers = []
  let g:syntastic_c_checkers = []
  let g:syntastic_objc_checkers = []
  let g:syntastic_objcpp_checkers = []
  " We try to ensure backwards compatibility with Syntastic if the user has
  " already defined styling for Syntastic highlight groups.

  if !hlexists('YcmErrorSign')
    if hlexists('SyntasticErrorSign')
      highlight link YcmErrorSign SyntasticErrorSign
    else
      highlight link YcmErrorSign error
    endif
  endif

  if !hlexists('YcmWarningSign')
    if hlexists('SyntasticWarningSign')
      highlight link YcmWarningSign SyntasticWarningSign
    else
      highlight link YcmWarningSign todo
    endif
  endif

  if !hlexists('YcmErrorLine')
    highlight link YcmErrorLine SyntasticErrorLine
  endif

  if !hlexists('YcmWarningLine')
    highlight link YcmWarningLine SyntasticWarningLine
  endif

  exe 'sign define YcmError text=' . g:ycm_error_symbol .
        \ ' texthl=YcmErrorSign linehl=YcmErrorLine'
  exe 'sign define YcmWarning text=' . g:ycm_warning_symbol .
        \ ' texthl=YcmWarningSign linehl=YcmWarningLine'
endfunction


function! s:OnBufferVisit()
  call ycm#BeginCompilation()
endfunction


function! s:OnBufferUnload(file)
  call send_event(0, 'buffer_unload', a:file)
endfunction


function! s:OnCursorMoved()
endfunction


function! s:StartYcmd()
  if &diff || !has('neovim')
    return
  endif
  call send_event(0, 'waiting_for_ycmd', 0)
endfunction


augroup ycmStart
  autocmd!
  autocmd VimEnter * call s:StartYcmd()
augroup END

