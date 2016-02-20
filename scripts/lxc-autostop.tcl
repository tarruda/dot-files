#!/usr/bin/expect -f
set timeout 300
set ssh_session {
  ssh -i ~/.ssh/id_local localhost sh -c
  "for c in $(grep '^[^#]' < $HOME/.lxc-auto); do lxc-stop -n $c; done"
}
spawn {*}$ssh_session
expect eof

