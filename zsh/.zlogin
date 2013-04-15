# Title: zlogin
# Author: Thiago de Arruda (github.com/tarruda)
# Description:
#   This file is sourced by zsh when started as a login shell(-l) but after
#   .zshrc is sourced(if interactive).

# X Keyboard {{{

if [[ -z $X11_WINDOWS ]]; then
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

# }}}
# Site initialization {{{
if [[ -r $ZDOTDIR/.site-zlogin ]]; then
	source $ZDOTDIR/.site-zlogin
fi
# }}}
