# Ensure profile scripts are only loaded once
if [ -z $ZPROFILE_LOADED ]; then
	export ZPROFILE_LOADED=1
	# Run scripts in profile directory
	if [ -d "$ZDOTDIR/profile.d" ]; then
		for startup in $ZDOTDIR/profile.d/*.zsh; do
			test -r "$startup" && source "$startup"
		done
		unset startup
	fi
fi
