tmux source $DOTDIR/tmux/tmuxrc
if [[ -r $DOTDIR/tmux/site-tmuxrc ]]; then
	tmux source $DOTDIR/tmux/site-tmuxrc
fi

# Vim/tmux integration {{{

# use y to copy and alt+p to paste(from the clipboard x11 clipboard if available)
if which xclip &> /dev/null && [[ -n $DISPLAY ]]; then
	tmux bind -t vi-copy y copy-pipe 'xclip -i -selection clipboard'
	tmux bind -n M-p run "xclip -o -selection clipboard | tmux load-buffer -; tmux paste-buffer"
else
	tmux bind -t vi-copy y copy-selection
	tmux bind -n M-p paste-buffer
fi
# }}}
