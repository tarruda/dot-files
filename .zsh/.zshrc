# load oh-my-zsh
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="evan" # afowler, alanpeabody, cypher
DISABLE_AUTO_UPDATE="true"
plugins=(git git-extras)
source $ZSH/oh-my-zsh.sh

if [ -d "$ZDOTDIR/rc.d" ]; then
	# delegate initialization
	for startup in "$ZDOTDIR/rc.d/"*.zsh(.N); do
		source "$startup"
	done
	unset startup
fi
