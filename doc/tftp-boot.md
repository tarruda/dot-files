## Ubuntu tftp + dhcp for netboot

Install dnsmasq. Need to install the `dnsmasq` package, the one used by network
manager is not enough. Then put something like this into /etc/dnsmasq.conf

```
dhcp-range=192.168.1.4,192.168.1.10,255.255.255.0,1h
dhcp-boot=FIRMWARE_IMG_FILE
enable-tftp
tftp-root=/tftpboot
```

Create the `/tftpboot` directory, change permissions to 777 and put
`FIRMWARE_IMG_FILE` in that directory. Restart with `sudo systemctl restart dnsmasq.conf`.
