[Setup]
AppName=ServcVPN
AppVersion=1.0.0
AppPublisher=ServcVPN
AppPublisherURL=https://github.com/servcvpn
DefaultDirName={autopf}\ServcVPN
DefaultGroupName=ServcVPN
UninstallDisplayIcon={app}\ServcVPN.exe
OutputDir=..\dist
OutputBaseFilename=ServcVPN-Setup-1.0.0
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
SetupIconFile=..\app\windows\runner\resources\app_icon.ico
WizardStyle=modern
DisableProgramGroupPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
; Flutter GUI
Source: "..\app\build\windows\x64\runner\Release\servc_vpn.exe"; DestDir: "{app}"; DestName: "ServcVPN.exe"; Flags: ignoreversion
Source: "..\app\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\app\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; VPN Core backend
Source: "..\build\vpncli.exe"; DestDir: "{app}\core"; Flags: ignoreversion
Source: "..\build\xray.exe"; DestDir: "{app}\core"; Flags: ignoreversion
Source: "..\build\tun2socks-windows-amd64.exe"; DestDir: "{app}\core"; Flags: ignoreversion
Source: "..\build\wintun.dll"; DestDir: "{app}\core"; Flags: ignoreversion
Source: "..\build\geoip.dat"; DestDir: "{app}\core"; Flags: ignoreversion
Source: "..\build\geosite.dat"; DestDir: "{app}\core"; Flags: ignoreversion

; Launcher script
Source: "launch.vbs"; DestDir: "{app}"; Flags: ignoreversion

; Icon file for shortcuts
Source: "..\app\windows\runner\resources\app_icon.ico"; DestDir: "{app}"; DestName: "servcvpn.ico"; Flags: ignoreversion

[Icons]
Name: "{group}\ServcVPN"; Filename: "wscript.exe"; Parameters: """{app}\launch.vbs"""; IconFilename: "{app}\servcvpn.ico"; WorkingDir: "{app}"
Name: "{autodesktop}\ServcVPN"; Filename: "wscript.exe"; Parameters: """{app}\launch.vbs"""; IconFilename: "{app}\servcvpn.ico"; WorkingDir: "{app}"

[Run]
Filename: "wscript.exe"; Parameters: """{app}\launch.vbs"""; Description: "Launch ServcVPN"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "taskkill"; Parameters: "/F /IM vpncli.exe"; Flags: runhidden
Filename: "taskkill"; Parameters: "/F /IM servc_vpn.exe"; Flags: runhidden
Filename: "taskkill"; Parameters: "/F /IM xray.exe"; Flags: runhidden
Filename: "taskkill"; Parameters: "/F /IM tun2socks-windows-amd64.exe"; Flags: runhidden
