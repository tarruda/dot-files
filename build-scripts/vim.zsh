#!/usr/bin/env zsh
# install ubuntu dependencies:
# libncursesw5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev
# libcairo2-dev libx11-dev libxpm-dev libxt-dev

# This script builds and installs vim in the home directory linked against
# python/ruby/perl installed by pyenv/rbenv/plenv respectively. Tested with
# weechat vim 7.4 

python_prefix=$(pyenv prefix)
python_lib=$(ls $python_prefix/**/libpython*.(so|a)([1]))
python_lib_dir=${python_lib:h}
python_config_dir=${$(ls $python_lib_dir/**/config.c):h}
pushd $python_config_dir
for file in ../../libpython*; do
    ln -s $file
done
popd

ruby_prefix=$(rbenv prefix)
ruby_lib=$(ls $ruby_prefix/**/libruby*.(so|a)([1]))
ruby_lib_dir=${ruby_lib:h}

perl_prefix=$(plenv prefix)
perl_lib=$(ls $perl_prefix/**/libperl*.(so|a)([1]))
perl_lib_dir=${perl_lib:h}

rpath=$python_lib_dir:$ruby_lib_dir:$perl_lib_dir
export LDFLAGS="-Wl,-rpath=$rpath"

./configure --with-features=huge --enable-gui=gnome2 --enable-pythoninterp\
    --enable-rubyinterp --enable-perlinterp --prefix=$HOME/.user-prefixes/vim

make

make install
