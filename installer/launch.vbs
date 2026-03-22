Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
strPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\"

' Start VPN core as admin (hidden window)
Set objShell = CreateObject("Shell.Application")
objShell.ShellExecute strPath & "core\vpncli.exe", "serve --port 50051", strPath & "core", "runas", 0

' Wait for core to initialize
WScript.Sleep 2000

' Start Flutter GUI (normal user)
WshShell.Run """" & strPath & "ServcVPN.exe""", 1, False
