package engine

import (
	"fmt"
	"os/exec"
)

// savedAutoConfigURL stores the original PAC URL to restore on disconnect.
var savedAutoConfigURL string

// SetSystemProxy enables the Windows system proxy using PowerShell for reliability.
// It also clears any PAC file (AutoConfigURL) that would override the manual proxy.
func SetSystemProxy(addr string) error {
	script := fmt.Sprintf(`
$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

# Save and clear AutoConfigURL (PAC file from other VPN clients)
$autoConfig = (Get-ItemProperty -Path $regPath -Name AutoConfigURL -ErrorAction SilentlyContinue).AutoConfigURL
if ($autoConfig) {
    Write-Host "SAVED_PAC:$autoConfig"
    Remove-ItemProperty -Path $regPath -Name AutoConfigURL -ErrorAction SilentlyContinue
}

# Set manual proxy
Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 1
Set-ItemProperty -Path $regPath -Name ProxyServer -Value '%s'
Set-ItemProperty -Path $regPath -Name ProxyOverride -Value 'localhost;127.*;10.*;172.16.*;192.168.*;<local>'

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinINetProxy {
    [DllImport("wininet.dll", SetLastError=true)]
    public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int lpdwBufferLength);
    public static void Refresh() {
        InternetSetOption(IntPtr.Zero, 39, IntPtr.Zero, 0);
        InternetSetOption(IntPtr.Zero, 37, IntPtr.Zero, 0);
    }
}
"@
[WinINetProxy]::Refresh()
`, addr)

	cmd := exec.Command("powershell", "-ExecutionPolicy", "Bypass", "-Command", script)
	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to set proxy: %w (output: %s)", err, string(out))
	}

	// Parse saved PAC URL from output
	output := string(out)
	for _, line := range splitLines(output) {
		if len(line) > 10 && line[:10] == "SAVED_PAC:" {
			savedAutoConfigURL = line[10:]
			fmt.Printf("[PROXY] Saved PAC URL: %s\n", savedAutoConfigURL)
		}
	}

	return nil
}

// ClearSystemProxy disables the Windows system proxy and restores the original PAC URL.
func ClearSystemProxy() error {
	restorePAC := ""
	if savedAutoConfigURL != "" {
		restorePAC = fmt.Sprintf(`Set-ItemProperty -Path $regPath -Name AutoConfigURL -Value '%s'`, savedAutoConfigURL)
		savedAutoConfigURL = ""
	}

	script := fmt.Sprintf(`
$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 0
%s

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinINetProxyClear {
    [DllImport("wininet.dll", SetLastError=true)]
    public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int lpdwBufferLength);
    public static void Refresh() {
        InternetSetOption(IntPtr.Zero, 39, IntPtr.Zero, 0);
        InternetSetOption(IntPtr.Zero, 37, IntPtr.Zero, 0);
    }
}
"@
[WinINetProxyClear]::Refresh()
`, restorePAC)

	cmd := exec.Command("powershell", "-ExecutionPolicy", "Bypass", "-Command", script)
	if out, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("failed to clear proxy: %w (output: %s)", err, string(out))
	}
	return nil
}

func splitLines(s string) []string {
	var lines []string
	start := 0
	for i := 0; i < len(s); i++ {
		if s[i] == '\n' {
			line := s[start:i]
			if len(line) > 0 && line[len(line)-1] == '\r' {
				line = line[:len(line)-1]
			}
			lines = append(lines, line)
			start = i + 1
		}
	}
	if start < len(s) {
		lines = append(lines, s[start:])
	}
	return lines
}
