which xmodmap >/dev/null 2>&1 && \
xmodmap - << EOF
remove Lock = Super_L
keysym Super_L = F12
EOF
