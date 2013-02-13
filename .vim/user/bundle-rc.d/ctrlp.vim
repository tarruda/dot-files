set wildignore+=*.o,*.so,*.dll,*.exe,*.bak,*.swp,*.class,*.pyc,*.pyd,*.pyo,*~
set wildignore+=*.zip,*.tgz,*.gz,*.bz2,*.lz,*.rar,*.7z,*.jar

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn|bzr)|node_modules)$',
  \ }
let g:ctrlp_extensions = ['tag']
let g:ctrlp_cmd = 'Ctrlp'

fun! s:search()
  SourceLocalVimrcOnce
  CtrlP
endf

command Ctrlp call s:search()

nnoremap <silent> <leader>p :CtrlPTag<CR>
