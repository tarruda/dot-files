source "$ZDOTDIR/plugins/fuzzy-match/fuzzy-match.zsh"

tmux-vi-fuzzy-open() {
	fuzzy-match '' '' 1
	vi $REPLY
	exit
}

zle -N tmux-vi-fuzzy-open
bindkey -M viins '^X^X' tmux-vi-fuzzy-open
