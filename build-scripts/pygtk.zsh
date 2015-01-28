#!/bin/bash
# script for pyenv installation of pygtk3 in ubuntu 12.04
# Adapted from https://gist.github.com/mehcode/6172694

system_package_installed() {
	if ! dpkg -l | grep -q $1; then
		sudo apt-get install $1
	fi
}

python_module_installed() {
	local mod=$1
	if ! python <<- EOF
	try:
	    import $mod
	    raise SystemExit(0)
	except ImportError:
	    raise SystemExit(-1)
	EOF
	then
		return 1
	fi
}

set -e
PYGTK_PREFIX="$(pyenv prefix)"
export PATH="$PYGTK_PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PYGTK_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"

system_package_installed libcairo2-dev
system_package_installed libglib2.0-dev
system_package_installed libgirepository1.0-dev
 
# Setup variables.
CACHE="/tmp/install-pygtk-$$"
 
# Make temp directory.
mkdir -p $CACHE

# Test for py2cairo.
echo -e "\E[1m * Checking for cairo...\E[0m"
if ! python_module_installed cairo; then
    echo -e "\E[1m * Installing cairo...\E[0m"
    # Fetch, build, and install py2cairo.
    (   cd $CACHE
        curl 'http://cairographics.org/releases/py2cairo-1.10.0.tar.bz2' > "py2cairo.tar.bz2"
        tar -xvf py2cairo.tar.bz2
        (   cd py2cairo*
            touch ChangeLog
            autoreconf -ivf
            ./configure --prefix=$PYGTK_PREFIX
            make
            make install
        )
    )
fi
 
# Test for gobject.
echo -e "\E[1m * Checking for gobject...\E[0m"
if ! python_module_installed gi; then
    echo -e "\E[1m * Installing gobject...\E[0m"
    # Fetch, build, and install gobject.
    (   cd $CACHE
        curl 'http://ftp.gnome.org/pub/GNOME/sources/pygobject/3.2/pygobject-3.2.2.tar.xz' > 'pygobject.tar.xz'
        tar -xf pygobject.tar.xz
        (   cd pygobject*
            ./configure --prefix=$PYGTK_PREFIX
            make
            make install
        )
    )
fi
