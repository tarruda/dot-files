" Some conventions used here were adapted from YouCompleteMe source code

let s:next_completion_id = 1
let s:current_completion_id = 0


function! ycm#BeginCompilation()
  if !s:ShouldAnalyzeBuffer()
    return ''
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

  call send_event(0, 'begin_compilation', data) 
endfunction


function! ycm#EndCompilation(data, result)
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
  if !s:ShouldAnalyzeBuffer()
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

  call send_event(0, 'begin_completion', data) 
  return ''
endfunction


function! ycm#EndCompletion(data, result)
  if mode() != 'i'
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


function! s:GetCompletionPosition()
  " The completion position is the start of the current identifier 
  let pos = searchpos('\i\@!', 'bn', line('.'))
  let pos[1] += 1
  return pos
endfunction


function! s:ShouldAnalyzeBuffer()
  return 1
  " if empty(&filetype) ||
  "       \ getbufvar(winbufnr(winnr()), "&buftype") ==# 'nofile' ||
  "       \ &filetype ==# 'qf'
  "   return 0
  " endif
  " return 1
endfunction

