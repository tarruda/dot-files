"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Title:	Vim startup file                                              "
" Author:	Thiago de Arruda                                              "
" Description:                                                                "  
"   My custom vim startup file.                                               " 
"                                                                             "
"   This script does the following:                                           "
"     1 - sets the runtimepath to ./user and ./bundle/vundle.                 "
"     2 - initalize bundles.                                                  "
"     3 - execute rc files in ./user.                                         "
"                                                                             "
"   The main purpose is organize my plugins/initialization commands and keep  "
"   each separated from third party bundles.                                  " 
"                                                                             "
"   Directory structure:                                                      "
"     ./bundle            - Third party plugins.                              "
"     ./user/rc.vim       - Vim option setup, also exec rc.d directories.     "
"     ./user/rc.d         - Role-specific(mappings, functions...) startup.    "
"     ./user/bundle-rc.d  - Bundle-specific startup.                          "
"                                                                             " 
"   Since ./user is a runtime directory, it also contains standard runtime    "
"   directories(plugin, ftplugin, syntax...).                                 "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:is_windows = has('win32') || has('win64')

" Little hack to set the $MYVIMRC from the $VIMINIT in the case it was used to 
" initialize vim.
let s:default_vimrc = 1
if empty($MYVIMRC)
  let $MYVIMRC = substitute($VIMINIT, "^source ", "", "g")
  let s:default_vimrc = 0
endif

" Extract the directory from $MYVIMRC (platform-specific)
if g:is_windows
  let g:rc_dir = strpart($MYVIMRC, 0, strridx($MYVIMRC, '\'))
else
  let g:rc_dir = strpart($MYVIMRC, 0, strridx($MYVIMRC, '/'))
endif

if s:default_vimrc
  " Set .vim as the rc_dir
  let g:rc_dir = g:rc_dir.'/.vim'
endif

let g:user_rc_dir = g:rc_dir.'/user'
let s:vundle_dir = g:rc_dir.'/bundle/vundle'
let &runtimepath = g:rc_dir.','.g:user_rc_dir.','.s:vundle_dir.','.$VIMRUNTIME

filetype off " Required

" Initialize vundle for package management
call vundle#rc()
" Required setup
Bundle 'gmarik/vundle'
" Load plugins
Bundle 'tpope/vim-repeat'
Bundle 'kien/ctrlp.vim'
Bundle 'juvenn/mustache.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kelan/gyp.vim'
Bundle 'groenewege/vim-less'
Bundle 'tpope/vim-surround'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'danro/rename.vim'
Bundle 'mattn/webapi-vim'
Bundle 'mattn/gist-vim'
" Themes
Bundle 'altercation/vim-colors-solarized'
" Snipmate
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'tomtom/tlib_vim'
Bundle 'honza/snipmate-snippets'
Bundle 'garbas/vim-snipmate'
"
Bundle 'ervandew/supertab'
Bundle 'Rip-Rip/clang_complete'
Bundle 'scrooloose/nerdtree'
Bundle 'vim-scripts/sessionman.vim'
Bundle 'MarcWeber/vim-addon-local-vimrc'
Bundle 'majutsushi/tagbar'
Bundle 'walm/jshint.vim'
Bundle 'Townk/vim-autoclose'
Bundle 'tpope/vim-fugitive'
Bundle 'bingaman/vim-sparkup'
Bundle 'vim-scripts/scratch.vim'
Bundle 'tpope/vim-commentary'
Bundle 'godlygeek/csapprox'
Bundle 'mileszs/ack.vim'
Bundle 'epeli/slimux'

" Source user settings directory
let s:user_init = g:user_rc_dir.'/rc.vim'
if filereadable(s:user_init)
  exe 'source' s:user_init
endif
