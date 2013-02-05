case $OSTYPE in
	freebsd*)
		alias l="command ls -G $@"
		alias ls=l
		alias p='ps -a'
		alias la='l -lah $@'
		;;
	linux*)
		alias l="command ls --color=auto $@"
		alias ls=l
		alias p='ps -e'
		alias la="l -lah $@"
		;;
esac
