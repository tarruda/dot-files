#!/usr/bin/env zsh
# Simple fuzzy file opener

ib_pos=(0 0)

cleanup() {
	zcurses end
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
	exit
}

split() {
	_shm_set "$wid:fuzzy-open" 1
	tmux split-window -t $wid -l 10\
		"zsh \"$HOME/.zshrc.d/tmux.d/fuzzy_edit.zsh\" $pid"
}

setup_screen() {
	zcurses init
	zcurses addwin header 1 $COLUMNS 0 0
	zcurses addwin results 8 $COLUMNS 1 0
	zcurses addwin input_box 1 $COLUMNS 9 0
	zcurses string header "Fuzzy file search"
	zcurses refresh header results input_box
}

getchar() {
	zcurses input input_box char
	keycode=`printf "%d" "'$char'"`
}

fuzzy_find() {
	find . -type f | grep -F "$1" | head -n 8
}

get_current_text() {
	local rv=""
	local reply=
	local curs=$ib_pos[2]
	for (( i = 0; i <= $curs; i++ )); do
		zcurses move input_box 0 $i
		zcurses querychar input_box
		rv="${rv}${reply[1]}"
	done
	echo -n "$rv"
}

update_results() {
	local i=0
	local max=8
	zcurses move results 0 0
	local res_line=0
	local line=
	while read line; do
		zcurses string results "$line"
		res_line=$(($res_line + 1))
		zcurses move results $res_line 0
		zcurses refresh results input_box
		i=$(($i + 1))
		[[ $i -eq 8 ]] && break
	done
}

process_char() {
	if [[ -n "$f_pid" && -n "`jobs`" ]]; then
		# kill currently running find
		kill $f_pid
	fi
	zcurses position input_box ib_pos
	zcurses move results 0 0
	if [ $keycode = 127 ]; then
		# backspace
		zcurses move input_box 0 $(($ib_pos[2] - 1))
		zcurses char input_box " "
		zcurses move input_box 0 $(($ib_pos[2] - 1))
	else
		zcurses char input_box $char
	fi
	zcurses refresh input_box
	local txt="`get_current_text`"
	if [ -n "$txt" ]; then
		wait
		# zcurses clear results
		find . -type f -path "*$txt*" | update_results &
		f_pid=$!
	fi
}
 
run() {
	zmodload zsh/curses
	trap cleanup INT HUP TERM EXIT
	setup_screen
	_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
	getchar
	while true; do
		if [ $keycode != 27 ]; then
			process_char
		else
			break
		fi
		getchar
	done
}

source "$HOME/.zshrc.d/tmux.d/common.zsh"

pid=$1
wid="`tmux display-message -pt \"$pid\" '#{window_id}'`" 2>/dev/null
if [ -z $wid ]; then
	echo "Cannot find window"
	exit
fi
is_open="`_shm_get $wid:fuzzy-open`"
if [ -z $is_open ]; then
	split
else
	pane_id="`_shm_get $wid:fuzzy-running`"
	if [ "%$pane_id" != "$TMUX_PANE" ]; then
		run
	fi
fi
