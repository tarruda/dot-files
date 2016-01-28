# Title: zprofile
# Author: Thiago de Arruda (github.com/tarruda)
# Description:
#   This file is sourced by zsh when started as a login shell(-l) but before
#   .zshrc is sourced. Environment initialization code can be put here.

# Paths for programs/libraries/manpages {{{

PATH=''
paths=(
# default unix paths
/usr/local/sbin
/usr/local/bin
/usr/sbin
/usr/bin
/sbin
/bin
/usr/games
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
paths=()
for dir in $paths; do
	if [[ -d $dir ]]; then
		PATH="$dir:$PATH"
	fi
done
prefixes_dir="$HOME/.opt"
# paths/manpaths for programs installed in home dir
if [[ -d $prefixes_dir ]]; then
	for dir in "$prefixes_dir"/*; do
		dir=${dir:A}
		if [ -d "$dir/bin" ]; then
			PATH="$dir/bin:$PATH"
		fi
		if [[ -d "$dir/share/man" ]]; then
			MANPATH="$dir/share/man:$MANPATH"
		fi
		if [[ -d "$dir/lib" ]]; then
			LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$dir/lib"
		fi
		if [[ -d "$dir/lib/pkgconfig" ]]; then
			PKG_CONFIG_PATH="$dir/lib/pkgconfig:$PKG_CONFIG_PATH"
		fi
	done
fi
unset dir paths prefixes_dir
export PATH MANPATH LD_LIBRARY_PATH PKG_CONFIG_PATH

# }}}
# Environment {{{

export LANG=en_US.UTF-8
export INPUTRC=$DOTDIR/.inputrc
export PYTHONSTARTUP=$DOTDIR/.pythonrc
export WINEARCH=win32
export WINEPREFIX=$HOME/.wine
export EDITOR=vim
export VISUAL=vim
export XDG_CONFIG_HOME=$DOTDIR/config
export VIMINIT="source $XDG_CONFIG_HOME/nvim/init.vim"
# Thanks this article for the following two environment variables
# http://my.opera.com/CrazyTerabyte/blog/2010/11/04/how-x11-xcompose-works
export GTK_IM_MODULE=cedilla
export QT_IM_MODULE=cedilla
export GPGKEY=F5EC672E
export EMAIL='tpadilha84@gmail.com'
if which vim &> /dev/null; then
	read PAGER <<- EOF
	zsh -c \"col -b -x | vim -R \
		--cmd 'let g:disable_plugins = 1' \
		-c 'set nomod nolist nomodifiable' \
		-c 'set nonumber norelativenumber' \
		-c 'map q :q<cr>' \
		-c 'map <space> <c-d>' \
		-c 'map b <c-u>' -\"
	EOF
	export PAGER
fi

# }}}
# SSH/GnuPG {{{

# install some basic ssh configuration
if [[ ! -e "$HOME/.ssh" ]]; then
	mkdir -m 700 "$HOME/.ssh"
fi 
if [ ! -e "$HOME/.ssh/config" ]; then
	cat > "$HOME/.ssh/config" <<- EOF
	ServerAliveInterval 60
	ServerAliveCountMax 2
	EOF
fi

if which gpg-agent &> /dev/null; then
	# Use ssh-add once to add an ssh key to the list of keys managed by
	# gnupg-agent
	if ! ps -C gpg-agent &> /dev/null; then
		ttl=2592000 # 1 month
		gpg-agent --daemon --enable-ssh-support \
			--write-env-file $HOME/.gpg-agent-env \
			--default-cache-ttl $ttl \
			--default-cache-ttl-ssh $ttl \
			--max-cache-ttl $ttl \
			--max-cache-ttl-ssh $ttl
	fi
	if [[ -r $HOME/.gpg-agent-env ]]; then
		. $HOME/.gpg-agent-env > /dev/null
		export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
	fi
elif which ssh-agent &> /dev/null; then
	# ensure ssh agent is running
	if ! ps -C ssh-agent &> /dev/null; then
		ssh-agent > $HOME/.ssh-env
	fi
	if [[ -r $HOME/.ssh-env ]]; then
		. $HOME/.ssh-env > /dev/null
	fi
fi

# }}}
# Site initialization {{{
# put site-specific configuration(not version controlled) in .site-zprofile
if [[ -r $ZDOTDIR/.site-zprofile ]]; then
	source $ZDOTDIR/.site-zprofile
fi
# }}}
# path to user programs
export PATH="$DOTDIR/bin:$HOME/bin:$HOME/.bin:$PATH"
