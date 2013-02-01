source "$HOME/.zshrc.d/tmux.d/common.zsh"

parsed=
tmux_pane=${1#*\%}
other=`_shm_get $tmux_pane`
[ -z $other ] && return
parsed=(${(s.:.)other})
toggle=
tgt=
percentage=
if [ "$parsed[2]" = "bottom" ]; then
	toggle="$parsed[1]"
	tgt=$tmux_pane
	percentage=70
else
	toggle="$tmux_pane"
	tgt="$parsed[1]"
	percentage=30
fi
hidden=`_shm_get "${toggle}-hidden"`
if [ ! -z $hidden ]; then
	# join and swap
	tmux join-pane -p $percentage -s "%$toggle" -t "%$tgt"
	_shm_pop "${toggle}-hidden" > /dev/null
	tmux swap-pane -s "%$toggle" -t "%$tgt"
	if [ -z $2 ]; then
		# focus the joined pane
		tmux select-pane -t "%$toggle"
	fi
else
	tmux break-pane -d -t "%$toggle"
	_shm_set "${toggle}-hidden" 1
fi
