package leaktest

import (
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"

	"golang.org/x/net/proxy"
)

// Result contains the results of DNS and IP leak tests.
type Result struct {
	VisibleIP  string   `json:"visibleIp"`
	RealIP     string   `json:"realIp"`
	IPLeaked   bool     `json:"ipLeaked"`
	DNSServers []string `json:"dnsServers"`
	DNSLeaked  bool     `json:"dnsLeaked"`
}

// proxyClient returns an HTTP client that routes through our SOCKS5 proxy.
func proxyClient() *http.Client {
	dialer, err := proxy.SOCKS5("tcp", "127.0.0.1:11808", nil, proxy.Direct)
	if err != nil {
		// Fallback to direct
		return &http.Client{Timeout: 10 * time.Second}
	}
	transport := &http.Transport{
		Dial: dialer.Dial,
	}
	return &http.Client{
		Timeout:   15 * time.Second,
		Transport: transport,
	}
}

// directClient returns an HTTP client that bypasses the proxy.
func directClient() *http.Client {
	transport := &http.Transport{
		Proxy: func(req *http.Request) (*url.URL, error) {
			return nil, nil // no proxy
		},
	}
	return &http.Client{
		Timeout:   10 * time.Second,
		Transport: transport,
	}
}

// RunTest performs a full IP and DNS leak test.
// realIP should be the user's actual IP (detected before VPN connection).
// serverIP is the VPN server's IP address.
func RunTest(realIP string, serverIP string) (*Result, error) {
	result := &Result{
		RealIP: realIP,
	}

	// Test 1: Check visible IP through VPN proxy
	visibleIP, err := getPublicIPViaProxy()
	if err != nil {
		return nil, fmt.Errorf("failed to get public IP via proxy: %w", err)
	}
	result.VisibleIP = visibleIP

	// IP is leaked if visible IP equals real IP (traffic bypasses VPN)
	// If real IP equals server IP, it was detected while VPN was active — not a real leak
	if realIP != "" && realIP != serverIP {
		result.IPLeaked = (visibleIP == realIP)
	} else {
		// Can't determine real IP reliably; check if visible IP is the VPN server
		result.IPLeaked = (serverIP != "" && visibleIP != serverIP)
	}

	// Test 2: DNS leak test through proxy
	dnsServers, err := detectDNSServersViaProxy()
	if err != nil {
		result.DNSServers = []string{fmt.Sprintf("error: %s", err)}
	} else {
		result.DNSServers = dnsServers
	}

	// Check if any DNS server is outside the VPN
	result.DNSLeaked = checkDNSLeak(dnsServers, realIP)

	return result, nil
}

// DetectRealIP gets the user's real IP before VPN connection (direct, no proxy).
func DetectRealIP() (string, error) {
	return getPublicIPDirect()
}

func getPublicIPViaProxy() (string, error) {
	client := proxyClient()
	return fetchPublicIP(client)
}

func getPublicIPDirect() (string, error) {
	client := directClient()
	return fetchPublicIP(client)
}

func fetchPublicIP(client *http.Client) (string, error) {
	apis := []string{
		"https://api.ipify.org",
		"https://ifconfig.me/ip",
		"https://icanhazip.com",
	}

	for _, api := range apis {
		resp, err := client.Get(api)
		if err != nil {
			continue
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			continue
		}

		ip := strings.TrimSpace(string(body))
		if net.ParseIP(ip) != nil {
			return ip, nil
		}
	}

	return "", fmt.Errorf("failed to detect public IP from all sources")
}

func detectDNSServersViaProxy() ([]string, error) {
	client := proxyClient()

	resp, err := client.Get("https://1.1.1.1/cdn-cgi/trace")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	servers := []string{}
	for _, line := range strings.Split(string(body), "\n") {
		if strings.HasPrefix(line, "ip=") {
			servers = append(servers, strings.TrimPrefix(line, "ip="))
		}
	}

	dnsResolvers, err := getDNSResolvers(client)
	if err == nil {
		servers = append(servers, dnsResolvers...)
	}

	return servers, nil
}

func getDNSResolvers(client *http.Client) ([]string, error) {
	resp, err := client.Get("https://dns.google/resolve?name=o-o.myaddr.l.google.com&type=TXT")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var dnsResp struct {
		Answer []struct {
			Data string `json:"data"`
		} `json:"Answer"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&dnsResp); err != nil {
		return nil, err
	}

	var resolvers []string
	for _, ans := range dnsResp.Answer {
		ip := strings.Trim(ans.Data, "\"")
		if net.ParseIP(ip) != nil {
			resolvers = append(resolvers, ip)
		}
	}

	return resolvers, nil
}

func checkDNSLeak(dnsServers []string, realIP string) bool {
	if realIP == "" {
		return false
	}

	realParts := strings.Split(realIP, ".")
	if len(realParts) < 3 {
		return false
	}
	realSubnet := strings.Join(realParts[:3], ".")

	for _, server := range dnsServers {
		serverParts := strings.Split(server, ".")
		if len(serverParts) < 3 {
			continue
		}
		if strings.Join(serverParts[:3], ".") == realSubnet {
			return true
		}
	}

	return false
}
