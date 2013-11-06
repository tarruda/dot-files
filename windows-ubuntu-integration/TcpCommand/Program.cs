using System;
using System.Net.Sockets;
using System.Net;

namespace TcpCommand
{
  class Program
  {
    static void Main(string[] args)
    {
      if (args.Length == 0) {
        System.Windows.Forms.MessageBox.Show("No command was provided");
        System.Environment.Exit(1);
      }
      // join arguments and convert to byte array terminated by linefeed
      string command = String.Join(" ", args) + "\n";
      byte[] data = System.Text.Encoding.UTF8.GetBytes(command);

      // connect to client and send data
      TcpClient socket = new TcpClient("192.168.56.50", 55555);
      NetworkStream stream = socket.GetStream();
      stream.Write(data, 0, data.Length);
      stream.Close();
      socket.Close();
    }
  }
}
