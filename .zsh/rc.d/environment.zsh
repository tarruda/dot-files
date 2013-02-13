if which vim &>/dev/null; then
		VIM="`which vim`"
    export PAGER="$SHELL -c \"unset PAGER;col -b -x | \
    command vim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
    -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
    -c 'set nonumber' \
    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -\""
    export EDITOR="$VIM"
		unset VIM
fi
