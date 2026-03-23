package engine

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

// ServerConfig holds parsed VPN server configuration.
type ServerConfig struct {
	Protocol    string            `json:"protocol"`
	UUID        string            `json:"uuid"`
	Address     string            `json:"address"`
	Port        int               `json:"port"`
	Encryption  string            `json:"encryption"`
	Flow        string            `json:"flow"`
	Security    string            `json:"security"`   // tls, reality, none
	SNI         string            `json:"sni"`
	Fingerprint string            `json:"fingerprint"` // uTLS fingerprint
	PublicKey   string            `json:"publicKey"`   // Reality public key
	ShortID     string            `json:"shortId"`     // Reality short ID
	SpiderX     string            `json:"spiderX"`     // Reality spiderX
	Network     string            `json:"network"`     // tcp, ws, grpc, http
	ALPN        []string          `json:"alpn"`
	Remark      string            `json:"remark"`
	Extra       map[string]string `json:"extra"`
}

// ParseURI parses a vless://, vmess://, or trojan:// URI into ServerConfig.
func ParseURI(uri string) (*ServerConfig, error) {
	uri = strings.TrimSpace(uri)

	if strings.HasPrefix(uri, "vless://") {
		return parseVLESS(uri)
	}
	if strings.HasPrefix(uri, "vmess://") {
		return parseVMess(uri)
	}
	if strings.HasPrefix(uri, "trojan://") {
		return parseTrojan(uri)
	}

	return nil, fmt.Errorf("unsupported protocol URI: %s", uri)
}

func parseVLESS(uri string) (*ServerConfig, error) {
	// vless://uuid@host:port?params#remark
	parsed, err := url.Parse(uri)
	if err != nil {
		return nil, fmt.Errorf("invalid vless URI: %w", err)
	}

	port, err := strconv.Atoi(parsed.Port())
	if err != nil {
		return nil, fmt.Errorf("invalid port in vless URI: %w", err)
	}

	params := parsed.Query()

	cfg := &ServerConfig{
		Protocol:    "vless",
		UUID:        parsed.User.Username(),
		Address:     parsed.Hostname(),
		Port:        port,
		Encryption:  params.Get("encryption"),
		Flow:        params.Get("flow"),
		Security:    params.Get("security"),
		SNI:         params.Get("sni"),
		Fingerprint: params.Get("fp"),
		PublicKey:   params.Get("pbk"),
		ShortID:     params.Get("sid"),
		SpiderX:     params.Get("spx"),
		Network:     params.Get("type"),
		Remark:      parsed.Fragment,
		Extra:       make(map[string]string),
	}

	if cfg.Encryption == "" {
		cfg.Encryption = "none"
	}
	if cfg.Network == "" {
		cfg.Network = "tcp"
	}

	alpn := params.Get("alpn")
	if alpn != "" {
		cfg.ALPN = strings.Split(alpn, ",")
	}

	return cfg, nil
}

func parseTrojan(uri string) (*ServerConfig, error) {
	// trojan://password@host:port?params#remark
	parsed, err := url.Parse(uri)
	if err != nil {
		return nil, fmt.Errorf("invalid trojan URI: %w", err)
	}

	port, err := strconv.Atoi(parsed.Port())
	if err != nil {
		return nil, fmt.Errorf("invalid port in trojan URI: %w", err)
	}

	params := parsed.Query()

	cfg := &ServerConfig{
		Protocol:    "trojan",
		UUID:        parsed.User.Username(),
		Address:     parsed.Hostname(),
		Port:        port,
		Security:    params.Get("security"),
		SNI:         params.Get("sni"),
		Fingerprint: params.Get("fp"),
		PublicKey:   params.Get("pbk"),
		ShortID:     params.Get("sid"),
		SpiderX:     params.Get("spx"),
		Network:     params.Get("type"),
		Remark:      parsed.Fragment,
		Extra:       make(map[string]string),
	}

	if cfg.Security == "" {
		cfg.Security = "tls"
	}
	if cfg.Network == "" {
		cfg.Network = "tcp"
	}

	alpn := params.Get("alpn")
	if alpn != "" {
		cfg.ALPN = strings.Split(alpn, ",")
	}

	return cfg, nil
}

