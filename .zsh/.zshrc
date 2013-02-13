if [ -d "$ZDOTDIR/rc.d" ]; then
	# delegate initialization
	for startup in "$ZDOTDIR/rc.d/"*.zsh(.N); do
		source "$startup"
	done
	unset startup
fi
