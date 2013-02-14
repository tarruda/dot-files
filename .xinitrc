#!/usr/bin/env zsh

if [ -z $ZDOTDIR ]; then
	export ZDOTDIR="$HOME/.zsh"
fi

[ -r "$ZDOTDIR/.zprofile" ] && source "$ZDOTDIR/.zprofile"

DEFAULT_SESSION=openbox-session

case $1 in
openbox)
  exec openbox-session
  ;;
kde)
	exec startkde
	;;
xfce4)
	exec startxfce4
	;;
icewm)
	icewmbg &
	icewmtray &
	exec icewm
	;;
wmaker)
	exec wmaker
	;;
blackbox)
	exec blackbox
	;;
*)
	exec $DEFAULT_SESSION
	;;
esac

