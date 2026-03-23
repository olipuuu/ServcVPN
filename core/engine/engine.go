package engine

import (
	"encoding/json"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"time"
)

// State represents VPN connection state.
type State string

const (
	StateDisconnected  State = "disconnected"
	StateConnecting    State = "connecting"
	StateConnected     State = "connected"
	StateDisconnecting State = "disconnecting"
)

// StatusCallback is called when VPN state changes.
type StatusCallback func(state State, message string)

// Engine manages the VPN connection lifecycle.
type Engine struct {
	mu             sync.RWMutex
	xrayCmd        *exec.Cmd
	tunManager     *TUNManager
	state          State
	config         *ServerConfig
	stats          *Stats
	tlsProfile     *TLSProfileManager
	onStatusChange StatusCallback
	connectedAt    time.Time
	xrayPath       string
	configPath     string
}

// NewEngine creates a new VPN engine.
func NewEngine() *Engine {
	return &Engine{
		state:      StateDisconnected,
		stats:      NewStats(),
		tlsProfile: NewTLSProfileManager(),
	}
}

// SetStatusCallback sets the callback for state changes.
func (e *Engine) SetStatusCallback(cb StatusCallback) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.onStatusChange = cb
}

// findXrayBinary locates the xray executable.
func findXrayBinary() (string, error) {
	// Check next to our executable
	exePath, err := os.Executable()
	if err == nil {
		exeDir := filepath.Dir(exePath)
		candidates := []string{
			filepath.Join(exeDir, "xray.exe"),
			filepath.Join(exeDir, "xray"),
		}
		for _, c := range candidates {
			if _, err := os.Stat(c); err == nil {
				return c, nil
			}
		}
	}

	// Check in PATH
	if p, err := exec.LookPath("xray"); err == nil {
		return p, nil
	}
	if p, err := exec.LookPath("xray.exe"); err == nil {
		return p, nil
	}

	return "", fmt.Errorf("xray binary not found; place xray.exe next to vpncli.exe or add to PATH")
}

// killOurXray kills only the xray process we started (by checking port 11808).
func killOurXray() {
	// Find PID listening on our port 11808
	out, err := exec.Command("powershell", "-Command",
		"(Get-NetTCPConnection -LocalPort 11808 -State Listen -ErrorAction SilentlyContinue).OwningProcess").Output()
	if err != nil || len(strings.TrimSpace(string(out))) == 0 {
		return // no process on our port
	}
	pid := strings.TrimSpace(string(out))
	if pid != "" && pid != "0" {
		fmt.Printf("[ENGINE] Killing our old xray PID %s on port 11808\n", pid)
		exec.Command("taskkill", "/F", "/PID", pid).Run()
		time.Sleep(500 * time.Millisecond)
	}
}

// CleanupOldProcesses kills leftover xray/tun2socks and removes TUN routes
// so that real IP detection works correctly at startup.
func CleanupOldProcesses() {
	// Kill old xray on our port
	killOurXray()
	// Kill leftover tun2socks
	exec.Command("taskkill", "/F", "/IM", "tun2socks-windows-amd64.exe").Run()
	// Remove TUN split routes
	exec.Command("route", "delete", "0.0.0.0", "mask", "128.0.0.0").Run()
	exec.Command("route", "delete", "128.0.0.0", "mask", "128.0.0.0").Run()
	time.Sleep(500 * time.Millisecond)
	fmt.Println("[CLEANUP] Old VPN processes and routes cleaned up")
}

// ConnectWithFallback tries multiple config URIs in order until one connects.
func (e *Engine) ConnectWithFallback(configURIs []string, fingerprint string, enableKillSwitch bool, maskingSNI string) error {
	if len(configURIs) == 0 {
		return fmt.Errorf("no config URIs provided")
	}

	var lastErr error
	for i, uri := range configURIs {
		uri = strings.TrimSpace(uri)
		if uri == "" {
			continue
		}
		fmt.Printf("[ENGINE] Trying protocol %d/%d: %s\n", i+1, len(configURIs), uriProtocol(uri))
		err := e.Connect(uri, fingerprint, enableKillSwitch, maskingSNI)
		if err == nil {
			fmt.Printf("[ENGINE] Connected via protocol %d/%d\n", i+1, len(configURIs))
			return nil
		}
		lastErr = err
		fmt.Printf("[ENGINE] Protocol %d/%d failed: %s\n", i+1, len(configURIs), err)
		// Reset state for next attempt
		e.mu.Lock()
		e.state = StateDisconnected
		e.mu.Unlock()
		time.Sleep(1 * time.Second)
	}
	return fmt.Errorf("all %d protocols failed, last error: %w", len(configURIs), lastErr)
}

// uriProtocol extracts protocol name from URI for logging.
func uriProtocol(uri string) string {
	if idx := strings.Index(uri, "://"); idx > 0 {
		return uri[:idx]
	}
	return "unknown"
}

