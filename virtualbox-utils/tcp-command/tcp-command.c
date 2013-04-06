#include <winsock2.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
  SOCKET conn;
  SOCKADDR_IN server_addr;
  WSADATA wsa_data;
  WORD version = MAKEWORD(2, 2);
  char *buffer = (char *)malloc(1024);
  char *pos = buffer;

  // join the arguments by space into one buffer
  argc--;
  argv++;
  while (argc > 0) {
    strcpy(pos, *argv);
    pos += strlen(*argv);
    strcpy(pos, " ");
    pos++;
    argc--;
    argv++;
  }
  if (pos == buffer)
    return 1; // nothing was provided as argument
  *(pos - 1) = '\n';

  // open the connection and send the command
  WSAStartup(version, &wsa_data); 
  conn = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  memset(&server_addr, 0, sizeof(server_addr));
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = inet_addr("192.168.56.50");
  server_addr.sin_port = htons(5555);
  connect(conn, (LPSOCKADDR)&server_addr, sizeof(server_addr));
  send(conn, buffer, pos - buffer, 0);
  closesocket(conn);
  WSACleanup();
  return 0;
}
