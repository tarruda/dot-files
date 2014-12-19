#!/bin/bash

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

# Adapted to pyenv from https://gist.github.com/mehcode/6172694
set -e
PYGTK_PREFIX="$(pyenv prefix)"
export PATH="$PYGTK_PREFIX/bin:$PATH"
 
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
            ./configure --prefix=$PYGTK_PREFIX --disable-dependency-tracking
            make
            make install
        )
    )
fi
 
# Test for gobject.
echo -e "\E[1m * Checking for gobject...\E[0m"
if ! python_module_installed gobject; then
    echo -e "\E[1m * Installing gobject...\E[0m"
    # Fetch, build, and install gobject.
    (   cd $CACHE
        curl 'http://ftp.gnome.org/pub/GNOME/sources/pygobject/2.28/pygobject-2.28.6.tar.bz2' > 'pygobject.tar.bz2'
        tar -xvf pygobject.tar.bz2
        (   cd pygobject*
            ./configure --prefix=$PYGTK_PREFIX --disable-introspection
            make
            make install
        )
    )
fi
 
# Test for gtk.
echo -e "\E[1m * Checking for gtk...\E[0m"
if ! python_module_installed gtk; then
    echo -e "\E[1m * Installing gtk...\E[0m"
    # Fetch, build, and install gtk.
    (   cd $CACHE
        curl 'https://pypi.python.org/packages/source/P/PyGTK/pygtk-2.24.0.tar.bz2' > 'pygtk.tar.bz2'
        tar -xvf pygtk.tar.bz2
        (   cd pygtk*
            ./configure --prefix=$PYGTK_PREFIX PKG_CONFIG_PATH="$PYGTK_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
            make
            make install
        )
    )
fi
