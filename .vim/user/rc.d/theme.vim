" Appearance settings for gvim
if has('gui_running')
  " set background=dark
  " colorscheme dark-solarized
  colorscheme darktwilight
  if g:is_windows
    set guifont=Consolas:h12
  elseif has('win32unix')
    set guifont=Consolas\ 16
  else
    set guifont=Ubuntu\ Mono\ 16,Monospace\ 14
  endif
  " Remove menu bar
  set guioptions-=m
  " Remove toolbar
  set guioptions-=T
  " Remove scroll bars
  set guioptions-=lr
else
  colorscheme darktwilight-term
  if $TERM =~ 'tmux' || $TERM =~ 'rxvt-unicode-256color'
    highlight Comment cterm=italic
    set ttyfast
  endif
endif
