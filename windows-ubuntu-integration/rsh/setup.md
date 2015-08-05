adapted from: hex.ro/wp/projects/personal-cloud-computing/rsh-between-windows-7-and-ubuntu-10-using-different-user-names/


#rsh between Windows 7 and Ubuntu 10 using different user names.

##Purpose

A hurdle I’ve encountered is how to get rsh to work between Windows 7 Ultimate and Ubuntu 10.04 LTS.

We’re starting with two limiting factors, which I learned the hard way:

    rsh-server coming with Ubuntu 10.04 uses a configuration file pointing to a PAM security module that was missing from the system. The /etc/pam.d/rsh points to the old pam_rhosts_auth.so (which supported the promiscuous option which all tutorials talk about), but my system only has pam_rhosts.so.
    rsh.exe is not found in Windows 7 anymore, so we have to manage using some other tools to connect.

##Network configuration:

The following diagram shows the network layout:


  +-----------------+          +-------------------+
  | rsh client      |          | rsh server        |
  | Windows 7       |--------->| Ubuntu 14.04      |
  | IP: 192.168.56.1|          | IP: 192.168.56.25 |
  | Username: Ubuntu|          | username: ubuntu  |
  +-----------------+          +-------------------+
                     

The goal is to be able to invoke commands from the Windows machine (client) to Ubuntu (server) using rsh.

First we need to configure the rsh server (linux part), then find a suitable Windows client, then test that is working.


##rsh server configuration

This is the most complex part  and a lot of things have to be in order. I had troubles to get it to work because of bad configuration files installed by default and because of lack of verbosity of rsh as well as pam modules.

These are the steps:

1. Install the three packages: `sudo apt-get install rsh-redone-server rsh-redone-client xinetd`. xinetd is required, as it is running the rsh server. Also, from now on, the rsh-server service name is ‘shell’ as you will see below.
2. Make sure to check /etc/services to contain a line like this: `shell 514/tcp cmd             # no passwords used`. We need the shell service present there, since that’s what xinetd looks for when a connection arrives on port 514.
3. Make sure to check /etc/inetd.conf if it has this line: `shell stream  tcp nowait  root    /usr/sbin/in.rshd`. This file tells to xinetd what to execute when a connection arrives on port 514. The link to the /etc/services above is the service name ‘shell’.
4. The last part of configuration is setting up the hosts files so that it will allow the Windows user name. For this two files have to be modified to allow pam_rhost module to match the remote user name with the remote ip and also with the local account:
  - /etc/hosts.equiv to add a line in format `remote_host remote_username`, for example: `192.168.56.1 Ubuntu`
  - /home/ubuntu/.rhosts needs the same line added: `192.168.56.1 Ubuntu`
  Also, logged in as ubuntu you need to `chmod +600 .rhosts`

A lot of tutorials say that /etc/securetty has to be updated to include rsh (and rlogin). But this is not needed, since the /etc/pam.d/rsh does not mention pam_securetty.so.

##Windows 7

There are two clients that I was able to get to run on Windows 7, a standalone one (.exe) http://www.ccs.neu.edu/home/bchafy/rsh_vista.html and a perl library Net::Rsh which it can be used with ActivePerl. You can use the .exe one like this:

```
C:\rsh>rsh 192.168.56.25 -l ubuntu cat /etc/issue
Ubuntu 10.04.1 LTS \n \l
```

To use the perl library, you can try the code below (adaptation of the code specified in its documentation):

```perl
use Net::Rsh;
use Data::Dumper;
 
$a=Net::Rsh->new();
 
$host="192.168.56.25";
$local_user="Ubuntu";
$remote_user="ubuntu";
$cmd="date";
 
@c=$a->rsh($host,$local_user,$remote_user,$cmd);
 
print Dumper @c;
```

The first byte of the reply is either 0 (success) or 1 and then it comes an error.

A successful run looks like this:

```
C:\rsh>perl rsh.pl
$VAR1 = ' Ubuntu 10.04.1 LTS \\n \\l
';
$VAR2 = '
';
```

If anything goes wrong, is better to use the perl client, which always shows the error sent by the server like this:

```
C:\rsh>perl rsh.pl
$VAR1 = '☺Permission denied.
';
```

##Improvements

IPs can be used instead of host names, but there’s always delays in reply from Ubuntu unless the IP of the client is not added in /etc/hosts with a name (and then all the other files /etc/hosts.equiv and .rhosts are updated accordingly). rsh server does host name lookups and it waits for timeout before settling for the IP. Of course, better is if all the nodes within VPN have their own DNS, but … that’s for another article.
