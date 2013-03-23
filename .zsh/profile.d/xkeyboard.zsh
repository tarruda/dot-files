if [[ -n $DISPLAY ]]; then
	if which setxkbmap &> /dev/null; then
		setxkbmap us_intl
		# setxkbmap -model abnt2 -layout br -variant abnt2
	fi
	if which xmodmap &> /dev/null; then
		xmodmap - <<- EOF
		remove Lock = Super_L
		keysym Super_L = F12
		clear Lock
		keycode 0x42 = Control_L
		EOF
	fi
fi
