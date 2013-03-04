# path for system-wide programs
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin;

# user binaries
if [ -d "$HOME/.bin" ]; then
	PATH="$HOME/.bin:$PATH"
fi

# Include git-extras
if [ -d "$HOME/.git-extras/bin" ] ; then
    PATH="$HOME/.git-extras/bin:$PATH"
fi

# path for user installed programs
if [ -d "$HOME/.user-prefixes" ]; then
	for prefix in "$HOME/.user-prefixes/"*(/N); do
		if [ -d "$prefix/bin" ]; then
			PATH="$prefix/bin:$PATH"
		fi
		if [ -d "$prefix/share/man" ]; then
			MANPATH="$prefix/share/man:$MANPATH"
		fi
	done
	unset prefix
fi

export PATH MANPATH
