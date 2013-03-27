# Ensure login scripts are only loaded once
if [ -z $ZLOGIN_LOADED ]; then
	export ZLOGIN_LOADED=1
	for dir in login.d login-local.d; do
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
