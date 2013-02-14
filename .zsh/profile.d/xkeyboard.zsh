if which setxkbmap &> /dev/null; then
	setxkbmap us_intl
fi
if which xmodmap &> /dev/null; then
	xmodmap - <<- EOF
	remove Lock = Super_L
	keysym Super_L = F12
	EOF
fi
