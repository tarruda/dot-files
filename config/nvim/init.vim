" Plugins {{{
function! VimrcLoadPlugins()
  " Install vim-plug if not available {{{
  if !isdirectory(g:vim_plug_dir)
    call mkdir(g:vim_plug_dir, 'p')
  endif
  if !isdirectory(g:vim_plug_dir.'/autoload')
    execute '!git clone git://github.com/junegunn/vim-plug '
          \ shellescape(g:vim_plug_dir.'/autoload', 1)
  endif
  " }}}
  call plug#begin()
  " Misc {{{
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-unimpaired'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-vinegar'
  Plug 'tpope/vim-eunuch'
  Plug 'Shougo/vinarise.vim'
  Plug 'Valloric/python-indent'
  Plug 'vim-scripts/DrawIt'
  Plug 'altercation/vim-colors-solarized'
  Plug 'rking/ag.vim'
  Plug 'danro/rename.vim'
  " Plug 'kchmck/vim-coffee-script'
  Plug 'pangloss/vim-javascript'
  Plug 'jimmyhchan/dustjs.vim'
  Plug 'mxw/vim-jsx'
  Plug 'leafgarland/typescript-vim'
  Plug 'digitaltoad/vim-jade'
  Plug 'nicklasos/vim-jsx-riot'
  Plug 'takac/vim-hardtime'
  " }}}
  " FZF {{{
  " let fzf_command = '((git ls-files && git ls-files --exclude-standard --cached --others 2> /dev/null)'  " git
  " let fzf_command .= ' || (hg manifest --all 2> /dev/null)'  " mercurial
  " let fzf_command .= ' || (bzr ls --versioned --recursive 2> /dev/null)'  " bzr
  " let fzf_command .= ' || (find -type d -name ".svn" -prune -o \( -type f -o -type l \) -print | cut -c3-)) | sort | uniq'  " svn and normal directories
  " let $FZF_DEFAULT_COMMAND=fzf_command
  let $FZF_DEFAULT_COMMAND='ag -l -g ""'
  let g:fzf_layout = { 'down': '~40%' }
  nnoremap <silent> <c-p> :FZF<cr>
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
  Plug 'junegunn/fzf.vim'
  " }}}
  " Neomake {{{
  Plug 'benekastah/neomake'
  let g:neomake_verbose = 0
  augroup Neomake
    au!
    au! BufWritePost * Neomake
  augroup END
  " }}}
  " UltiSnips {{{
  if g:has_python
    let g:UltiSnipsEditSplit = 'normal'
    let g:UltiSnipsSnippetsDir = g:rc_dir . '/UltiSnips'
    let g:UltiSnipsExpandTrigger="<c-s>"
    " let g:UltiSnipsJumpForwardTrigger="<leader>n"
    " let g:UltiSnipsJumpBackwardTrigger="<leader>p"
    " let g:UltiSnipsListSnippets="<c-tab>"
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
  endif
  " }}}
  " undotree {{{
  Plug 'mbbill/undotree'
  nnoremap <leader>u :UndotreeToggle<cr>
  " }}}
  " Project-local vimrc {{{
  Plug 'MarcWeber/vim-addon-local-vimrc'
  let g:local_vimrc = {
        \ 'names': ['.lvimrc'],
        \ 'hash_fun': 'LVRHashOfFile'
        \ }
  " }}}
  " YouCompleteMe {{{
  if g:has_python
    " let g:ycm_path_to_python_interpreter = s:cpython_path
    let g:ycm_auto_trigger = 1
    au FileType c,cpp nnoremap <buffer> <c-]> :YcmCompleter GoToDefinitionElseDeclaration<CR>
    Plug 'Valloric/YouCompleteMe'
  endif
  " }}}
  " gnupg {{{
  
  " Small help since the plugin doesn't bundle documentation
  "
  " Commands: 

  " :GPGEditRecipients 
  "   Opens a scratch buffer to change the list of recipients. Recipients that 
  "   are unknown (not in your public key) are highlighted and have 
  "   a prepended "!". Closing the buffer makes the changes permanent. 

  " :GPGViewRecipients 
  "   Prints the list of recipients. 

  " :GPGEditOptions 
  "   Opens a scratch buffer to change the options for encryption (symmetric, 
  "   asymmetric, signing). Closing the buffer makes the changes permanent. 
  "   WARNING: There is no check of the entered options, so you need to know 
  "   what you are doing. 

  " :GPGViewOptions 
  "   Prints the list of options. 
  "
  " Configuration:
  " "(Defaults are commented)
  "
  " let g:GPGExecutable = 'gpg'
  " let g:GPGUseAgent = 1
  let g:GPGPreferSymmetric = 1
  let g:GPGPreferArmor = 1
  " let g:GPGPreferSign = 0
  let g:GPGDefaultRecipients = ["Thiago de Arruda <tpadilha84@gmail.com>"]
  let g:GPGUsePipes = 1
  " let g:GPGHomeDir = '~/.gnupg'
 
  Plug 'jamessan/vim-gnupg'
  " }}}
  " zoomwintab {{{
  let g:zoomwintab_remap = 0
  Plug 'troydm/zoomwintab.vim'
  " }}}
  " Fugitive {{{
  nnoremap <leader>gs :Gstatus<cr>
  nnoremap <leader>gd :Gdiff<cr>
  nnoremap <leader>gb :Gblame<cr>
  nnoremap <leader>gw :Gwrite
  nnoremap <leader>gr :Gread
  nnoremap <leader>dp :diffput<cr>:diffupdate<cr>
  vnoremap <leader>dp :diffput<cr>:diffupdate<cr>
  nnoremap <leader>dg :diffget<cr>:diffupdate<cr>
  vnoremap <leader>dg :diffget<cr>:diffupdate<cr>
  Plug 'tpope/vim-fugitive'
  " }}}
  call plug#end()