func parseVMess(uri string) (*ServerConfig, error) {
	// vmess://base64json
	raw := strings.TrimPrefix(uri, "vmess://")

	// Handle both standard and URL-safe base64
	raw = strings.TrimRight(raw, "=")
	raw = strings.ReplaceAll(raw, "-", "+")
	raw = strings.ReplaceAll(raw, "_", "/")

	// Pad base64 string
	switch len(raw) % 4 {
	case 2:
		raw += "=="
	case 3:
		raw += "="
	}

	decoded, err := decodeBase64(raw)
	if err != nil {
		return nil, fmt.Errorf("invalid vmess base64: %w", err)
	}

	var vmess struct {
		V    interface{} `json:"v"`
		PS   string      `json:"ps"`
		Add  string      `json:"add"`
		Port interface{} `json:"port"`
		ID   string      `json:"id"`
		Aid  interface{} `json:"aid"`
		Net  string      `json:"net"`
		Type string      `json:"type"`
		Host string      `json:"host"`
		Path string      `json:"path"`
		TLS  string      `json:"tls"`
		SNI  string      `json:"sni"`
		ALPN string      `json:"alpn"`
		FP   string      `json:"fp"`
	}

	if err := json.Unmarshal(decoded, &vmess); err != nil {
		return nil, fmt.Errorf("invalid vmess JSON: %w", err)
	}

	port := 0
	switch v := vmess.Port.(type) {
	case float64:
		port = int(v)
	case string:
		port, _ = strconv.Atoi(v)
	}

	cfg := &ServerConfig{
		Protocol:    "vmess",
		UUID:        vmess.ID,
		Address:     vmess.Add,
		Port:        port,
		Network:     vmess.Net,
		Security:    vmess.TLS,
		SNI:         vmess.SNI,
		Fingerprint: vmess.FP,
		Remark:      vmess.PS,
		Extra: map[string]string{
			"host": vmess.Host,
			"path": vmess.Path,
			"type": vmess.Type,
		},
	}

	if vmess.ALPN != "" {
		cfg.ALPN = strings.Split(vmess.ALPN, ",")
	}

	return cfg, nil
}

func decodeBase64(s string) ([]byte, error) {
	return base64.StdEncoding.DecodeString(s)
}

