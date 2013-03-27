set FILE=%~f1
T:\cygwin\bin\run.exe /bin/zsh -l -c 'DISPLAY=:0.0 gvim $(cygpath -u ${FILE})'
