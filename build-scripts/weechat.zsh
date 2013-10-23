#!/usr/bin/env zsh
# This script builds and installs weechat in the home directory linked against
# python/ruby/perl provided by pyenv/rbenv/plenv respectively. Tested with
# weechat 4.2.
#
# This enables sandboxed installation modules needed by weechat plugins

python_prefix=$(pyenv prefix)
python_lib=$(ls $python_prefix/**/libpython*.so([1]))
python_lib_dir=${python_lib:h}
python_include=$(ls $python_prefix/**/Python.h([1]))
python_include_dir=${python_include:h}
python_exec=$python_prefix/bin/python
python_lflags=$($python_exec -c "import sys; from distutils.sysconfig import *; sys.stdout.write(get_config_var('LINKFORSHARED'))")

ruby_prefix=$(rbenv prefix)
ruby_lib=$(ls $ruby_prefix/**/libruby*.so([1]))
ruby_lib_dir=${ruby_lib:h}
ruby_include=$(ls $ruby_prefix/**/ruby.h([1]))
ruby_include_dir=${ruby_include:h}
ruby_exec=$ruby_prefix/bin/ruby
ruby_arch=$($ruby_exec -r rbconfig -e "print RbConfig::CONFIG['arch']")
ruby_arch=$ruby_include_dir/$ruby_arch

perl_prefix=$(plenv prefix)
perl_lib=$(ls $perl_prefix/**/libperl*.so([1]))
perl_lib_dir=${perl_lib:h}
perl_include=$(ls $perl_prefix/**/perl.h([1]))
perl_include_dir=${perl_include:h}
perl_prefix=$(plenv prefix)

rpath="$python_lib_dir:$ruby_lib_dir:$perl_lib_dir"

cmake_args="-DPYTHON_FOUND=true"
cmake_args+=" -DPYTHON_LIBRARY=$python_lib"
cmake_args+=" -DPYTHON_INCLUDE_PATH=$python_include_dir"
cmake_args+=" -DPYTHON_LFLAGS='$python_lflags'"
cmake_args+=" -DRUBY_FOUND=true"
cmake_args+=" -DRUBY_LIBRARY=$ruby_lib"
cmake_args+=" -DRUBY_INCLUDE_PATH=$ruby_include_dir"
cmake_args+=" -DRUBY_ARCH=$ruby_arch"
# cmake_args+=" -DPERL_LIBRARY=$perl_lib"
# cmake_args+=" -DPERL_INCLUDE_PATH=$perl_include_dir"

# enable rpath
sed -i 's/^\s*set(cmake_skip_rpath/#\0/I' CMakeLists.txt
# disable finding of python/ruby/perl
sed -i 's/^\s*find_package(\(python\|ruby/#\0/I' src/plugins/CMakeLists.txt

src_dir=$(pwd)
build_dir=$(mktemp -d)
cd $build_dir

prefix="$HOME/.user-prefixes/weechat"

cmake $src_dir -DPREFIX=$prefix -DCMAKE_INSTALL_RPATH=$rpath ${(z)cmake_args}
make
make install
