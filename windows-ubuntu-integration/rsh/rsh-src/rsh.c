/*-
 * Copyright (c) 1988, 1989 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the University of
 *      California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

char copyright[] =
 "@(#) Copyright (c) 1988, 1989 The Regents of the University of California.\n"
 "All rights reserved.\n";


/*
 * From: @(#)rsh.c	5.24 (Berkeley) 7/1/91
 */

/*  
 *  Windows Port by Bryan Chafy (bchafy@ccs.neu.edu)
 */

#include <stdio.h>
#include <fcntl.h>
#include <malloc.h>
#include <errno.h>
#include <winsock2.h>
#include <signal.h>
#include <io.h>
#include <Windows.h>

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

/*
 * rsh - remote shell
 */
static int rfd2;

static char *copyargs(char **);
static void talkthread();
static void talkmain(int nflag, long omask, int rem);
static void usage(void);
static void sendsig(int sig);

int rem, nflag;

int
main(int argc, char *argv[])
{
        char acUserName[100];
        DWORD nUserName = 100;
	struct servent *sp;
	long omask;
	int argoff, asrsh, ch, dflag, one;
	char *args, *host, *user;
        HANDLE pid;

	argoff = asrsh = dflag = nflag = 0;
	one = 1;
	host = user = NULL;

 
	/* handle "rsh host flags" */
	if (!host && argc > 2 && argv[1][0] != '-') {
		host = argv[1];
		argoff = 1;
	}

#define	OPTIONS	"+8KLdel:nw"
	while ((ch = getopt(argc - argoff, argv + argoff, OPTIONS)) != EOF)
		switch(ch) {
		case 'K':
			break;
		case 'L':	/* -8Lew are ignored to allow rlogin aliases */
		case 'e':
		case 'w':
		case '8':
			break;
		case 'd':
			dflag = 1;
			break;
		case 'l':
			user = optarg;
			break;
		case 'n':
			nflag = 1;
			break;
		case '?':
		default:
			usage();
		}
	optind += argoff;

	/* if haven't gotten a host yet, do so */
	if (!host && !(host = argv[optind++]))
		usage();

	/* if no further arguments, must have been called as rlogin. */
	if (!argv[optind]) {
        /*
		if (setuid(getuid())) {
			fprintf(stderr, "rsh: setuid: %s\n", strerror(errno));
			exit(1);
		}
		if (asrsh) argv[0] = (char *)"rlogin";
	        execve(_PATH_RLOGIN, argv, saved_environ); 

         */

		fprintf(stderr, "rsh: can't exec rlogin.\n");
		exit(1);
	}

	argc -= optind;
	argv += optind;


	if (!(GetUserName(acUserName, &nUserName)) ) {
		fprintf(stderr, "rsh: unknown user id.\n");
		exit(1);
	}
	if (!user)
		user = acUserName;


	args = copyargs(argv);

	sp = NULL;
	if (sp == NULL)
           sp = (struct servent *) malloc (sizeof(struct servent));
	   sp->s_name = "shell";      /* official service name */
	   sp->s_aliases = NULL;	/* alias list */
	   sp->s_port = 514;		/* port # */
	   sp->s_proto = "tcp";     /* protocol to use */

	if (sp == NULL) {
		fprintf(stderr, "rsh: shell/tcp: unknown service.\n");
		exit(1);
	}

        rfd2 = 0;

	rem = rcmd(&host, sp->s_port, acUserName, user, args, &rfd2);

	if (rem < 0) {
		fprintf(stderr, "rsh: can't establish stdout.\n");
		exit(1);
        }

	if (rfd2 < 0) {
		fprintf(stderr, "rsh: can't establish stderr.\n");
		exit(1);
	}


	if (dflag) {
		if (setsockopt(rem, SOL_SOCKET, SO_DEBUG, &one,
		    sizeof(one)) < 0)
			fprintf(stderr, "rsh: setsockopt: %s.\n",
			    strerror(errno));
	}


	// omask = sigblock(sigmask(SIGTERM));
	if (signal(SIGTERM, SIG_IGN) != SIG_IGN)
		signal(SIGTERM, sendsig);



	ioctlsocket(rem, FIONBIO, &one);


	if (!nflag) {
          DWORD threadId;
        pid = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) talkthread, NULL, 0, &threadId);

	if (pid <= 0) {
			fprintf(stderr,
			    "rsh: CreateThread: %s.\n", strerror(errno));
			exit(1);
		}

	}
	
	
        if (!nflag)
	   talkmain(nflag, omask, rem);

	if (!nflag)
           TerminateThread(  pid,  0 );
           shutdown(rem, SD_BOTH);
           closesocket(rem);
	exit(0);
}

