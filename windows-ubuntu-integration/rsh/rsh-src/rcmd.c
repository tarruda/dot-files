/* rcmd.c --- execute a command on a remote host from Windows NT

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.


   Bryan Chafy <bchafy@ccs.neu.edu> --- March 2010
              Fixed gethostbyname bug - March 2011
   Jim Blandy <jimb@cyclic.com> --- August 1995  */

#include "rcmd.h"

#include <io.h>
#include <fcntl.h>
#include <malloc.h>
#include <errno.h>

#ifdef MINGW32
 #include <winsock2.h>
 #include <windows.h>
 #define SOCK_ERRNO errno
 #define SOCK_STRERROR strerror
#else
  #include <sys/types.h>
  #include <sys/socket.h>
  #include <netinet/in.h>
  #include <netdb.h>
  typedef int SOCKET;
  #define closesocket close
  #define SOCK_ERRNO errno
  /* Probably would be cleaner to just use EADDRINUSE, as NT has that too.  */
  #define WSAEADDRINUSE EADDRINUSE
  /* Probably would be cleaner to just check for < 0.  Might want to
     double-check that doing so would seem to work on NT.  */
  #define SOCKET_ERROR -1
  #define INVALID_SOCKET -1
#endif

#include <stdio.h>
#include <assert.h>

extern void error (int status, int errnum, const char *format, ...)
{
    va_list p;
    va_start(p, format);
    vfprintf(stderr, format, p);
    va_end(p);
    if (errnum != 0) {
	fprintf(stderr, ": %s\n", strerror(errnum));
    } else {
	fprintf(stderr, "\n");
    }
    if (status != 0) {
	exit(status);
    }
}

extern void PrintLastErrorMessage(char * prefix, int last_error)
{
  TCHAR errmsg[512];

  if (!FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, last_error, 0, errmsg, 511, NULL))
  {
       fprintf(stderr, "cannot FormatMessage!\n" );
       return;
  }


   fprintf(stderr, "%s %s\n", prefix, errmsg);
   exit(-1);
} 


/* The rest of this file contains the rcmd() code, which is used
   only by START_SERVER.  The idea for a long-term direction is
   that this code can be made portable (by using SOCK_ERRNO and
   so on), and then moved to client.c or someplace it can be
   shared with the VMS port and any other ports which may want it.  */


static int
resolve_address (const char **ahost, struct sockaddr_in *sai)
{
    WORD wVersionRequested;
    WSADATA wsaData;
    int err=0;

/* Use the MAKEWORD(lowbyte, highbyte) macro declared in Windef.h */
    wVersionRequested = MAKEWORD(2, 2);

    err = WSAStartup(wVersionRequested, &wsaData);
    if (err != 0) {
        /* Tell the user that we could not find a usable */
        /* Winsock DLL.                                  */
        printf("WSAStartup failed with error: %d\n", err);
        return 1;
    }

    {
	unsigned long addr = inet_addr (*ahost);

	if (addr != (unsigned long) -1)
	{
	    sai->sin_family = AF_INET;
	    sai->sin_addr.s_addr = addr;
	    return 0;
	}
    }

    {
        struct hostent *e = gethostbyname (*ahost);

	if (e)
	{
	    assert (e->h_addrtype == AF_INET);
	    assert (e->h_addr);
	    *ahost = e->h_name;
	    sai->sin_family = AF_INET;
	    memcpy (&sai->sin_addr, e->h_addr, sizeof (sai->sin_addr));
	    return 0;
	}
    }

    error (1, 0, "no such host %s", *ahost);
    /* Shut up gcc -Wall.  */
    return 1;
}

