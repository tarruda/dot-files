" Appearance settings for gvim
if has('gui_running')
  " set background=dark
  " colorscheme dark-solarized
  colorscheme darktwilight
  if g:is_windows
    set guifont=Consolas:h12
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

endif
