#!/usr/bin/env zsh

if ! which dmcs > /dev/null 2>&1; then
 	sudo apt-get install mono-dmcs
fi

if ! which xbuild > /dev/null 2>&1; then
 	sudo apt-get install mono-xbuild
fi

python_prefix=$(pyenv prefix)
libpython=$(ls $python_prefix/lib/*.so([1]))
python_include=$(ls $python_prefix/include/**/Python.h([1]))
python_include=${python_include:h}

cd $DOTDIR/vim/addons/github-Valloric-YouCompleteMe

git submodule update --init --recursive
echo $python_include

EXTRA_CMAKE_ARGS="-DPYTHON_LIBRARY=$libpython"
EXTRA_CMAKE_ARGS+=" -DPYTHON_INCLUDE_DIR=$python_include"
EXTRA_CMAKE_ARGS+=" -DEXTRA_RPATH=$python_prefix/lib" 

EXTRA_CMAKE_ARGS=$EXTRA_CMAKE_ARGS ./install.sh --clang-completer --omnisharp-completer
