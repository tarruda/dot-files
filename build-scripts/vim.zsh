#!/usr/bin/env zsh

# This script builds and installs vim in the home directory linked against
# python/ruby/perl installed by pyenv/rbenv/plenv respectively. Tested with
# weechat vim 7.4 

python_prefix=$(pyenv prefix)
python_lib=$(ls $python_prefix/**/libpython*.so([1]))
python_lib_dir=${python_lib:h}

ruby_prefix=$(rbenv prefix)
ruby_lib=$(ls $ruby_prefix/**/libruby*.so([1]))
ruby_lib_dir=${ruby_lib:h}

perl_prefix=$(plenv prefix)
perl_lib=$(ls $perl_prefix/**/libperl*.so([1]))
perl_lib_dir=${perl_lib:h}


DYNAMIC_PYTHON=yes DYNAMIC_RUBY=yes DYNAMIC_PERL=yes ./configure \
 	--with-features=huge --enable-gui=gnome2 --enable-pythoninterp\
 	--enable-rubyinterp --enable-perlinterp --prefix=$HOME/.user-prefixes/vim

rpath=$python_lib_dir:$ruby_lib_dir:$perl_lib_dir

LDFLAGS="-Wl,-rpath=$rpath" make

make install