// Connect establishes a VPN connection by launching xray as a subprocess.
func (e *Engine) Connect(configURI string, fingerprint string, enableKillSwitch bool, maskingSNI string) error {
	e.mu.Lock()
	if e.state == StateConnected || e.state == StateConnecting {
		e.mu.Unlock()
		// Force disconnect before reconnecting
		fmt.Println("[ENGINE] Force disconnecting before new connection...")
		e.Disconnect()
		e.mu.Lock()
	}
	e.setState(StateConnecting)
	e.mu.Unlock()

	// Kill only our old xray if still running (don't touch user's other VPN)
	killOurXray()

	// Find xray binary
	xrayPath, err := findXrayBinary()
	if err != nil {
		e.setState(StateDisconnected)
		return err
	}

	// Parse URI
	serverCfg, err := ParseURI(configURI)
	if err != nil {
		e.setState(StateDisconnected)
		return fmt.Errorf("failed to parse config URI: %w", err)
	}

	// Apply TLS fingerprint
	fp := e.tlsProfile.GetActiveFingerprint()
	if fingerprint != "" {
		fp = fingerprint
	}

	// Generate xray-core config (with optional SNI masking)
	xrayConfigJSON, err := serverCfg.ToXrayConfig(fp, maskingSNI)
	if err != nil {
		e.setState(StateDisconnected)
		return fmt.Errorf("failed to generate xray config: %w", err)
	}

	// Write temp config file
	tmpDir := os.TempDir()
	configPath := filepath.Join(tmpDir, "servc_vpn_xray.json")
	if err := os.WriteFile(configPath, xrayConfigJSON, 0600); err != nil {
		e.setState(StateDisconnected)
		return fmt.Errorf("failed to write config: %w", err)
	}

	// Launch xray directly with DETACHED_PROCESS flag
	fmt.Printf("[ENGINE] Starting xray: %s\n", xrayPath)
	fmt.Printf("[ENGINE] Config: %s\n", configPath)

	// Redirect xray stdout/stderr to NUL; xray writes its own logs via config
	devNull, err := os.OpenFile(os.DevNull, os.O_WRONLY, 0)
	if err != nil {
		e.setState(StateDisconnected)
		return fmt.Errorf("failed to open devnull: %w", err)
	}

	cmd := exec.Command(xrayPath, "run", "-c", configPath)
	cmd.Dir = filepath.Dir(xrayPath)
	cmd.Stdout = devNull
	cmd.Stderr = devNull
	cmd.SysProcAttr = &syscall.SysProcAttr{
		CreationFlags: 0x00000008, // DETACHED_PROCESS
	}

	if err := cmd.Start(); err != nil {
		devNull.Close()
		e.setState(StateDisconnected)
		return fmt.Errorf("failed to start xray: %w", err)
	}
	fmt.Printf("[ENGINE] xray started with PID %d\n", cmd.Process.Pid)

	// Store PID and paths for restart capability
	e.mu.Lock()
	e.xrayCmd = cmd
	e.xrayPath = xrayPath
	e.configPath = configPath
	e.mu.Unlock()

	// Wait for xray to bind to ports
	fmt.Println("[ENGINE] Waiting for xray to start listening...")
	ready := false
	for i := 0; i < 10; i++ {
		time.Sleep(500 * time.Millisecond)
		conn, err := net.Dial("tcp", "127.0.0.1:11808")
		if err == nil {
			conn.Close()
			ready = true
			fmt.Println("[ENGINE] xray is ready on port 11808")
			break
		}
	}
	if !ready {
		// Kill xray if it didn't bind
		cmd.Process.Kill()
		devNull.Close()
		e.setState(StateDisconnected)
		return fmt.Errorf("xray failed to start listening on port 11808")
	}

	e.mu.Lock()
	e.config = serverCfg
	e.connectedAt = time.Now()
	e.stats.Reset()
	e.stats.Start()
	e.mu.Unlock()

	// Start TUN mode: create TUN adapter and route all traffic through it
	fmt.Println("[ENGINE] Starting TUN mode...")
	tunMgr := NewTUNManager()
	if err := tunMgr.Start("127.0.0.1:11808", serverCfg.Address); err != nil {
		fmt.Printf("[ENGINE] ERROR: TUN setup failed: %s\n", err)
		// Kill xray since TUN failed
		cmd.Process.Kill()
		devNull.Close()
		e.setState(StateDisconnected)
		return fmt.Errorf("TUN setup failed: %w", err)
	}
	fmt.Println("[ENGINE] TUN mode active")

	e.mu.Lock()
	e.tunManager = tunMgr
	e.mu.Unlock()

	e.setState(StateConnected)

	// Health monitor: restart xray if it dies, never give up
	go func() {
		failCount := 0
		const maxFails = 5 // 5 consecutive fails before restart attempt
		for {
			time.Sleep(60 * time.Second) // check every 60s
			e.mu.RLock()
			state := e.state
			e.mu.RUnlock()
			if state != StateConnected {
				devNull.Close()
				return
			}

			// Port check with 5 retries, increasing timeout
			portOk := false
			for attempt := 0; attempt < 5; attempt++ {
				conn, err := net.DialTimeout("tcp", "127.0.0.1:11808", 5*time.Second)
				if err == nil {
					conn.Close()
					portOk = true
					break
				}
				time.Sleep(5 * time.Second)
			}
			if portOk {
				failCount = 0
				continue
			}
			failCount++
			fmt.Printf("[ENGINE] xray port 11808 check failed (%d/%d)\n", failCount, maxFails)

			if failCount >= maxFails {
				fmt.Println("[ENGINE] xray unreachable, restarting...")
				if e.restartXray() {
					failCount = 0
					fmt.Println("[ENGINE] xray restarted successfully")
				} else {
					fmt.Println("[ENGINE] xray restart failed, will retry in 120s...")
					time.Sleep(60 * time.Second)
				}
			}
		}
	}()

	return nil
}

