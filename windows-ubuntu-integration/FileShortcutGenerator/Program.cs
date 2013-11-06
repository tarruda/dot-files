using System;
using System.IO;
using System.Text;
using System.Net.Sockets;
using System.Net;

// Assuming you install FileShortcutGenerator.exe and TcpCommand.exe to
// [INSTALL_DIR] and your username is [USER], create a shortcut on the Startup
// folder in start menu with the following target:
//
// [INSTALL_DIR]\FileShortcutGenerator.exe "C:\Users\[USER]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Ubuntu" "C:\Users\[USER]\ubuntu-generated-icons" "[INSTALL_DIR]\TcpCommand.exe"
namespace FileShortcutGeneratorServer
{
  class Program
  {
    static TcpListener server;

    static void Main(string[] args)
    {
      if (args.Length < 2) {
        System.Windows.Forms.MessageBox.Show(
            "Need to provide directories for generated shortcuts and icons");
        System.Environment.Exit(1);
      }

      string shortcutDirectory = args[0];
      string iconDirectory = args[1];

      if (!Directory.Exists(shortcutDirectory)) {
        System.Windows.Forms.MessageBox.Show(String.Format(
            "Directory {0} doesn't exist", shortcutDirectory));
        System.Environment.Exit(1);
      }

      if (!Directory.Exists(iconDirectory)) {
        System.Windows.Forms.MessageBox.Show(String.Format(
            "Directory {0} doesn't exist", iconDirectory));
        System.Environment.Exit(1);
      }

      if (args.Length < 3) {
        System.Windows.Forms.MessageBox.Show(
            "Need the path for the TcpCommand.exe utility");
        System.Environment.Exit(1);
      }

      string tcpCommand = args[2];

      if (!File.Exists(tcpCommand)) {
        System.Windows.Forms.MessageBox.Show(String.Format(
            "File {0} doesn't exist", iconDirectory));
        System.Environment.Exit(1);
      }

      string listenIp = "192.168.56.1";
      int listenPort = 55556;

      server = new TcpListener(IPAddress.Parse(listenIp), listenPort);
      server.Start();

      while (true)
      {
        TcpClient client = server.AcceptTcpClient();

        // Keep eveything in sync by deleting all shortcuts and icons when
        // a new connection is accepted
        foreach (string item in Directory.GetFiles(shortcutDirectory, "*.lnk"))
          File.Delete(item);

        foreach (string item in Directory.GetFiles(iconDirectory, "*.ico"))
          File.Delete(item);

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
          name += " (Ubuntu)";

          // read command
          int commandLength = reader.ReadInt32();
          byte[] commandData = reader.ReadBytes(commandLength);
          string command = Encoding.UTF8.GetString(commandData, 0,
              commandLength);

          // Create icon if provided
          string iconPath = null;
          if (iconData != null) {
            iconPath = Path.Combine(iconDirectory, name + ".ico");
            File.WriteAllBytes(iconPath, iconData);
          }

          // Create shortcut and wrap command into a tcp-command call
          IWshRuntimeLibrary.IWshShortcut shortcut = wsh.CreateShortcut(
              Path.Combine(shortcutDirectory, name + ".lnk"))
            as IWshRuntimeLibrary.IWshShortcut;
          shortcut.TargetPath = tcpCommand;
          shortcut.Arguments = command;
          // not sure about what this is for
          shortcut.WindowStyle = 1;
          shortcut.Description = name;
          shortcut.WorkingDirectory = Path.GetDirectoryName(tcpCommand);
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
