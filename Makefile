install:
	ln -s $(PWD)/zsh/.zshenv $(HOME)/.zshenv
	ln -s $(PWD)/.gitconfig $(HOME)/.gitconfig
	ln -s $(PWD)/.global.gitignore $(HOME)/.global.gitignore
	ln -s $(PWD)/.XWinrc $(HOME)/.XWinrc
	ln -s $(PWD)/.Xresources $(HOME)/.Xresources
	ln -s $(PWD)/.startxwinrc $(HOME)/.startxwinrc
	ln -s $(PWD)/tmux/tmux.conf $(HOME)/.tmux.conf
	ln -s $(PWD)/emacs.d $(HOME)/.emacs.d
	ln -s $(PWD)/terminfo $(HOME)/.terminfo

uninstall:
	rm $(HOME)/.zshenv
	rm $(HOME)/.gitconfig
	rm $(HOME)/.global.gitignore
	rm $(HOME)/.Xresources
	rm $(HOME)/.XWinrc
	rm $(HOME)/.startxwinrc
	rm $(HOME)/.tmux.conf
	rm $(HOME)/.emacs.d
	rm $(HOME)/.terminfo

install-fonts:
	@./install/fonts

.PHONY: install install-fonts uninstall
