# this will only work when using zsh 4.3.10+. basically we are setting ZDOTDIR to
# the directory that contains the .zshenv file, which will be symlinked in the
# $HOME dir
function() {
zmodload zsh/parameter
local this_file="${funcsourcetrace[1]%:*}"
local cur_dir="${this_file:A:h}"
export DOTDIR=${cur_dir:h}
export ZDOTDIR="$DOTDIR/zsh"
unsetopt global_rcs
}
