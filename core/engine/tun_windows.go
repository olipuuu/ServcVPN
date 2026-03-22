package engine

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

const (
	tunAdapterName = "ServcVPN"
	tunAdapterIP   = "10.0.85.1"
	tunSubnetMask  = "255.255.255.0"
	tunMetric      = "5"
)

// TUNManager manages the tun2socks process and network routes.
type TUNManager struct {
	cmd        *exec.Cmd
	devNull    *os.File
	serverIP   string
	gatewayIP  string
	tunIfIndex string
}

// NewTUNManager creates a new TUN manager.
func NewTUNManager() *TUNManager {
	return &TUNManager{}
}

// Start creates a TUN adapter via tun2socks and routes all traffic through it.
// socksAddr is the SOCKS5 proxy address (e.g. "127.0.0.1:11808").
// vpnServerIP is the remote VPN server IP that must be excluded from TUN routing.
func (t *TUNManager) Start(socksAddr string, vpnServerIP string) error {
	// Find tun2socks binary next to vpncli.exe
	tunPath, err := findTun2SocksBinary()
	if err != nil {
		return err
	}

	t.serverIP = vpnServerIP

	// Save the current default gateway before we modify routes
	gw, err := getDefaultGateway()
	if err != nil {
		return fmt.Errorf("failed to get default gateway: %w", err)
	}
	t.gatewayIP = gw
	fmt.Printf("[TUN] Original default gateway: %s\n", t.gatewayIP)

	// Open NUL for tun2socks output
	devNull, err := os.OpenFile(os.DevNull, os.O_WRONLY, 0)
	if err != nil {
		return fmt.Errorf("failed to open devnull: %w", err)
	}
	t.devNull = devNull

	// Start tun2socks with DETACHED_PROCESS (same as xray)
	fmt.Printf("[TUN] Starting tun2socks: %s\n", tunPath)
	cmd := exec.Command(tunPath,
		"-device", "tun://"+tunAdapterName,
		"-proxy", "socks5://"+socksAddr,
	)
	cmd.Dir = filepath.Dir(tunPath)
	cmd.Stdout = devNull
	cmd.Stderr = devNull
	cmd.SysProcAttr = &syscall.SysProcAttr{
		CreationFlags: 0x00000008, // DETACHED_PROCESS
	}

	if err := cmd.Start(); err != nil {
		devNull.Close()
		return fmt.Errorf("failed to start tun2socks (run vpncli as admin): %w", err)
	}
	t.cmd = cmd
	fmt.Printf("[TUN] tun2socks started with PID %d\n", cmd.Process.Pid)

	// Wait for the TUN adapter to appear
	fmt.Println("[TUN] Waiting for TUN adapter to appear...")
	if err := waitForAdapter(tunAdapterName, 10*time.Second); err != nil {
		t.Stop()
		return fmt.Errorf("TUN adapter did not appear: %w", err)
	}
	fmt.Println("[TUN] TUN adapter detected")

	// Configure the TUN adapter IP address via netsh
	fmt.Printf("[TUN] Setting adapter IP to %s/%s\n", tunAdapterIP, tunSubnetMask)
	if out, err := exec.Command("netsh", "interface", "ip", "set", "address",
		tunAdapterName, "static", tunAdapterIP, tunSubnetMask).CombinedOutput(); err != nil {
		fmt.Printf("[TUN] netsh output: %s\n", string(out))
		t.Stop()
		return fmt.Errorf("failed to set TUN adapter IP: %w", err)
	}

	// Wait for IP and adapter to be fully ready
	time.Sleep(2 * time.Second)

	// Set up routing
	if err := t.setupRoutes(); err != nil {
		t.Stop()
		return fmt.Errorf("failed to set up routes: %w", err)
	}

	// Monitor tun2socks process in background
	go func() {
		cmd.Wait()
		if t.devNull != nil {
			t.devNull.Close()
		}
	}()

	return nil
}

// Stop tears down the TUN adapter and restores original routing.
func (t *TUNManager) Stop() {
	// Remove routes first (before killing tun2socks)
	t.cleanupRoutes()

	// Kill our tun2socks process
	if t.cmd != nil && t.cmd.Process != nil {
		fmt.Printf("[TUN] Killing tun2socks PID %d\n", t.cmd.Process.Pid)
		t.cmd.Process.Kill()
		t.cmd.Process.Wait()
	}

	// Fallback: kill any leftover tun2socks
	exec.Command("taskkill", "/F", "/IM", "tun2socks-windows-amd64.exe").Run()

	if t.devNull != nil {
		t.devNull.Close()
		t.devNull = nil
	}

	t.cmd = nil
	t.serverIP = ""
	t.gatewayIP = ""
}

