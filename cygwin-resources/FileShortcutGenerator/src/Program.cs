using System;
using System.Text;
using System.Net.Sockets;
using System.Net;

namespace FileShortcutGeneratorServer
{
  class Program
  {
    static TcpListener server;

    static void Main()
    {
      IPAddress ip = IPAddress.Parse("127.0.0.1");
      server = new TcpListener(ip, 3000);
      server.Start();

      byte[] buffer = new byte[4096];
      string data;
      int read;

      while (true)
      {
        Console.Write("Waiting for connection...");
        TcpClient client = server.AcceptTcpClient();
        Console.WriteLine("Connection accepted");
        NetworkStream stream = client.GetStream();

        read = 0;
        data = null;

        while ((read = stream.Read(buffer, 0, buffer.Length)) != 0)
        {
          data = Encoding.UTF8.GetString(buffer, 0, read);
          Console.WriteLine("Received: {0}", data); 
        }

        stream.Close();
      }
    }
  }
}
