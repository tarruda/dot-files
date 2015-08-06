using System;
using System.IO;
using System.Text;
using System.Net.Sockets;
using System.Net;

// Assuming you install FileShortcutGenerator.exe and rsh.exe to [INSTALL_DIR],
// your windows username is [USER] and linux username is [user], create a
// shortcut on the Startup folder in start menu with the following target:
//
// [INSTALL_DIR]\FileShortcutGenerator.exe "C:\Users\[USER]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Ubuntu" "C:\Users\[USER]\ubuntu-generated-icons" "[INSTALL_DIR]\rsh.exe" 192.168.56.1 [user]
//
// 192.168.56.1 is the default address of virtualbox host-only interface(where
// it will listen on)
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
            "Need the path for the rsh.exe utility");
        System.Environment.Exit(1);
      }

      string rshCommand = args[2];

      if (!File.Exists(rshCommand)) {
        System.Windows.Forms.MessageBox.Show(String.Format(
              "File {0} doesn't exist", iconDirectory));
        System.Environment.Exit(1);
      }

      if (args.Length < 4)
      {
        System.Windows.Forms.MessageBox.Show(
            "Need listen address");
        System.Environment.Exit(1);
      }

      string listenIp = args[3];
      int listenPort = 55556;

      if (args.Length < 5)
      {
        System.Windows.Forms.MessageBox.Show(
            "Need virtualbox guest user");
        System.Environment.Exit(1);
      }

      string user = args[4];

      server = new TcpListener(IPAddress.Parse(listenIp), listenPort);
      server.Start();

      while (true)
      {
        TcpClient client = server.AcceptTcpClient();
        string ip = client.Client.RemoteEndPoint.ToString().Split(':')[0];

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
          // remove invalid substrings in paths
          name = name.Replace(@"\", @" ").Replace(@"/", @" ").Replace(":", "");
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
            iconPath = iconPath.Replace(@"\", @"\\");
            File.WriteAllBytes(iconPath, iconData);
          }

          string scpath = Path.Combine(shortcutDirectory, name + ".lnk");
          scpath = scpath.Replace(@"\", @"\\");
          // Create shortcut and wrap command into a tcp-command call
          IWshRuntimeLibrary.IWshShortcut shortcut = wsh.CreateShortcut(scpath)
            as IWshRuntimeLibrary.IWshShortcut;
          shortcut.TargetPath = rshCommand;
          shortcut.Arguments = String.Format("{0} -l {1} {2}", ip, user, command);
          // not sure about what this is for
          shortcut.WindowStyle = 1;
          shortcut.Description = name;
          shortcut.WorkingDirectory = Path.GetDirectoryName(rshCommand);
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
