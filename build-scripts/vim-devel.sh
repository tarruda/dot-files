#!/usr/bin/env zsh

(make distclean && cd src && make autoconf)

python_prefix=$(pyenv prefix)
python_lib=$(ls $python_prefix/**/libpython*.so([1]))
python_lib_dir=${python_lib:h}
python_config_dir=${$(ls $python_lib_dir/**/config.c):h}
pushd $python_config_dir
for file in ../../libpython*; do
    ln -s $file
done
popd

ruby_prefix=$(rbenv prefix)
ruby_lib=$(ls $ruby_prefix/**/libruby*.so([1]))
ruby_lib_dir=${ruby_lib:h}

perl_prefix=$(plenv prefix)
perl_lib=$(ls $perl_prefix/**/libperl*.so([1]))
perl_lib_dir=${perl_lib:h}

rpath=$python_lib_dir:$ruby_lib_dir:$perl_lib_dir
export CFLAGS="-g -DDEBUG"
export LDFLAGS="-Wl,-rpath=$rpath"

# use 'git --update-index --assume-unchanged src/regexp.c' to ignore this
# change
sed -i 's@^/\*\s*\(\#undef\s*DEBUG\)\s*\*/\s*$@\1@' ./src/regexp.c

./configure --with-features=huge --enable-gui=gnome2 --enable-pythoninterp \
	--enable-rubyinterp --enable-perlinterp --enable-jobcontrol \
	--prefix=$HOME/.vim-development

make
