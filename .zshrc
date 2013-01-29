# load oh-my-zsh
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="evan" # afowler, alanpeabody, cypher
DISABLE_AUTO_UPDATE="true"
# plugins=(node)
source $ZSH/oh-my-zsh.sh

# load personal scripts
for rc in `ls "$HOME/.zshrc.d/"*.zsh`; do
	source "$rc"
done

for rc in `ls "$HOME/.zshrc.d/"*.sh`; do
	source "$rc"
done
