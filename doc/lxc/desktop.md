## xpra service to attach/detach from applications running in the container

For best results:

- Install xpra from latest source tarball(uncomment '-Wno-error=strict-prototypes'
  flag from setup.py or it may fail compilation).
- Bind mount the host's ~/.xpra directory to the container by adding something
  like this to the configuration:
    
    lxc.mount.entry = /home/tarruda/.xpra home/tarruda/.xpra none bind,create=dir 0 0

- Install required opengl packages on both client and server:

    sudo pip install PyOpenGL PyOpenGL_accelerate
    sudo apt-get install python-gtkglext1

Create a service script to automatically run xpra on boot. For upstart, put the
following into /etc/init/xpra.conf:

```upstart
start on started networking
stop on stopping networking
setuid tarruda

env XPRA=/usr/local/bin/xpra
env XPRA_DISPLAY="100"
env HOME=/home/tarruda

script
  exec ${XPRA} start --no-daemon --sharing=yes :${XPRA_DISPLAY}
end script

post-start script
  while ! ${XPRA} version :${XPRA_DISPLAY}; do sleep 1; done
end script

post-stop script
  # Kill the Xorg server started by xpra
  [ -f /tmp/.X${XPRA_DISPLAY}-lock ] && kill $(cat /tmp/.X${XPRA_DISPLAY}-lock)
end script
```

Spawn programs using ssh, eg:

```sh
ssh CONTAINER DISPLAY=:100 setsid urxvt &
ssh CONTAINER DISPLAY=:100 setsid chromium-browser &
```

## full desktop through xpra

Install all packages for a desktop distro and Xephyr(nested X required to
forward a full desktop through xpra).

Eg: `sudo apt-get install xubuntu-desktop xserver-xephyr`. For upstart, put the
following into /etc/init/xpra-desktop.conf:

```upstart
start on started xpra
stop on stopping xpra
setuid tarruda

env XPRA=/usr/bin/xpra
env XPRA_DISPLAY="200"
env HOME=/home/tarruda

script
  # Commands are run outside a normal session, export a basic environment
  export LANG=en_US.UTF-8 SHELL=/bin/zsh USER=$(whoami)
  cd $HOME
  # xpra/X options
  display="201"
  geometry="1920x1080"
  startx="/usr/bin/startx -- /usr/bin/Xephyr :${display} -ac -screen ${geometry}"
  opts="--no-daemon --start-child='${startx}' --exit-with-children"
  eval "exec ${XPRA} start $opts :${XPRA_DISPLAY}"
end script

post-start script
  while ! ${XPRA} version :${XPRA_DISPLAY}; do sleep 1; done
end script

post-stop script
  # Kill the Xorg server started by xpra
  [ -f /tmp/.X${XPRA_DISPLAY}-lock ] && kill $(cat /tmp/.X${XPRA_DISPLAY}-lock)
end script
```

Note that the xpra-desktop has a dependency on the first xpra. This is not a
requirement(instead it can have the same "networking" dependency as the former),
but it allows the desktop share applications with any other clients connected to
the first xpra. This would be possible by putting something like this on
.xinitrc:

```sh
#!/bin/sh

setsid xpra attach --sharing=yes :100 &
exec xfce4-session
```

So any applications spawned like `ssh CONTAINER DISPLAY=:100 setsid urxvt &`
would also be visible in the desktop.

## attaching from the host

For best performance, attach using a mmapped file. Since ~/.xpra is also mounted
on the container, this should work:

```sh
mkdir ~/.xpra/mmap
TMPDIR=$HOME/.xpra/mmap xpra attach --sharing=yes socket:$HOME/.xpra/CONTAINER-${XPRA_DISPLAY}
```

Where `${XPRA_DISPLAY}` is the display of the xpra server you want to connect.
`--sharing=yes` should only be used if the server was also started with this
option.

Specifying TMPDIR is required because by default `/tmp` is used to store mmapped
files.

The `socket:` URL is required because xpra fails to find local live
servers(possibly because /tmp is not used by X).

The TMPDIR and socket URL can probably be skipped by also bind mounting the
host's /tmp to the container, but I prefer to not do it for security reasons.

## scripting examples

Send key to the xpra desktop:

```sh
ssh CONTAINER DISPLAY=:201 xdotool key "alt+Tab"
```

Take screenshot(requires the `scrot` command to be installed):

```sh
sh -c 'ssh CONTAINER DISPLAY=:201 scrot screen.png' && scp CONTAINER:screen.png ./ && xdg-open screen.png
```
