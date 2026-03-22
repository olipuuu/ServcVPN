package killswitch

import (
	"fmt"
	"os/exec"
	"sync"
)

// KillSwitch manages Windows firewall rules to block all traffic except VPN.
type KillSwitch struct {
	mu      sync.Mutex
	enabled bool
}

const (
	ruleNameBlockAll   = "ServcVPN_BlockAll"
	ruleNameAllowVPN   = "ServcVPN_AllowVPN"
	ruleNameAllowLocal = "ServcVPN_AllowLocal"
	ruleNameAllowDHCP  = "ServcVPN_AllowDHCP"
	ruleNameAllowDNS   = "ServcVPN_AllowDNS"
	ruleNameAllowTUN   = "ServcVPN_AllowTUN"
)

// New creates a new KillSwitch instance.
func New() *KillSwitch {
	return &KillSwitch{}
}

// Enable activates the kill switch, blocking all traffic except to the VPN server.
func (ks *KillSwitch) Enable(vpnServerIP string, vpnServerPort int) error {
	ks.mu.Lock()
	defer ks.mu.Unlock()

	if ks.enabled {
		return nil
	}

	// Clean up any existing rules
	ks.cleanup()

	// Allow traffic to VPN server (TCP)
	if err := ks.netshAdd(ruleNameAllowVPN+"_TCP",
		"dir=out", "action=allow",
		fmt.Sprintf("remoteip=%s", vpnServerIP),
		"protocol=tcp",
		fmt.Sprintf("remoteport=%d", vpnServerPort),
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add VPN TCP rule: %w", err)
	}

	// Allow traffic to VPN server (UDP)
	if err := ks.netshAdd(ruleNameAllowVPN+"_UDP",
		"dir=out", "action=allow",
		fmt.Sprintf("remoteip=%s", vpnServerIP),
		"protocol=udp",
		fmt.Sprintf("remoteport=%d", vpnServerPort),
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add VPN UDP rule: %w", err)
	}

	// Allow local network traffic
	if err := ks.netshAdd(ruleNameAllowLocal,
		"dir=out", "action=allow",
		"remoteip=LocalSubnet",
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add local rule: %w", err)
	}

	// Allow DHCP (protocol must come before port)
	if err := ks.netshAdd(ruleNameAllowDHCP,
		"dir=out", "action=allow",
		"protocol=udp",
		"remoteport=67,68",
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add DHCP rule: %w", err)
	}

	// Allow DNS through TUN
	if err := ks.netshAdd(ruleNameAllowDNS,
		"dir=out", "action=allow",
		"protocol=udp",
		"remoteport=53",
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add DNS rule: %w", err)
	}

	// Allow loopback (for xray SOCKS proxy)
	if err := ks.netshAdd(ruleNameAllowTUN,
		"dir=out", "action=allow",
		"remoteip=127.0.0.1",
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add loopback rule: %w", err)
	}

	// Block all other outbound traffic
	if err := ks.netshAdd(ruleNameBlockAll,
		"dir=out", "action=block",
	); err != nil {
		ks.cleanup()
		return fmt.Errorf("failed to add block rule: %w", err)
	}

	ks.enabled = true
	fmt.Println("[KILLSWITCH] Enabled")
	return nil
}

// Disable deactivates the kill switch, restoring normal traffic.
func (ks *KillSwitch) Disable() error {
	ks.mu.Lock()
	defer ks.mu.Unlock()

	if !ks.enabled {
		return nil
	}

	ks.cleanup()
	ks.enabled = false
	fmt.Println("[KILLSWITCH] Disabled")
	return nil
}

// IsEnabled returns whether the kill switch is active.
func (ks *KillSwitch) IsEnabled() bool {
	ks.mu.Lock()
	defer ks.mu.Unlock()
	return ks.enabled
}

// netshAdd adds a firewall rule using proper argument passing (no string splitting).
func (ks *KillSwitch) netshAdd(name string, args ...string) error {
	cmdArgs := []string{"advfirewall", "firewall", "add", "rule", fmt.Sprintf("name=%s", name)}
	cmdArgs = append(cmdArgs, args...)
	cmd := exec.Command("netsh", cmdArgs...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("%s: %s", err, string(output))
	}
	return nil
}

func (ks *KillSwitch) cleanup() {
	rules := []string{
		ruleNameBlockAll,
		ruleNameAllowVPN + "_TCP",
		ruleNameAllowVPN + "_UDP",
		ruleNameAllowLocal,
		ruleNameAllowDHCP,
		ruleNameAllowDNS,
		ruleNameAllowTUN,
	}
	for _, name := range rules {
		exec.Command("netsh", "advfirewall", "firewall", "delete", "rule", fmt.Sprintf("name=%s", name)).Run()
	}
}
