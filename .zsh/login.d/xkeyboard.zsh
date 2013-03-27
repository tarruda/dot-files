if [[ -z $CYGWIN_X ]]; then
	echo 'Configuring X keyboard'
	if which setxkbmap &> /dev/null; then
		setxkbmap us_intl
		# setxkbmap -model abnt2 -layout br -variant abnt2
	fi
	if which xmodmap &> /dev/null; then
		xmodmap - <<- EOF
		clear Lock
		keycode 0x42 = Control_L
		EOF
	fi
fi
