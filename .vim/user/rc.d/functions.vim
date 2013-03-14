fun! GetFoldLevel(lnum)
  if getline(a:lnum) =~? '\v^\s*$'
    return '-1'
  endif
  let this_indent = s:IndentLevel(a:lnum)
  let next_indent = s:IndentLevel(s:NextNonBlankLine(a:lnum))
  if next_indent == this_indent
    return this_indent
  elseif next_indent < this_indent
    return this_indent
  elseif next_indent > this_indent
    return '>' . next_indent
  endif
endfun

fun! s:NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1
  while current <= numlines
    if getline(current) =~? '\v\S'
      return current
    endif
    let current += 1
  endwhile
  return -2
endfun

fun! s:IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfun

if $TERM =~ 'tmux'
  " integrate movement between tmux/vim panes/windows

  fun! TmuxMove(direction)
    " Check if we are currently focusing on a edge window.
    " To achieve that,  move to/from the requested window and
    " see if the window number changed
    let oldw = winnr()
    silent! exe 'wincmd ' . a:direction
    let neww = winnr()
    silent! exe oldw . 'wincmd'
    if oldw == neww
      " The focused window is at an edge, so ask tmux to switch panes
      if a:direction == 'j'
        call system("tmux select-pane -D")
      elseif a:direction == 'k'
        call system("tmux select-pane -U")
      elseif a:direction == 'h'
        call system("tmux select-pane -L")
      elseif a:direction == 'l'
        call system("tmux select-pane -R")
      endif
    else
      exe 'wincmd ' . a:direction
    end
  endfunction

  nnoremap <silent> <c-a>j :silent call TmuxMove('j')<cr><c-l>
  nnoremap <silent> <c-a>k :silent call TmuxMove('k')<cr><c-l>
  nnoremap <silent> <c-a>h :silent call TmuxMove('h')<cr><c-l>
  nnoremap <silent> <c-a>l :silent call TmuxMove('l')<cr><c-l>
  nnoremap <silent> <c-a><down> :silent call TmuxMove('j')<cr><c-l>
  nnoremap <silent> <c-a><up> :silent call TmuxMove('k')<cr><c-l>
  nnoremap <silent> <c-a><left> :silent call TmuxMove('h')<cr><c-l>
  nnoremap <silent> <c-a><right> :silent call TmuxMove('l')<cr><c-l>

endif
