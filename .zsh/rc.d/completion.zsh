# Add local completion functions to fpath:
local_comp="$HOME/.zshrc.d/completion.d"
if [ -d $local_comp ]; then
    fpath=($local_comp $fpath)
fi

zstyle ':completion:*:*:vi:*:*files' ignored-patterns '*.o,*~,*.swp'