static SOCKET
bind_and_connect (struct sockaddr_in *server_sai)
{
    SOCKET s;
    struct sockaddr_in client_sai;
    u_short client_port;


    WORD wVersionRequested;
    WSADATA wsaData;
    int err;

/* Use the MAKEWORD(lowbyte, highbyte) macro declared in Windef.h */
    wVersionRequested = MAKEWORD(2, 2);

    err = WSAStartup(wVersionRequested, &wsaData);
    if (err != 0) {
        /* Tell the user that we could not find a usable */
        /* Winsock DLL.                                  */
        printf("WSAStartup failed with error: %d\n", err);
        return 1;
    }

    client_sai.sin_family = AF_INET;
    client_sai.sin_addr.s_addr = htonl (INADDR_ANY);


    for (client_port = IPPORT_RESERVED - 1;
         client_port >= IPPORT_RESERVED/2;
         client_port--)
    {
	int result, errcode;
	client_sai.sin_port = htons (client_port);

        if ((s = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1)
	   PrintLastErrorMessage( "cannot create socket: " , WSAGetLastError());

	result = bind (s, (struct sockaddr *) &client_sai,
	               sizeof (client_sai));
	errcode = WSAGetLastError();
	if (result == -1)
	{
	    closesocket (s);
	    if (errcode == WSAEADDRINUSE)
		continue;
	    else
		error (1, 0, "cannot bind to socket: %s",
		       SOCK_STRERROR (WSAGetLastError()));
	}

	result = connect (s, (struct sockaddr *) server_sai,
	                  sizeof (*server_sai));
	errcode = WSAGetLastError();
	if (result == -1)
	{
	    closesocket (s);
	    if (errcode == WSAEADDRINUSE)
		continue;
	    else
               PrintLastErrorMessage("cannot connect to socket: ",WSAGetLastError());
	}

	return s;
    }

    error (1, 0, "cannot find free port");
    /* Shut up gcc -Wall.  */
	return s;
}

static int
rcmd_authenticate (int fd, char *locuser, char *remuser, char *command)
{
    /* Send them a bunch of information, each terminated by '\0':
       - secondary stream port number (we don't use this)
       - username on local machine
       - username on server machine
       - command
       Now, the Ultrix man page says you transmit the username on the
       server first, but that doesn't seem to work.  Transmitting the
       client username first does.  Go figure.  The Linux man pages
       get it right --- hee hee.  */
    if ((send (fd, "0\0", 2, 0) == -1)
	|| (send (fd, locuser, strlen (locuser) + 1, 0) == -1)
	|| (send (fd, remuser, strlen (remuser) + 1, 0) == -1)
	|| (send (fd, command, strlen (command) + 1, 0) == -1))
	error (1, 0, "cannot send authentication info to rshd: %s",
	       SOCK_STRERROR (WSAGetLastError()));

    /* They sniff our butt, and send us a '\0' character if they
       like us.  */
    {
        char c;
	if (recv (fd, &c, 1, 0) == -1)
	{
	    error (1, 0, "cannot receive authentication info from rshd: %s",
		   SOCK_STRERROR (WSAGetLastError()));
	}
	if (c != '\0')
	{
	    /* All the junk with USER, LOGNAME, GetUserName, &c, is so
	       confusing that we better give some clue as to what sort
	       of user name we decided on.  */
	    error (0, 0, "cannot log in as local user '%s', remote user '%s'",
		   locuser, remuser);
	    error (1, 0, "Permission denied by rshd");
	}
    }

    return 0;
}

int
rcmd (const char **ahost,
      unsigned short inport,
      char *locuser,
      char *remuser,
      char *cmd,
      int *fd2p)
{
    struct sockaddr_in sai;
    SOCKET s;

    //assert (fd2p == 0);

    if (resolve_address (ahost, &sai) < 0)
        error (1, 0, "internal error: resolve_address < 0");

    sai.sin_port = htons (inport);

    if ((s = bind_and_connect (&sai)) == -1)
	error (1, 0, "internal error: bind_and_connect < 0");

    if (rcmd_authenticate (s, locuser, remuser, cmd) < 0)
	error (1, 0, "internal error: rcmd_authenticate < 0");


    return s;
}

