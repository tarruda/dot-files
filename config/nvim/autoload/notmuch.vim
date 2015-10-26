python << EOF
import sys, vim
sys.path.append(vim.eval("expand('<sfile>:p:h')") + '/lib/')
from notmuch_vim import render_folders, render_threads
EOF

function! notmuch#NotmuchRun()
  call s:InitLayout()
endfunction

function! s:InitLayout()
  call s:NewBuffer('threads')
python << EOF
render_threads()
EOF
  setl nosplitright
  30 vsp 
  call s:NewBuffer('folders')
python << EOF
render_folders()
EOF
endfunction

function! s:NewBuffer(type)
  enew
  setlocal buftype=nofile bufhidden=hide
  keepjumps 0d
  execute 'set filetype=notmuch-'.a:type
  execute 'set syntax=notmuch-'.a:type
endfunction

