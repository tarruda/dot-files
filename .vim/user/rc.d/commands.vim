" Allows saving files which needs root permission with ':W'. This is one of
" the forms of the ':w' command, which instead of writing to a file, takes
" all lines in a range(or the whole buffer if not range is specified) and
" pipes as standard input for the command after '!'. In this case 'tee' will
" redirect its standard input(the entire buffer) to the file being edited(%)
if !exists(":W")
  command W :w !sudo tee % > /dev/null 
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif
