package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"servc_vpn/core/api"
	"servc_vpn/core/engine"
	"servc_vpn/core/killswitch"
	"servc_vpn/core/leaktest"
)

func main() {
	connectCmd := flag.NewFlagSet("connect", flag.ExitOnError)
	uri := connectCmd.String("uri", "", "VPN config URI (vless://, trojan://, vmess://)")
	fingerprint := connectCmd.String("fingerprint", "chrome", "TLS fingerprint profile (chrome, firefox, safari, edge, random, auto)")
	killSwitch := connectCmd.Bool("killswitch", false, "Enable kill switch")

	parseCmd := flag.NewFlagSet("parse", flag.ExitOnError)
	parseURI := parseCmd.String("uri", "", "URI to parse and display config")

	leakCmd := flag.NewFlagSet("leaktest", flag.ExitOnError)

	serveCmd := flag.NewFlagSet("serve", flag.ExitOnError)
	servePort := serveCmd.String("port", "50051", "gRPC server port")

	profilesCmd := flag.NewFlagSet("profiles", flag.ExitOnError)

	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "connect":
		connectCmd.Parse(os.Args[2:])
		if *uri == "" {
			fmt.Println("Error: --uri is required")
			connectCmd.Usage()
			os.Exit(1)
		}
		runConnect(*uri, *fingerprint, *killSwitch)

	case "parse":
		parseCmd.Parse(os.Args[2:])
		if *parseURI == "" {
			fmt.Println("Error: --uri is required")
			parseCmd.Usage()
			os.Exit(1)
		}
		runParse(*parseURI)

	case "leaktest":
		leakCmd.Parse(os.Args[2:])
		runLeakTest()

	case "serve":
		serveCmd.Parse(os.Args[2:])
		runServe(*servePort)

	case "profiles":
		profilesCmd.Parse(os.Args[2:])
		runProfiles()

	default:
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("ServcVPN CLI - VPN Client with TLS Fingerprint Control")
	fmt.Println()
	fmt.Println("Usage:")
	fmt.Println("  vpncli connect --uri <URI> [--fingerprint <profile>] [--killswitch]")
	fmt.Println("  vpncli serve [--port <port>]")
	fmt.Println("  vpncli parse --uri <URI>")
	fmt.Println("  vpncli leaktest")
	fmt.Println("  vpncli profiles")
	fmt.Println()
	fmt.Println("Commands:")
	fmt.Println("  connect    Connect to a VPN server")
	fmt.Println("  serve      Start gRPC server for GUI communication")
	fmt.Println("  parse      Parse and display a config URI")
	fmt.Println("  leaktest   Run DNS and IP leak test")
	fmt.Println("  profiles   List available TLS fingerprint profiles")
}

func runServe(port string) {
	// Clean up leftover VPN processes from previous sessions
	// so real IP detection works correctly
	engine.CleanupOldProcesses()

	eng := engine.NewEngine()
	ks := killswitch.New()
	server := api.NewVPNServer(eng, ks)

	eng.SetStatusCallback(func(state engine.State, message string) {
		fmt.Printf("[%s] State: %s\n", time.Now().Format("15:04:05"), state)
	})

	// Handle shutdown
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		fmt.Println("\nShutting down...")
		server.Stop()
		_ = eng.Disconnect()
		_ = ks.Disable()
	}()

	fmt.Printf("Starting ServcVPN gRPC server on port %s...\n", port)
	if err := server.Start("127.0.0.1:" + port); err != nil {
		fmt.Printf("Error: %s\n", err)
		os.Exit(1)
	}
}

func runConnect(uri, fingerprint string, killSwitch bool) {
	eng := engine.NewEngine()

	eng.SetStatusCallback(func(state engine.State, message string) {
		fmt.Printf("[%s] State: %s - %s\n", time.Now().Format("15:04:05"), state, message)
	})

	fmt.Printf("Connecting to VPN...\n")
	fmt.Printf("  URI: %s\n", uri)
	fmt.Printf("  TLS Fingerprint: %s\n", fingerprint)
	fmt.Printf("  Kill Switch: %v\n", killSwitch)
	fmt.Println()

	if err := eng.Connect(uri, fingerprint, killSwitch, ""); err != nil {
		fmt.Printf("Error: %s\n", err)
		os.Exit(1)
	}

	fmt.Println("Connected! Press Ctrl+C to disconnect.")
	fmt.Printf("SOCKS5 proxy: 127.0.0.1:11808\n")
	fmt.Printf("HTTP proxy:   127.0.0.1:11809\n")
	fmt.Println()

	// Print stats periodically
	go func() {
		ticker := time.NewTicker(5 * time.Second)
		defer ticker.Stop()
		for range ticker.C {
			stats := eng.GetStats()
			fmt.Printf("[Stats] Upload: %s | Download: %s | Speed: %s/%s | Ping: %dms\n",
				formatBytes(stats.UploadBytes),
				formatBytes(stats.DownloadBytes),
				formatSpeed(stats.UploadSpeed),
				formatSpeed(stats.DownloadSpeed),
				stats.PingMs,
			)
		}
	}()

	// Wait for interrupt
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	fmt.Println("\nDisconnecting...")
	if err := eng.Disconnect(); err != nil {
		fmt.Printf("Error disconnecting: %s\n", err)
		os.Exit(1)
	}
	fmt.Println("Disconnected.")
}

func runParse(uri string) {
	cfg, err := engine.ParseURI(uri)
	if err != nil {
		fmt.Printf("Error parsing URI: %s\n", err)
		os.Exit(1)
	}

	fmt.Printf("Protocol:    %s\n", cfg.Protocol)
	fmt.Printf("Address:     %s:%d\n", cfg.Address, cfg.Port)
	fmt.Printf("UUID:        %s\n", cfg.UUID)
	fmt.Printf("Security:    %s\n", cfg.Security)
	fmt.Printf("Network:     %s\n", cfg.Network)
	fmt.Printf("SNI:         %s\n", cfg.SNI)
	fmt.Printf("Fingerprint: %s\n", cfg.Fingerprint)
	if cfg.Flow != "" {
		fmt.Printf("Flow:        %s\n", cfg.Flow)
	}
	if cfg.PublicKey != "" {
		fmt.Printf("PublicKey:   %s\n", cfg.PublicKey)
	}
	if cfg.ShortID != "" {
		fmt.Printf("ShortID:     %s\n", cfg.ShortID)
	}
	fmt.Printf("Remark:      %s\n", cfg.Remark)

	fmt.Println("\n--- Generated xray-core config ---")
	xrayJSON, err := cfg.ToXrayConfig("chrome")
	if err != nil {
		fmt.Printf("Error generating config: %s\n", err)
		return
	}
	fmt.Println(string(xrayJSON))
}

func runLeakTest() {
	fmt.Println("Running leak test...")
	fmt.Println()

	result, err := leaktest.RunTest("", "")
	if err != nil {
		fmt.Printf("Error: %s\n", err)
		os.Exit(1)
	}

	fmt.Printf("Visible IP:  %s\n", result.VisibleIP)
	if result.RealIP != "" {
		fmt.Printf("Real IP:     %s\n", result.RealIP)
		if result.IPLeaked {
			fmt.Println("IP Leak:     YES - Your real IP is exposed!")
		} else {
			fmt.Println("IP Leak:     NO - IP is hidden")
		}
	}

	fmt.Println()
	fmt.Println("DNS Servers:")
	for _, s := range result.DNSServers {
		fmt.Printf("  - %s\n", s)
	}
	if result.DNSLeaked {
		fmt.Println("DNS Leak:    YES - DNS requests may be exposed!")
	} else {
		fmt.Println("DNS Leak:    NO - DNS is protected")
	}
}

func runProfiles() {
	mgr := engine.NewTLSProfileManager()
	profiles := mgr.GetAvailableProfiles()

	fmt.Println("Available TLS Fingerprint Profiles:")
	fmt.Println()
	for _, p := range profiles {
		fmt.Printf("  %-12s  %s\n", p.Fingerprint, p.Description)
	}
}

func formatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(b)/float64(div), "KMG"[exp])
}

func formatSpeed(bps int64) string {
	return formatBytes(bps) + "/s"
}
