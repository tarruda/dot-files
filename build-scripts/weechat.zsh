#!/usr/bin/env zsh
# This script builds and installs weechat in the home directory linked against
# python/ruby/perl installed by pyenv/rbenv/plenv respectively. Tested with
# weechat 1.0.1.
#
# This enables non-root sandboxed installation of modules needed by weechat
# python/ruby/perl plugins

python_prefix=$(pyenv prefix)
python_exec=$python_prefix/bin/python
python_lib=$(ls $python_prefix/**/libpython*.so([1]))
python_lib_dir=${python_lib:h}

ruby_prefix=$(rbenv prefix)
ruby_exec=$ruby_prefix/bin/ruby
ruby_lib=$(ls $ruby_prefix/**/libruby*.so([1]))
ruby_lib_dir=${ruby_lib:h}

perl_prefix=$(plenv prefix)
perl_exec=$perl_prefix/bin/perl
perl_lib=$(ls $perl_prefix/**/libperl*.so([1]))
perl_lib_dir=${perl_lib:h}

# patch CMakeLists.txt to enable rpath
sed -i 's/^\s*set(cmake_skip_rpath/#\0/I' CMakeLists.txt
sed -i 's/LIBPL/LIBDIR/' cmake/FindPython.cmake

src_dir=$(pwd)
build_dir=$(mktemp -d)
cd $build_dir

rpath=$python_lib_dir:$ruby_lib_dir:$perl_lib_dir

cmake_args="-DCMAKE_INSTALL_RPATH='$rpath'"
cmake_args+=" -DPREFIX=$HOME/.user-prefixes/weechat"
cmake_args+=" -DPYTHON_EXECUTABLE=$python_exec"
cmake_args+=" -DRUBY_EXECUTABLE=$ruby_exec"
cmake_args+=" -DPERL_EXECUTABLE=$perl_exec"

cmake $src_dir ${(z)cmake_args}
make
make install