static void
talkthread()
{
	register int cc, wc;
	register char *bp;
	fd_set rembits;
	char buf[BUFSIZ];

	FD_ZERO(&rembits);

	if (!nflag) {
	//      close(rfd2);


reread:		errno = 0;
		if ((cc = read(0, buf, sizeof(buf))) <= 0)
			goto done;
		bp = buf;

rewrite:	FD_ZERO(&rembits);
		FD_SET(rem, &rembits);
		if (select(rem+1, 0, &rembits, 0, 0) < 0) {
			if (errno != EINTR) {
                          PrintLastErrorMessage( "rsh: select: " , WSAGetLastError());
			//	fprintf(stderr,
			//	    "rsh: select: %s.\n", strerror(errno));
				exit(1);
			}
			goto rewrite;
		}
		if (! FD_ISSET(rem, &rembits))
			goto rewrite;
			wc = send(rem, bp, cc, 0);
		if (wc < 0) {
			if (errno == WSAEWOULDBLOCK)
				goto rewrite;
			goto done;
		}
		bp += wc;
		cc -= wc;
		if (cc == 0)
			goto reread;
		goto rewrite;
done:
		shutdown(rem, SD_SEND);
		exit(0);
	}

}

static void
talkmain(int nflag, long omask, int rem)
{

	register int cc;
	fd_set readfrom;
	int rfd2_ok, rem_ok;
	char buf[BUFSIZ];
        int selstatus;


	rfd2_ok = rem_ok = 1;
	while (rem_ok) {
		FD_ZERO(&readfrom);
	//	if (rfd2_ok)
	//		FD_SET(rfd2, &readfrom);
		if (rem_ok)
			FD_SET(rem, &readfrom);

                selstatus = select(rem+1, &readfrom, 0, 0, 0);

                if (selstatus < 0) {
			if (errno != EINTR) {
                          PrintLastErrorMessage( "rsh: sselect: " , WSAGetLastError());
			}
			continue;
		}
		if (FD_ISSET(rem, &readfrom)) {
			errno = 0;
			cc = recv(rem, buf, sizeof buf,0);
			if (cc > 0)
				write(1, buf, cc);
			else if (cc == 0 || WSAGetLastError() != WSAEWOULDBLOCK)
				rem_ok = 0;
		}
	}
}


char *
copyargs(char **argv)
{
	int cc;
	char **ap, *p;
	char *args;

	cc = 0;
	for (ap = argv; *ap; ++ap)
		cc += strlen(*ap) + 1;
	args = malloc(cc);
	if (!args) {
		fprintf(stderr, "rsh: %s.\n", strerror(ENOMEM));
		exit(1);
	}
	for (p = args, ap = argv; *ap; ++ap) {
		/*strcpy(p, *ap);*/
		for (p = strcpy(p, *ap); *p; ++p);
		if (ap[1])
			*p++ = ' ';
	}
	return(args);
}

void 
sendsig(int sig)
{
  char signo;
  signo = sig;

  send(rem,&signo,1,0);

}

void
usage(void)
{

        fprintf(stderr,"\n        RSH for Windows (c)2010,2011 Bryan Chafy. Licensed under the GPL.\n\n");
        fprintf(stderr,"Runs commands on remote hosts running the RSH service.\n\n");
        fprintf(stderr,"RSH host [-l username] [-n] command\n\n");
        fprintf(stderr,"  host            Specifies the remote host on which to run command.\n");
        fprintf(stderr,"  -l username     Specifies the user name to use on the remote host. If\n");
        fprintf(stderr,"                  omitted, the logged on user name is used\n");
        fprintf(stderr,"  -n              Redirects the input of RSH to NULL.\n");
        fprintf(stderr,"  command         Specifies the command to run.\n\n");


	exit(1);
}
