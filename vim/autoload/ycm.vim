if !has('neovim')
  finish
endif

py import vim
let s:channel_id = pyeval('vim.channel_id')

let s:next_completion_id = 1
let s:current_completion_id = 0

let s:searched_and_results_found = 0
let s:old_cursor_position = []
let s:cursor_moved = 0
let s:moved_vertically_in_insert_mode = 0
let s:previous_num_chars_on_current_line = -1


function! ycm#StartYcmd()
  let ycmd_path = get(g:, 'ycmd_path', '')
  if &diff || !has('neovim') || ycmd_path == ''
    return
  endif
  call send_event(s:channel_id, 'vim_enter', ycmd_path)
endfunction


function! ycm#Setup()
  call s:SetupKeys()
  call s:SetupEvents()
  call s:SetupSigns()
endfunction


function! ycm#BeginCompilation()
  if !s:AllowedToCompleteInCurrentFile()
    return
  endif

  if b:changedtick == get(b:, 'last_changedtick', -1)
    return
  endif

  let b:last_changedtick = b:changedtick

  let data = {
        \ 'filetype': &filetype,
        \ 'filepath': expand('%:p'),
        \ 'contents': getline(1,'$'),
        \ 'bufnum': bufnr('%')
        \ }

  call send_event(s:channel_id, 'begin_compilation', data) 
endfunction


function! ycm#EndCompilation(data, result)
  if !s:AllowedToCompleteInCurrentFile()
    return
  endif

  let bufnum = a:data.bufnum
  let winnum = bufwinnr(bufnum)

  " Clear location list for the window, if its visible
  if winnum != -1
    call setloclist(winnum, [])
  endif

  " Clear all signs
  exe 'sign unplace * buffer=' . bufnum

  if empty(a:result)
    " Nothing else to do
    return
  endif

  " Set location list
  call setloclist(winnum, a:result)

  " Set signs
  let sign_id = 1
  for loclistitem in a:result
    let sign_name = loclistitem.type == 'E' ? 'YcmError' : 'YcmWarning'
    let lnum = loclistitem.lnum
    let col = loclistitem.col

    if lnum < 1 || lnum > line('$')
      let lnum = 1
    endif

    exe 'silent! sign place ' . sign_id
          \ . ' name=' . sign_name
          \ . ' line=' . lnum
          \ . ' buffer=' . bufnum

    let sign_id += 1
  endfor
endfunction


function! ycm#BeginCompletion()
  if !s:AllowedToCompleteInCurrentFile()
    return ''
  endif

  let s:current_completion_id = s:next_completion_id
  let s:next_completion_id += 1

  let data = {
        \ 'id': s:current_completion_id,
        \ 'position': s:GetCompletionPosition(),
        \ 'cursor': getpos('.'),
        \ 'filetype': &filetype,
        \ 'filepath': expand('%:p'),
        \ 'contents': getline(1,'$')
        \ }

  call send_event(s:channel_id, 'begin_completion', data) 
  return ''
endfunction


function! ycm#EndCompletion(data, result)
  if mode() != 'i' || !s:AllowedToCompleteInCurrentFile()
    " Not in insert mode, ignore
    return
  endif

  let completion_id = a:data.id
  if s:current_completion_id != completion_id
    " Completion expired
    return
  endif

  let completion_pos = a:data.position
  let current_pos = s:GetCompletionPosition()
  if current_pos[0] != completion_pos[0] || current_pos[1] != completion_pos[1]
    " Completion position changed 
    return
  endif

  if empty(a:result)
    return
  endif

  call complete(completion_pos[1], a:result)
  " Like YCM, do not select the first match automatically
  call feedkeys("\<c-p>", 'n')
endfunction


function! s:SetupKeys()
  if !empty(g:ycm_key_compile)
    let invoke_key = g:ycm_key_compile
    silent! exe 'nnoremap <silent>' . invoke_key . ' :call ycm#BeginCompilation()<cr>'
  endif

  if !empty(g:ycm_key_invoke_completion)
    let invoke_key = g:ycm_key_invoke_completion

    if invoke_key ==# '<C-Space>'
      let invoke_key = '<nul>'
    endif

    silent! exe 'inoremap ' . invoke_key . ' <c-r>=ycm#BeginCompletion()<cr>'
  endif

  for key in g:ycm_key_list_select_completion
    exe 'inoremap <expr>' . key . ' pumvisible() ? "\<c-n>" : "\' . key .'"'
  endfor

  for key in g:ycm_key_list_previous_completion
    exe 'inoremap <expr>' . key . ' pumvisible() ? "\<c-p>" : "\' . key .'"'
  endfor
endfunction