// ToXrayConfig converts ServerConfig to xray-core JSON configuration.
// maskingSNI overrides the SNI to disguise traffic as a different service.
func (c *ServerConfig) ToXrayConfig(fingerprint string, maskingSNI ...string) ([]byte, error) {
	if fingerprint != "" {
		c.Fingerprint = fingerprint
	}
	if c.Fingerprint == "" {
		c.Fingerprint = "chrome"
	}
	if len(maskingSNI) > 0 && maskingSNI[0] != "" {
		c.SNI = maskingSNI[0]
	}

	// Use xray's own log file so the detached process manages its own handles
	xrayLogPath := ""
	if exePath, err := os.Executable(); err == nil {
		xrayLogPath = filepath.Join(filepath.Dir(exePath), "xray_output.log")
	}

	logConfig := map[string]interface{}{
		"loglevel": "info",
	}
	if xrayLogPath != "" {
		logConfig["access"] = xrayLogPath
		logConfig["error"] = xrayLogPath
	}

	config := map[string]interface{}{
		"log": logConfig,
		"api": map[string]interface{}{
			"tag": "api",
			"services": []string{
				"StatsService",
			},
		},
		"inbounds": []map[string]interface{}{
			{
				"tag":      "socks-in",
				"port":     11808,
				"protocol": "socks",
				"settings": map[string]interface{}{
					"udp": true,
				},
				"sniffing": map[string]interface{}{
					"enabled":      true,
					"destOverride": []string{"http", "tls"},
				},
			},
			{
				"tag":      "http-in",
				"port":     11809,
				"protocol": "http",
			},
			{
				"tag":      "api-in",
				"port":     11810,
				"listen":   "127.0.0.1",
				"protocol": "dokodemo-door",
				"settings": map[string]interface{}{
					"address": "127.0.0.1",
				},
			},
		},
		"outbounds": []interface{}{
			c.buildOutbound(),
			map[string]interface{}{
				"tag":      "direct",
				"protocol": "freedom",
			},
			map[string]interface{}{
				"tag":      "block",
				"protocol": "blackhole",
			},
		},
		"routing": map[string]interface{}{
			"domainStrategy": "AsIs",
			"rules": []map[string]interface{}{
				{
					"type":        "field",
					"inboundTag":  []string{"api-in"},
					"outboundTag": "api",
				},
				{
					"type":        "field",
					"outboundTag": "direct",
					"ip":          []string{"10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "127.0.0.0/8"},
				},
			},
		},
		"stats": map[string]interface{}{},
		"policy": map[string]interface{}{
			"system": map[string]interface{}{
				"statsOutboundUplink":   true,
				"statsOutboundDownlink": true,
			},
		},
	}

	return json.MarshalIndent(config, "", "  ")
}

func (c *ServerConfig) buildOutbound() map[string]interface{} {
	outbound := map[string]interface{}{
		"tag":      "proxy",
		"protocol": c.Protocol,
	}

	switch c.Protocol {
	case "vless":
		outbound["settings"] = map[string]interface{}{
			"vnext": []map[string]interface{}{
				{
					"address": c.Address,
					"port":    c.Port,
					"users": []map[string]interface{}{
						{
							"id":         c.UUID,
							"encryption": c.Encryption,
							"flow":       c.Flow,
						},
					},
				},
			},
		}
	case "vmess":
		outbound["settings"] = map[string]interface{}{
			"vnext": []map[string]interface{}{
				{
					"address": c.Address,
					"port":    c.Port,
					"users": []map[string]interface{}{
						{
							"id":       c.UUID,
							"security": "auto",
						},
					},
				},
			},
		}
	case "trojan":
		outbound["settings"] = map[string]interface{}{
			"servers": []map[string]interface{}{
				{
					"address":  c.Address,
					"port":     c.Port,
					"password": c.UUID,
				},
			},
		}
	}

	// Stream settings
	streamSettings := map[string]interface{}{
		"network": c.Network,
	}

	// TLS / Reality settings
	switch c.Security {
	case "reality":
		streamSettings["security"] = "reality"
		realitySettings := map[string]interface{}{
			"fingerprint": c.Fingerprint,
			"serverName":  c.SNI,
			"publicKey":   c.PublicKey,
			"shortId":     c.ShortID,
			"spiderX":     c.SpiderX,
		}
		streamSettings["realitySettings"] = realitySettings
	case "tls":
		streamSettings["security"] = "tls"
		tlsSettings := map[string]interface{}{
			"fingerprint": c.Fingerprint,
			"serverName":  c.SNI,
		}
		if len(c.ALPN) > 0 {
			tlsSettings["alpn"] = c.ALPN
		}
		streamSettings["tlsSettings"] = tlsSettings
	default:
		streamSettings["security"] = "none"
	}

	// Network-specific settings
	switch c.Network {
	case "ws":
		wsSettings := map[string]interface{}{}
		if path, ok := c.Extra["path"]; ok && path != "" {
			wsSettings["path"] = path
		}
		if host, ok := c.Extra["host"]; ok && host != "" {
			wsSettings["headers"] = map[string]interface{}{
				"Host": host,
			}
		}
		streamSettings["wsSettings"] = wsSettings
	case "grpc":
		grpcSettings := map[string]interface{}{}
		if sn, ok := c.Extra["serviceName"]; ok && sn != "" {
			grpcSettings["serviceName"] = sn
		}
		streamSettings["grpcSettings"] = grpcSettings
	}

	outbound["streamSettings"] = streamSettings

	return outbound
}
