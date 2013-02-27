#!/usr/bin/env zsh
# simple vim/tmux integration. Open one vim instance per project, if a project file is
# opened and there is a running vim instance for that project, then open in it
# alias this script in zsh if running inside tmux

while (( $# != 0 )); do
	file=$1
	dir=${file:h}
	while [[ -n $dir ]] ; do
		# Only work with svn 1.7 +
		[[ -d "$dir/.git" ||\
			-d "$dir/.svn" ||\
			-d "$dir/.hg"  ||\
			-d "$dir/.bzr" ]] && break
		# go up one level
		dir=${dir:h}
	done
	tmux monitor -l "@vim-edit:$dir" # prevent race conditions
	vim_pane=`tmux show -v "@vim-edit:$dir" 2> /dev/null`
	if [[ -z $vim_pane ]] || ! tmux display-message -t $vim_pane &> /dev/null; then
		# vim is not running in any pane, so start a new instance 
		#
		# g:project_dir can be used by vim scripts that need to know the project
		# root directory
		monitor="@$RANDOM"
		tmux split-window -d -p 70 "vim \
			-c \"cd $dir\" \
			-c \"let g:project_dir='$dir'\" \
			-c ':silent !tmux set -q \"@vim-edit:$dir\" \"\$TMUX_PANE\"'\
			-c ':silent !tmux monitor -s \"$monitor\"'"
		tmux monitor -w $monitor
		vim_pane=`tmux show -v "@vim-edit:$dir" 2> /dev/null`
	fi
	# open all files
	tmux send-keys -t $vim_pane 'Escape'
	tmux send-keys -t $vim_pane ":e ${(q)${${file:a}#$dir/}}" "Enter"
	window_uid="`tmux display-message -pt \"$vim_pane\" '#{window_id}'`"
	tmux select-window -t "$window_uid"
	tmux select-pane -t "$vim_pane"
	tmux monitor -u "@vim-edit:$dir" &> /dev/null
	shift
done
