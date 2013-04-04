install:
	ln -s $(PWD)/zsh/.zshenv $(HOME)/.zshenv
	ln -s $(PWD)/.gitconfig $(HOME)/.gitconfig
	ln -s $(PWD)/.global.gitignore $(HOME)/.global.gitignore

uninstall:
	rm $(HOME)/.zshenv
	rm $(HOME)/.gitconfig
	rm $(HOME)/.global.gitignore

install-fonts:
	@./install/fonts

.PHONY: install install-fonts uninstall
