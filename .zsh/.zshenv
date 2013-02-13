# ignore global startup files to maintain consistency across distros
unsetopt global_rcs

if [ -d "$ZDOTDIR/env.d" ]; then
	for startup in "$ZDOTDIR/env.d/"*.zsh(.N); do
		source "$startup"
	done
	unset startup
fi
