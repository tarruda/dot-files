" Close VIM if NERDTree is the only buffer left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" Toggle NERDTree
nnoremap <silent> <F2> :NERDTreeToggle<CR>
