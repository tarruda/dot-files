#!/bin/sh

setxkbmap us_intl

if [ -z $PROFILE_LOADED ]; then
	. "$HOME/.profile"
fi
unset PROFILE_LOADED

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

