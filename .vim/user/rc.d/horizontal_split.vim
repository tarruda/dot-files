set winminheight=0
nnoremap <silent> <C-s> :call ToggleTopSplit()<CR>
let s:TopSplitOpen = 0
fun! ToggleTopSplit()
  if s:TopSplitOpen
    :wincmd j
    :500 wincmd +
    let s:TopSplitOpen = 0
  else
    :15 wincmd -
    wincmd k
    let s:TopSplitOpen = 1
  endif
endfun

