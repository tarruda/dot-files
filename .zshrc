# Run individual scripts
for rc in `ls "$HOME/.zshrc.d/"*.zsh`; do
	source "$rc"
done

for rc in `ls "$HOME/.zshrc.d/"*.sh`; do
	source "$rc"
done
