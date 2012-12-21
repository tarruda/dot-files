# Run individual scripts
for rc in `ls "$HOME/.zshrc.d/"*.zsh`; do
	source "$rc"
done

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