function! s:SetupEvents()
  augroup ycm
    autocmd!
    autocmd CursorMovedI * call s:OnCursorMovedInsertMode()
    autocmd CursorMoved * call s:OnCursorMovedNormalMode()
    autocmd InsertLeave * call s:OnInsertLeave()
    autocmd InsertEnter * call s:OnInsertEnter()
    autocmd BufUnload * call s:OnBufferUnload(expand('<afile>:p'))
    autocmd VimLeavePre * call s:OnVimLeavePre()
    " autocmd BufRead,BufEnter,FileType * call s:OnBufferVisit()
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


function! s:OnBufferUnload(deleted_buffer_file)
  if !s:AllowedToCompleteInCurrentFile() || empty(a:deleted_buffer_file)
    return
  endif

  call send_event(s:channel_id, 'buffer_unload', a:deleted_buffer_file)
endfunction


function! s:OnCursorMovedInsertMode()
  if !s:AllowedToCompleteInCurrentFile()
    return
  endif

  call s:UpdateCursorMoved()

  " Basically, we need to only trigger the completion menu when the user has
  " inserted or deleted a character, NOT just when the user moves in insert
  " mode (with, say, the arrow keys). If we trigger the menu even on pure
  " moves, then it's impossible to move in insert mode since the up/down arrows
  " start moving the selected completion in the completion menu. Yeah, people
  " shouldn't be moving in insert mode at all (that's what normal mode is for)
  " but explain
  " that to the users who complain...
  if !s:BufferTextChangedSinceLastMoveInInsertMode()
    return
  endif

  if g:ycm_auto_trigger || s:omnifunc_mode
    call ycm#BeginCompletion()
  endif
endfunction


function! s:OnCursorMovedNormalMode()
  if !s:AllowedToCompleteInCurrentFile()
    return
  endif

  call ycm#BeginCompilation()
endfunction


function! s:OnInsertLeave()
  if !s:AllowedToCompleteInCurrentFile()
    return
  endif

  let s:omnifunc_mode = 0
  call ycm#BeginCompilation()
  if g:ycm_autoclose_preview_window_after_completion ||
        \ g:ycm_autoclose_preview_window_after_insertion
    call s:ClosePreviewWindowIfNeeded()
  endif
endfunction


function! s:OnInsertEnter()
  if !s:AllowedToCompleteInCurrentFile()
    return
  endif

  let s:old_cursor_position = []
endfunction


function! s:OnVimLeavePre()
  call send_event(s:channel_id, 'vim_leave', 0)
endfunction


function! s:UpdateCursorMoved()
  let current_position = getpos('.')
  let s:cursor_moved = current_position != s:old_cursor_position

  let s:moved_vertically_in_insert_mode = s:old_cursor_position != [] &&
        \ current_position[ 1 ] != s:old_cursor_position[ 1 ]

  let s:old_cursor_position = current_position
endfunction


function! s:BufferTextChangedSinceLastMoveInInsertMode()
  if s:moved_vertically_in_insert_mode
    let s:previous_num_chars_on_current_line = -1
    return 0
  endif

  let num_chars_in_current_cursor_line = strlen( getline('.') )

  if s:previous_num_chars_on_current_line == -1
    let s:previous_num_chars_on_current_line = num_chars_in_current_cursor_line
    return 0
  endif

  let changed_text_on_current_line = num_chars_in_current_cursor_line !=
        \ s:previous_num_chars_on_current_line
  let s:previous_num_chars_on_current_line = num_chars_in_current_cursor_line

  return changed_text_on_current_line
endfunction


function! s:ClosePreviewWindowIfNeeded()
  let current_buffer_name = bufname('')

  " We don't want to try to close the preview window in special buffers like
  " "[Command Line]"; if we do, Vim goes bonkers. Special buffers always start
  " with '['.
  if current_buffer_name[ 0 ] == '['
    return
  endif

  if s:searched_and_results_found
    " This command does the actual closing of the preview window. If no preview
    " window is shown, nothing happens.
    pclose
  endif
endfunction


function! s:GetCompletionPosition()
  " The completion position is the start of the current identifier 
  let pos = searchpos('\i\@!', 'bn', line('.'))
  let pos[1] += 1
  return pos
endfunction


function! s:AllowedToCompleteInCurrentFile()
  if empty(&filetype) ||
        \ getbufvar(winbufnr(winnr()), "&buftype") ==# 'nofile' ||
        \ &filetype ==# 'qf'
    return 0
  endif

  let whitelist_allows = has_key( g:ycm_filetype_whitelist, '*' ) ||
        \ has_key( g:ycm_filetype_whitelist, &filetype )
  let blacklist_allows = !has_key( g:ycm_filetype_blacklist, &filetype )

  return whitelist_allows && blacklist_allows
endfunction