endfunction

" }}}
" Mappings {{{

function! VimrcLoadMappings()
  " Misc {{{
  let g:mapleader = ","
  " execute the current line or selection
  nnoremap <silent> <leader>t "ryy:@r<cr>
  vnoremap <silent> <leader>t "rygv:@r<cr>
  " toggle spell on/off
  nnoremap <silent> <leader>s :set spell!<cr>
  " edit vimrc
  nnoremap <leader>e :e $MYVIMRC<cr>
  " clear search highlight with ,c
  nnoremap <silent> <leader>c :noh<cr>
  " search/replace the word under the cursor
  nnoremap <leader>z :let @z = expand("<cword>")<cr>q:i%s/\C\v<<esc>"zpa>//g<esc>hi
  " help
  inoremap <f1> <esc>:help 
  nnoremap <f1> <esc>:help 
  vnoremap <f1> <esc>:help 
  " move text up/down
  nnoremap <silent> <c-j> :m .+1<cr>==
  nnoremap <silent> <c-k> :m .-2<cr>==
  vnoremap <silent> <c-j> :m '>+1<cr>gv=gv
  vnoremap <silent> <c-k> :m '<-2<cr>gv=gv
  " }}}
  " Editing {{{
  nnoremap <leader>gf :e <cfile><cr>
  " }}}
  " Quickfix/location list {{{
  augroup quick_loc_list
    au! BufWinEnter quickfix nnoremap <silent> <buffer>
          \	q :cclose<cr>:lclose<cr>
  augroup END
  nnoremap <silent> <leader>q :botright copen 10<cr>
  nnoremap <silent> <leader>l :botright lopen 10<cr>
  " }}}
  " Window/buffer navigation and manipulation {{{
  nnoremap <leader>e :e $MYVIMRC<cr>
  " zoom with <c-w>z in any mode
  nnoremap <silent> <c-w>z :ZoomWinTabToggle<cr>
  inoremap <silent> <c-w>z <c-\><c-n>:ZoomWinTabToggle<cr>a
  vnoremap <silent> <c-w>z <c-\><c-n>:ZoomWinTabToggle<cr>gv
  if has('nvim') && exists(':tnoremap')
    tnoremap <c-w>j <c-\><c-n><c-w>j
    tnoremap <c-w>k <c-\><c-n><c-w>k
    tnoremap <c-w>h <c-\><c-n><c-w>h
    tnoremap <c-w>l <c-\><c-n><c-w>l
    tnoremap <pageup> <c-\><c-n><pageup>
    tnoremap <pagedown> <c-\><c-n><pagedown>
    tnoremap <silent> <c-w>z <c-\><c-n>:ZoomWinTabToggle<cr>
  endif
  " }}}
  " REPL integration {{{
  nnoremap <silent> <f6> :REPLSendLine<cr>
  vnoremap <silent> <f6> :REPLSendSelection<cr>
  " }}}
