REM Converts the temp file path to a cygwin path and edit with vim
set FILE=%~f1
set FILE=%FILE:\=/%
T:\cygwin\bin\zsh.exe -c "LETTER=${FILE[1]:l};FILE=/cygdrive/${LETTER}${FILE[3,-1]};export FILE;source ~/.zsh/profile.d/00-paths.zsh;source ~/.zsh/profile.d/environment.zsh;DISPLAY=:0.0 urxvt -geometry 100x25 -e vim ${FILE}"
