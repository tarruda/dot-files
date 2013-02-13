unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end

autoload -U compinit
compinit -C
# Add local completion functions to fpath:
local_comp="$ZDOTDIR/completion.d"
if [ -d $local_comp ]; then
		fpath=($local_comp $fpath)
fi
unset local_comp

zstyle ':completion:*:default' list-colors ''
zstyle ':completion:*:*:vi:*:*files' ignored-patterns '*.o,*~,*.swp'
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"
