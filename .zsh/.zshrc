for dir in rc.d rc-local.d; do
	if [ -d "$ZDOTDIR/$dir" ]; then
		# delegate initialization
		for startup in "$ZDOTDIR/$dir/"*.zsh(.N); do
			source "$startup"
		done
		unset startup
	fi
done
unset dir
