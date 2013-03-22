if which vim &>/dev/null && [[ -n $SHELL ]]; then
		VIM="`which vim`"
    export PAGER="$SHELL -c \"unset PAGER;col -b -x | \
    command vim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
    -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
    -c 'set nonumber' \
    -c 'set norelativenumber' \
    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -\""
    export EDITOR="$VIM"
		unset VIM
fi
export ACKRC=".ackrc"
