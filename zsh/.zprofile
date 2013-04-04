# Title: zprofile
# Author: Thiago de Arruda (github.com/tarruda)
# Description:
#   This file is sourced by zsh when started as a login shell(-l) but before
#   .zshrc is sourced. Environment initialization code can be put here.

# Environment {{{

export LANG=en_US.UTF-8
export VIMINIT="source $DOTDIR/vim/vimrc"
export VIMPERATOR_INIT="source $DOTDIR/vimperator/vimperatorrc"
export STARTXWINRC=$DOTDIR/.startxwinrc
export INPUTRC=$DOTDIR/.inputrc
export PYTHONSTARTUP=$DOTDIR/.pythonrc
export WINEARCH=win32
export WINEPREFIX=$HOME/.wine
export EDITOR=vim
export ACKRC=$DOTDIR/.ackrc
if which vim &>/dev/null && [[ -n $SHELL ]]; then
	VIM="`which vim`"
	export PAGER="$SHELL -c \"unset PAGER;col -b -x | \
		$VIM -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
		-c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
		-c 'set nonumber' \
		-c 'set norelativenumber' \
		-c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -\""
	unset VIM
fi
export VBOX_USER_HOME=$HOME/.virtualbox

#

# }}}
# Paths for programs/libraries/manpages {{{

PATH=''
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
$DOTDIR/bin
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

# }}}
# SSH {{{

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
# ensure ssh agent is running
SSHPID=`ps ax | grep -c "[s]sh-agent" 2> /dev/null`
if [[ $SSHPID -eq 0 ]]; then
	echo 'Starting ssh agent'
	ssh-agent > "$HOME/.ssh-env"
fi
. "$HOME/.ssh-env" > /dev/null

# }}}
# Site initialization {{{
# put site-specific configuration(not version controlled) in .site-zprofile
if [[ -r $ZDOTDIR/.site-zprofile ]]; then
	source $ZDOTDIR/.site-zprofile
fi
# }}}
