if [ -z $PROFILE_LOADED ]; then
	PROFILE_LOADED=1
	PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:$HOME/bin;

	if [ -d "$HOME/.user-prefixes" ]; then
		for prefix in "$HOME/.user-prefixes/"*; do
			if [ -d "$prefix/bin" ]; then
				PATH="$prefix/bin:$PATH"
			fi
		done
		unset prefix
	fi
	export PATH

	# Run scripts in profile directory
	if [ -d "$HOME/.profile.d" ]; then
		for profile in $HOME/.profile.d/*.sh; do
			test -r "$profile" && source "$profile"
		done
		unset profile
	fi

	export LC_ALL=en_US.UTF-8
fi
