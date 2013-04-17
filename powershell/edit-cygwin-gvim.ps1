param (
    [string]$path
)
$path = resolve-path $path
$path = $path -replace '\\','\\\\'
$path = "`"$path`""
$socket = new-object System.Net.Sockets.TcpClient('127.0.0.1', 55555)
$stream = $socket.GetStream()
$writer = new-object System.IO.StreamWriter $stream
$writer.Write("gvim '$path'`n")
$writer.Flush()
$writer.Close()
$stream.Close()