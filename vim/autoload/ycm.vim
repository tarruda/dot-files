" Some conventions used here were adapted from YouCompleteMe source code

let s:next_completion_id = 1
let s:current_completion_id = 0


function! ycm#BeginCompilation()
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


function! ycm#EndCompilation(data)
  let result = a:data.result

  if empty(result)
    let bufnum = a:data.bufnum
    if bufwinnr(bufnum) != -1
      exe 'sign unplace * buffer=' . bufnum
    endif
    return
  endif

  let cleared = {}
  let sign_id = 1

  for diagnostic in result
    let location = diagnostic.location
    let bufnum = bufnr(location.filepath, 1)

    if bufwinnr(bufnum) == -1
      " Buffer not visible
      continue
    endif

    if !get(cleared, bufnum)
      exe 'sign unplace * buffer=' . bufnum
      let cleared[bufnum] = 1
    endif

    let sign_name = diagnostic.kind == 'ERROR' ? 'YcmError' : 'YcmWarning'

    exe 'sign place ' . sign_id
          \ . ' name=' . sign_name
          \ . ' line=' . location.line_num
          \ . ' buffer=' . bufnum

    let sign_id += 1
  endfor
endfunction


function! ycm#BeginCompletion()
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


function! ycm#EndCompletion(data)
  if mode() != 'i'
    " Not in insert mode, ignore
    return
  endif

  let completion_id = a:data['id']
  if s:current_completion_id != completion_id
    " Completion expired
    return
  endif

  let completion_pos = a:data['position']
  let current_pos = s:GetCompletionPosition()
  if current_pos[0] != completion_pos[0] || current_pos[1] != completion_pos[1]
    " Completion position changed 
    return
  endif

  call complete(completion_pos[1] + 1, a:data['result'])
  " Like YCM, do not select the first match automatically
  call feedkeys("\<c-p>")
endfunction


function! s:GetCompletionPosition()
  " The completion position is the start of the current identifier 
  return searchpos('\i\@!', 'bn', line('.'))
endfunction
