PATH=''

# path for system programs
paths=(
  # default unix paths
  /sbin
	/bin
	/usr/sbin
	/usr/bin
	/usr/games
	/usr/local/sbin
	/usr/local/bin
)

if [[ -x /bin/cygpath ]]; then
	sysroot=$(/bin/cygpath -u $SYSTEMROOT)
	# windows specific paths
  paths+=$sysroot	
	paths+=$sysroot/system32
	paths+=$sysroot/system32/wbem
  paths+=$sysroot/system32/windowspowershell/v1.0
	unset sysroot
fi

for dir in $paths; do
 if [[ -d $dir ]]; then
	 PATH="$PATH:$dir"
 fi
done

# path to user programs
paths=(
	$HOME/.git-extras/bin
	$HOME/.bin
)

for dir in $paths; do
 if [[ -d $dir ]]; then
	 PATH="$dir:$PATH"
 fi
done

prefixes_dir="$HOME/.user-prefixes"

# paths/manpaths for programs installed in home dir
if [ -d $prefixes_dir ]; then
	for dir in $prefixes_dir/*(/N); do
		if [ -d "$dir/bin" ]; then
			PATH="$dir/bin:$PATH"
		fi
		if [ -d "$dir/share/man" ]; then
			MANPATH="$dir/share/man:$MANPATH"
		fi
	done
fi

unset dir paths prefixes_dir

export PATH MANPATH
