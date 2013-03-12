case $OSTYPE in
	*bsd*)
		# Make freebsd ls colors look like linux ls
		# src: http://www.puresimplicity.net/~hemi/freebsd/misc.html
		export CLICOLOR="YES";
		export LSCOLORS="ExGxFxdxCxDxDxhbadExEx"; 
		alias l="command ls -G $@"
		alias ls=l
		alias la='l -lah $@'
		alias p='ps -auxww'
		;;
	linux*)
		alias l="command ls --color=auto $@"
		alias ls=l
		alias la="l -lah $@"
		alias p='ps -ef'
		;;
esac

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias d='dirs -v | head -10'

alias GET='burl GET'
alias HEAD='burl -I'
alias POST='burl POST'
alias PUT='burl PUT'
alias PATCH='burl PATCH'
alias DELETE='burl DELETE'
alias OPTIONS='burl OPTIONS'
