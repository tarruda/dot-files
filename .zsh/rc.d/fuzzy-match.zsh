source "$ZDOTDIR/plugins/fuzzy-match/fuzzy-match.zsh"

tmux-vi-fuzzy-open() {
	LBUFFER='vi'
	RBUFFER=''
	PS1=''
	zle -Rc
	zle fuzzy-match
}

zle -N tmux-vi-fuzzy-open fuzzy-match
bindkey -M viins '^X^X' tmux-vi-fuzzy-open
