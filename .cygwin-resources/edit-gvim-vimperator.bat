set FILE=%~f1
T:\cygwin\bin\run.exe /bin/zsh -wait -l -c 'DISPLAY=:0.0 gvim -f $(cygpath -u ${FILE})'