// setupRoutes adds routes so that:
// 1. VPN server IP goes via original gateway (prevents routing loop)
// 2. All other traffic goes via TUN adapter using split routing (/1 routes)
//    Split routing uses two /1 routes instead of one /0 route.
//    /1 routes are MORE SPECIFIC than /0 and always win regardless of metric.
//    This beats any existing default route (including WSL/Docker with metric 0).
func (t *TUNManager) setupRoutes() error {
	// Get TUN adapter interface index
	tunIfIndex, err := getAdapterIndex(tunAdapterName)
	if err != nil {
		return fmt.Errorf("failed to get TUN adapter index: %w", err)
	}
	t.tunIfIndex = tunIfIndex
	fmt.Printf("[TUN] TUN adapter interface index: %s\n", tunIfIndex)

	// Route VPN server IP through original gateway to prevent loop
	fmt.Printf("[TUN] Adding route: %s via %s (VPN server bypass)\n", t.serverIP, t.gatewayIP)
	out, err := exec.Command("route", "add", t.serverIP, "mask", "255.255.255.255",
		t.gatewayIP).CombinedOutput()
	fmt.Printf("[TUN] route add server result: %s\n", strings.TrimSpace(string(out)))
	if err != nil {
		return fmt.Errorf("failed to add server route: %w", err)
	}

	// Split routing: two /1 routes with explicit interface index
	fmt.Printf("[TUN] Adding split route 0.0.0.0/1 via %s IF %s\n", tunAdapterIP, tunIfIndex)
	out, err = exec.Command("route", "add", "0.0.0.0", "mask", "128.0.0.0",
		tunAdapterIP, "metric", tunMetric, "IF", tunIfIndex).CombinedOutput()
	fmt.Printf("[TUN] route add 0/1 result: %s\n", strings.TrimSpace(string(out)))
	if err != nil {
		return fmt.Errorf("failed to add split route 1: %w", err)
	}

	fmt.Printf("[TUN] Adding split route 128.0.0.0/1 via %s IF %s\n", tunAdapterIP, tunIfIndex)
	out, err = exec.Command("route", "add", "128.0.0.0", "mask", "128.0.0.0",
		tunAdapterIP, "metric", tunMetric, "IF", tunIfIndex).CombinedOutput()
	fmt.Printf("[TUN] route add 128/1 result: %s\n", strings.TrimSpace(string(out)))
	if err != nil {
		return fmt.Errorf("failed to add split route 2: %w", err)
	}

	// Verify routes were added
	verifyOut, _ := exec.Command("route", "print").CombinedOutput()
	routeTable := string(verifyOut)
	if strings.Contains(routeTable, "128.0.0.0") && strings.Contains(routeTable, tunAdapterIP) {
		fmt.Println("[TUN] Routes verified in route table")
	} else {
		fmt.Println("[TUN] WARNING: Routes may not have been applied correctly")
	}

	fmt.Println("[TUN] Routes configured successfully")
	return nil
}

// cleanupRoutes removes the routes we added.
func (t *TUNManager) cleanupRoutes() {
	if t.serverIP != "" {
		fmt.Printf("[TUN] Removing route for VPN server %s\n", t.serverIP)
		exec.Command("route", "delete", t.serverIP).Run()
	}
	fmt.Println("[TUN] Removing split routes via TUN")
	exec.Command("route", "delete", "0.0.0.0", "mask", "128.0.0.0", tunAdapterIP).Run()
	exec.Command("route", "delete", "128.0.0.0", "mask", "128.0.0.0", tunAdapterIP).Run()
}

// waitForAdapter polls until the named network adapter appears or times out.
func waitForAdapter(name string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		ifaces, err := net.Interfaces()
		if err == nil {
			for _, iface := range ifaces {
				if iface.Name == name {
					return nil
				}
			}
		}
		time.Sleep(500 * time.Millisecond)
	}
	return fmt.Errorf("adapter %q not found after %s", name, timeout)
}

// findTun2SocksBinary locates the tun2socks executable next to vpncli.exe or in PATH.
func findTun2SocksBinary() (string, error) {
	// Check next to our own executable (same logic as findXrayBinary)
	exePath, err := os.Executable()
	if err == nil {
		exeDir := filepath.Dir(exePath)
		candidates := []string{
			filepath.Join(exeDir, "tun2socks-windows-amd64.exe"),
			filepath.Join(exeDir, "tun2socks.exe"),
		}
		for _, c := range candidates {
			if _, err := os.Stat(c); err == nil {
				return c, nil
			}
		}
	}

	// Check in PATH
	if p, err := exec.LookPath("tun2socks-windows-amd64.exe"); err == nil {
		return p, nil
	}
	if p, err := exec.LookPath("tun2socks.exe"); err == nil {
		return p, nil
	}

	return "", fmt.Errorf("tun2socks binary not found; place tun2socks-windows-amd64.exe next to vpncli.exe or add to PATH")
}

// getAdapterIndex returns the interface index for a named network adapter.
func getAdapterIndex(name string) (string, error) {
	out, err := exec.Command("powershell", "-Command",
		fmt.Sprintf("(Get-NetAdapter -Name '%s' -ErrorAction SilentlyContinue).ifIndex", name)).Output()
	if err != nil {
		return "", fmt.Errorf("failed to get adapter index: %w", err)
	}
	idx := strings.TrimSpace(string(out))
	if idx == "" {
		return "", fmt.Errorf("adapter %q not found", name)
	}
	return idx, nil
}

// getDefaultGateway returns the current default gateway IP address.
func getDefaultGateway() (string, error) {
	out, err := exec.Command("powershell", "-Command",
		"(Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Where-Object { $_.NextHop -ne '0.0.0.0' } | Sort-Object RouteMetric | Select-Object -First 1).NextHop").Output()
	if err != nil {
		return "", fmt.Errorf("failed to query default gateway: %w", err)
	}
	gw := strings.TrimSpace(string(out))
	if gw == "" {
		return "", fmt.Errorf("no default gateway found")
	}
	if net.ParseIP(gw) == nil {
		return "", fmt.Errorf("invalid gateway IP: %s", gw)
	}
	return gw, nil
}