endfunction

" }}}
" Settings {{{

function! VimrcLoadSettings()
  set backspace=indent,eol,start " backspace over everything in insert mode
  set nobackup " no need for backup files(use undo files instead)
  set undofile " create '.<FILENAME>.un~' for persiting undo history
  set dir=.,/tmp " swap files storage, first try in the cwd then in /tmp
  set undodir=. " undo files storage, only allow the same directory
  set history=500 " 500 lines of command-line history
  set mouse=a " enable mouse
  set noerrorbells visualbell t_vb= " disable annoying terminal sounds
  set encoding=utf-8 " universal text encoding, compatible with ascii
  set noequalalways
  set list
  set listchars=tab:▸\ ,extends:❯,precedes:❮ " ,eol:¬
  set showbreak=↪
  set fillchars=diff:⣿,vert:│
  set showcmd " display incomplete commands
  set completeopt=menu,menuone,longest " disable preview scratch window
  set complete=.,w,b,u,t " h: 'complete'
  set pumheight=15 " limit completion menu height
  set nonumber " don't display line numbers on the left
  set relativenumber " shows relative line numbers for easy motions

  set expandtab " expand tabs into spaces
  set softtabstop=2 " number of spaces used with tab/bs
  set tabstop=2 " display tabs with the width of two spaces
  set shiftwidth=2 " indent with two spaces 
  set ignorecase " ignore case when searching
  set smartcase " disable 'ignorecase' if search pattern has uppercase characters
  set incsearch " highlight matches while typing search pattern
  set hlsearch " highlight previous search matches
  set showmatch " briefly jump to the matching bracket on insert
  set matchtime=2 " time in decisecons to jump back from matching bracket 
  if !exists('g:vimpager')
    set textwidth=80 " number of character allowed in a line
  endif
  set wrap " automatically wrap text when 'textwidth' is reached
  set foldmethod=indent " by default, fold using indentation
  set nofoldenable " don't fold by default
  set foldlevel=0 " if fold everything if 'foldenable' is set
  set foldnestmax=10 " maximum fold depth
  set synmaxcol=500 " maximum length to apply syntax highlighting
  set timeout " enable timeout of key codes and mappings(the default)
  set timeoutlen=3000 " big timeout for key sequences
  set ttimeoutlen=10 " small timeout for key sequences since these will be normally scripted
  if $DISABLE_UNNAMED_CLIP != '1'
    set clipboard+=unnamedplus
  endif
  set backupskip=/tmp/*,/private/tmp/* " make it possible to use vim to edit crontab
  augroup global_settings
    au!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  augroup END
endfunction

" }}}
" File type settings {{{
function! VimrcLoadFiletypeSettings()
  augroup filetype_settings
    au!
    " my vimrc may not have the usual path
    au BufNewFile,BufRead $MYVIMRC setl filetype=vim
    " html with mustaches
    au  BufNewFile,BufRead *.html.mustache,*.html.handlebars,*.html.hbs,*.html.hogan,*.html.hulk setl filetype=html.mustache
    " extra zsh files without extensions 
    au BufNewFile,BufRead $ZDOTDIR/functions/**/* setl filetype=zsh
    au BufNewFile,BufRead $ZDOTDIR/completion-functions/* setl filetype=zsh
    au BufNewFile,BufRead $ZDOTDIR/plugins/**/functions/* setl filetype=zsh
    " riot/jsx
    au BufNewFile,BufRead *.riot.tag setlocal ft=javascript
    " Coffeescript {{{
    au FileType coffee
          \   setl foldmethod=marker
          \ | setl foldenable
    " }}}
    " Html {{{
    au BufNewFile,BufRead *.ejs set filetype=html
    au FileType html
          \   setl foldmethod=marker
          \ | setl foldenable
    " }}}
    " Vim {{{
    au FileType vim
          \   setl foldmethod=marker
          \ | setl foldenable
    " }}}
    " C/C++ {{{
    au FileType c,cpp
          \   nnoremap <buffer> <silent> <leader>ff :call Uncrustify('c')<cr>
          \ | setl commentstring=//%s
    " }}}
    " Moonscript {{{
    au FileType moon
          \   setl commentstring=--%s
    " }}}
    " Zsh/sh {{{
    au FileType sh,bash,zsh setl noexpandtab
    au FileType zsh 
          \   runtime! indent/sh.vim
          \ | setl foldmethod=marker
          \ | setl foldenable
    " }}}
    " Haskell {{{
    au FileType haskell
          \   setl softtabstop=4
          \ | setl shiftwidth=4
          \ | setl textwidth=75
          \ | nnoremap <buffer> <leader>h :Hoogle 

    " }}}
    " Nasm {{{
    au FileType nasm 
          \   setl softtabstop=4
          \ | setl shiftwidth=4 
          \ | setl textwidth=150
    " }}}
    " Python {{{
    au FileType python 
          \   setl softtabstop=4
          \ | setl shiftwidth=4 
          \ | setl textwidth=79
    command! DocTest !python -m doctest %
    " }}}
    " Mail {{{
    au FileType man 
          \   setl foldmethod=indent
          \ | setl foldenable
          \ | setl foldnestmax=1
    " }}}
  augroup END
endfunction
" }}}
" Colors {{{
function! VimrcLoadColors()
  set background=dark
  if $TERM =~ 'screen-256color' || $TERM =~ 'rxvt-unicode-256color' || $TERM =~ 'xterm-256color'
    colorscheme twilight-term256
    " for tmux, this will only work if the client terminal supports italic
    " escape sequences
    highlight Comment cterm=italic
  endif
  highlight ColorColumn ctermbg=235 guibg=#2c2d27
  let &colorcolumn='+'.join(range(1,200),",+")
endfunction
" }}}
" Terminal {{{
if has('nvim')
  augroup Terminal
    au!
    au TermOpen * let g:last_terminal_job_id = b:terminal_job_id
    au WinEnter term://* startinsert
  augroup END
endif
let g:terminal_color_0  = '#2e3436'
let g:terminal_color_1  = '#cc0000'
let g:terminal_color_2  = '#4e9a06'
let g:terminal_color_3  = '#c4a000'
let g:terminal_color_4  = '#3465a4'
let g:terminal_color_5  = '#75507b'
let g:terminal_color_6  = '#0b939b'
let g:terminal_color_7  = '#d3d7cf'
let g:terminal_color_8  = '#555753'
let g:terminal_color_9  = '#ef2929'
let g:terminal_color_10 = '#8ae234'
let g:terminal_color_11 = '#fce94f'
let g:terminal_color_12 = '#729fcf'
let g:terminal_color_13 = '#ad7fa8'
let g:terminal_color_14 = '#00f5e9'
let g:terminal_color_15 = '#eeeeec'
" }}}
" Functions {{{
function! s:GetVisual()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - 2]
  let lines[0] = lines[0][col1 - 1:]
  return lines
endfunction

function! REPLSend(lines)
  call jobsend(g:last_terminal_job_id, add(a:lines, ''))
endfunction
" }}}
" Commands {{{
" REPL integration {{{
command! -range=% REPLSendSelection call REPLSend(s:GetVisual())
command! REPLSendLine call REPLSend([getline('.')])
" }}}
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.  Only define it when not
" defined already.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
      \ | wincmd p | diffthis
" }}}
" Initialization {{{
call VimrcLoadMappings()
if !exists('g:vimrc_initialized')
  let g:is_windows = has('win32') || has('win64')
  " Little hack to set the $MYVIMRC from the $VIMINIT in the case it was used to 
  " initialize vim.
  if empty($MYVIMRC)
    let $MYVIMRC = substitute($VIMINIT, "^source ", "", "g")
  endif
  " Extract the directory from $MYVIMRC
  let g:rc_dir = strpart($MYVIMRC, 0, strridx($MYVIMRC, (g:is_windows ? '\' : '/')))
  let $RCDIR = g:rc_dir
  let g:plugins_dir = g:rc_dir.'/plugged'
  let g:vim_plug_dir = g:plugins_dir.'/vim-plug'
  let &runtimepath = g:rc_dir.','.g:vim_plug_dir.','.$VIMRUNTIME
  if !exists('g:vimpager')
    let g:has_python = has('python')
    call VimrcLoadPlugins()
  else
    call plug#begin()
    " only load vim-sensible
    Plug 'tpope/vim-sensible'
    call plug#end()
  endif
  let g:vimrc_initialized = 1
endif
call VimrcLoadSettings()
call VimrcLoadFiletypeSettings()
call VimrcLoadColors()
" }}}
