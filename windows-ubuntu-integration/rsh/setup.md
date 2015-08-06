adapted from: hex.ro/wp/projects/personal-cloud-computing/rsh-between-windows-7-and-ubuntu-10-using-different-user-names/


#rsh between Windows 7 and Ubuntu 10 using different user names.

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

3. Add a /etc/xinetd.d/rsh file with these contents:

```
service shell
{
	disable		= no
	socket_type	= stream
	wait		= no
	user		= root
	log_on_success	+= USERID
	log_on_failure	+= USERID
	server		= /usr/sbin/in.rshd
	protocol	= tcp
}
```

This file tells to xinetd what to execute when a connection arrives on port 514. The link to the /etc/services above is the service name ‘shell’.

4. Add the following to /etc/security/pam_env.conf

```
REMOTEHOST	DEFAULT=localhost OVERRIDE=@{PAM_RHOST}
DISPLAY		DEFAULT=${REMOTEHOST}:0.0 OVERRIDE=${DISPLAY}
PULSE_SERVER	DEFAULT=${REMOTEHOST} OVERRIDE=${PULSE_SERVER}
LIBGL_ALWAYS_INDIRECT DEFAULT=1
```

This will point the DISPLAY/PULSE_SERVER variables to the client IP(Which are
probably running X/pulse servers)

5. Now configure rshd authorization to allow connections from the Windows
user/host to the local linux user. Create a ~/.rhosts file with these contents:

```
192.168.56.1 Ubuntu
```

The ip is the address of the client machine and Ubuntu is the windows user name.
This file needs 600 permissions(`chmod 600 ~/.rhosts`)

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
