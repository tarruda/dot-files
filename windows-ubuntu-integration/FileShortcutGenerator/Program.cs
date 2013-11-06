using System;
using System.IO;
using System.Text;
using System.Net.Sockets;
using System.Net;

namespace FileShortcutGeneratorServer
{
  class Program
  {
    static TcpListener server;

    static void Main(string[] args)
    {
      if (args.Length < 1) {
        System.Console.WriteLine(
            "Need to provide directory for generated shortcuts/icons");
        System.Environment.Exit(1);
      }

      string directory = args[0];

      if (!Directory.Exists(directory)) {
        System.Console.WriteLine("Directory {0} doesn't exist", directory);
        System.Environment.Exit(1);
      }

      string listenIp = "192.168.56.1";
      int listenPort = 55556;
      string targetIp = "192.168.56.50";

      server = new TcpListener(IPAddress.Parse(listenIp), listenPort);
      server.Start();

      while (true)
      {
        TcpClient client = server.AcceptTcpClient();

        // Delete all icons and shortcuts in the directory to keep in sync
        string[] currentIcons = Directory.GetFiles(directory, "*.ico");
        foreach (string icon in currentIcons)
        {
          File.Delete(icon);
        }

        string[] currentShortcuts = Directory.GetFiles(directory, "*.lnk");
        foreach (string shortcut in currentShortcuts)
        {
          File.Delete(shortcut);
        }

        IWshRuntimeLibrary.WshShellClass wsh =
          new IWshRuntimeLibrary.WshShellClass();

        // Get the connection stream
        NetworkStream stream = client.GetStream();
        // BinaryReader makes easier to parse binary data
        BinaryReader reader = new BinaryReader(stream);

        while (reader.ReadByte() != 0)
        {
          // next entry

          // read icon
          int iconLength = reader.ReadInt32();
          byte[] iconData = null;
          if (iconLength != 0) {
            iconData = reader.ReadBytes(iconLength);
          }

          // read name
          int nameLength = reader.ReadInt32();
          byte[] nameData = reader.ReadBytes(nameLength);
          string name = Encoding.UTF8.GetString(nameData, 0, nameLength);

          // read command
          int commandLength = reader.ReadInt32();
          byte[] commandData = reader.ReadBytes(commandLength);
          string command = Encoding.UTF8.GetString(commandData, 0,
              commandLength);

          // Create icon if provided
          string iconPath = null;
          if (iconData != null) {
            iconPath = Path.Combine(directory, name + ".ico");
            File.WriteAllBytes(iconPath, iconData);
          }

          // Create shortcut and wrap command into a tcp-command call
          IWshRuntimeLibrary.IWshShortcut shortcut = wsh.CreateShortcut(
              Path.Combine(directory, name + ".lnk"))
            as IWshRuntimeLibrary.IWshShortcut;
          shortcut.TargetPath = Path.Combine(directory, "tcp-command.exe");
          shortcut.Arguments = targetIp + " " + command;
          // not sure about what this is for
          shortcut.WindowStyle = 1;
          shortcut.Description = name;
          shortcut.WorkingDirectory = directory;
          if (iconData != null)
            shortcut.IconLocation = iconPath;
          shortcut.Save();
        }

        // Close connection
        stream.Close();
      }
    }
  }
}
