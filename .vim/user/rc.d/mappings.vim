" Leader mappings
" Type ,c to clear search
nnoremap <silent> <leader>c :noh<cr>
" Move between bracket pairs using tab
" (in normal and visual mode)
nnoremap <tab> %
vnoremap <tab> % 
" Move between splits using TAB
nnoremap <C-tab> <C-w>w
" Move single lines
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
" Move selection
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
" Disable help key
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

if $TERM =~ 'tmux'
  " fix some mappings
  nnoremap <Esc>A <up>
  nnoremap <Esc>B <down>
  nnoremap <Esc>C <right>
  nnoremap <Esc>D <left>
  inoremap <Esc>A <up>
  inoremap <Esc>B <down>
  inoremap <Esc>C <right>
  inoremap <Esc>D <left>
endif
