## Host/container configuration

- Edit /etc/{subuid,subgid}. Each file should contain a line like `USER:100000:1000000`
  where USER is your username, 100000 is the first host id that belongs to USER
  and 1000000 is the number of ids the user can have. Ideally each container
  will have its own range of 65535 ids.

- Edit /etc/lxc/lxc-usernet. It should contain something like this: `USER veth lxcbr0 10`
  where the "10" is the number of interfaces USER can create(normally one per
  container).

- Add this line to /etc/default/lxc-net: `LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf`.
  This lets you cleanly configure static IPs for containers from the host. Example
  `/etc/lxc/dnsmasq.conf`: `dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf` and
  `/etc/lxc/dnsmasq-hosts.conf`: `CONTAINER,10.0.3.50`.

- Create the container directory: `mkdir -p ~/.local/share/lxc/CONTAINER/rootfs`

- Put something like this into `~/.local/share/lxc/CONTAINER/config`:

    lxc.include = /usr/share/lxc/config/ubuntu.common.conf
    lxc.include = /usr/share/lxc/config/ubuntu.userns.conf
    lxc.arch = x86_64
    lxc.id_map = u    0   100000     1000
    lxc.id_map = g    0   100000     1000
    lxc.id_map = u 1000     1000        1
    lxc.id_map = g 1000     1000        1
    lxc.id_map = u 1001   101001    64535
    lxc.id_map = g 1001   101001    64535
    lxc.network.type = veth
    lxc.network.link = lxcbr0
    lxc.network.flags = up
    lxc.network.hwaddr = 00:16:3e:07:5a:bf
    lxc.rootfs = ~/.local/share/lxc/CONTAINER/rootfs
    lxc.utsname = CONTAINER

  This configuration will map a range of ids(starting from 100000) to the
  container namespace. The only exception is the user 1000, which will map to
  the real 1000 id from the host. This configuration simplifies some tasks such
  as sharing directories from host and containe, but if sharing one uid between
  host and container is not desired, then replace all `lxc.id_map` lines with:

    lxc.id_map = u    0   100000     65535
    lxc.id_map = g    0   100000     65535

# Convert from existing privileged container

- copy the rootfs from the privileged container:
  `sudo rsync -avP /var/lib/lxc/CONTAINER/rootfs/ ~/.local/share/lxc/CONTAINER/rootfs/
- remove all device nodes under /dev:
  `sudo find ~/.local/share/lxc/CONTAINER/rootfs/dev \( -type c -o -type b \) -delete
- save lists of all setuid/setgid binaries:
  `find ~/.local/share/lxc/CONTAINER/rootfs -perm -4000 > ~/setuid` and
  `find ~/.local/share/lxc/CONTAINER/rootfs -perm -2000 > ~/setgid`
- change ownership to the root in the container namespace(adjust if not 100000):
  `sudo chown -R 100000:10000 ~/.local/share/lxc/CONTAINER/rootfs`
- restore setuid/setgid binaries(lost after chown):
  `cat ~/setuid | xargs sudo chmod u+s` and `cat ~/setgid | xargs sudo chmod g+s`

At this point the container should be ready to start.
