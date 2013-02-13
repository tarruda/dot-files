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