// restartXray kills the old xray and starts a new one using saved config.
func (e *Engine) restartXray() bool {
	e.mu.Lock()
	xrayPath := e.xrayPath
	configPath := e.configPath
	if e.xrayCmd != nil && e.xrayCmd.Process != nil {
		e.xrayCmd.Process.Kill()
	}
	e.mu.Unlock()

	if xrayPath == "" || configPath == "" {
		return false
	}

	// Kill any leftover xray on our port
	killOurXray()
	time.Sleep(1 * time.Second)

	devNull, err := os.OpenFile(os.DevNull, os.O_WRONLY, 0)
	if err != nil {
		return false
	}

	cmd := exec.Command(xrayPath, "run", "-c", configPath)
	cmd.Dir = filepath.Dir(xrayPath)
	cmd.Stdout = devNull
	cmd.Stderr = devNull
	cmd.SysProcAttr = &syscall.SysProcAttr{
		CreationFlags: 0x00000008, // DETACHED_PROCESS
	}

	if err := cmd.Start(); err != nil {
		devNull.Close()
		return false
	}
	fmt.Printf("[ENGINE] xray restarted with PID %d\n", cmd.Process.Pid)

	e.mu.Lock()
	e.xrayCmd = cmd
	e.mu.Unlock()

	// Wait for xray to bind
	for i := 0; i < 10; i++ {
		time.Sleep(500 * time.Millisecond)
		conn, err := net.Dial("tcp", "127.0.0.1:11808")
		if err == nil {
			conn.Close()
			return true
		}
	}
	return false
}

// Disconnect tears down the VPN connection.
func (e *Engine) Disconnect() error {
	e.mu.Lock()
	if e.state == StateDisconnected {
		e.mu.Unlock()
		return nil
	}
	e.setState(StateDisconnecting)
	e.mu.Unlock()

	// Tear down TUN first (removes routes before killing processes)
	e.mu.Lock()
	if e.tunManager != nil {
		fmt.Println("[ENGINE] Stopping TUN...")
		e.tunManager.Stop()
		e.tunManager = nil
	}
	e.mu.Unlock()

	// Kill xray by stored PID first, then fallback to port-based kill
	e.mu.Lock()
	if e.xrayCmd != nil && e.xrayCmd.Process != nil {
		fmt.Printf("[ENGINE] Killing xray PID %d\n", e.xrayCmd.Process.Pid)
		e.xrayCmd.Process.Kill()
		e.xrayCmd.Process.Wait()
	}
	e.mu.Unlock()

	// Fallback: kill by port in case PID didn't work
	killOurXray()

	e.mu.Lock()
	e.xrayCmd = nil
	e.config = nil
	e.stats.Stop()
	e.mu.Unlock()

	e.setState(StateDisconnected)

	return nil
}

// GetState returns the current VPN state.
func (e *Engine) GetState() State {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.state
}

// GetStats returns the current connection statistics.
func (e *Engine) GetStats() StatsSnapshot {
	e.mu.RLock()
	defer e.mu.RUnlock()

	snapshot := e.stats.Snapshot()
	snapshot.State = string(e.state)
	if !e.connectedAt.IsZero() && e.state == StateConnected {
		snapshot.ConnectedSince = e.connectedAt.Unix()
	}
	return snapshot
}

// GetConfig returns the current server config.
func (e *Engine) GetConfig() *ServerConfig {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.config
}

// GetConfigJSON returns the current xray-core config as JSON string (for debugging).
func (e *Engine) GetConfigJSON() string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if e.config == nil {
		return "{}"
	}
	data, err := e.config.ToXrayConfig(e.tlsProfile.GetActiveFingerprint())
	if err != nil {
		return fmt.Sprintf(`{"error": "%s"}`, err.Error())
	}

	var pretty json.RawMessage = data
	prettyJSON, err := json.MarshalIndent(pretty, "", "  ")
	if err != nil {
		return string(data)
	}
	return string(prettyJSON)
}

// TLSProfile returns the TLS profile manager.
func (e *Engine) TLSProfile() *TLSProfileManager {
	return e.tlsProfile
}

func (e *Engine) setState(state State) {
	e.state = state
	if e.onStatusChange != nil {
		go e.onStatusChange(state, string(state))
	}
}
