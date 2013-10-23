#!/usr/bin/env zsh

DYNAMIC_PYTHON=no DYNAMIC_RUBY=no DYNAMIC_PERL=no ./configure\
 	--with-features=huge --enable-gui=gnome2 --enable-pythoninterp\
 	--enable-rubyinterp --enable-perlinterp\
 	--prefix=$HOME/.user-prefixes/vim

make

make install
