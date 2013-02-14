# Ensure profile scripts are only loaded once
if [ -z $ZPROFILE_LOADED ]; then
	export ZPROFILE_LOADED=1
	for dir in profile.d profile-local.d; do
		# Run scripts in profile directory
		if [ -d "$ZDOTDIR/$dir" ]; then
			for startup in "$ZDOTDIR/$dir/"*.zsh; do
				test -r "$startup" && source "$startup"
			done
			unset startup
		fi
	done
	unset dir
fi
