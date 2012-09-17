# Run individual scripts
for rc in `ls "$HOME/.zshrc.d/"*.zsh`; do
	source "$rc"
done
