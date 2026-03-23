package engine

import (
	"fmt"
	"testing"
)

func TestTrojanConfig(t *testing.T) {
	cfg, err := ParseURI("trojan://bc2aa2dc-f5f7-40ab-9b52-1cb8cf181be3@150.241.115.143:2083?security=reality&sni=google.com&fp=chrome&pbk=oLFP3Oo5NMwHx3WsH7AmZV-mm6n_Vl-CD9-PrpNPjlI&sid=dcdaf51c8f2425f0&type=tcp#ServcVPN-Trojan")
	if err != nil {
		t.Fatal("Parse error:", err)
	}
	fmt.Printf("Protocol: %s, Security: %s, PBK: %s, SID: %s\n", cfg.Protocol, cfg.Security, cfg.PublicKey, cfg.ShortID)
	data, err := cfg.ToXrayConfig("chrome")
	if err != nil {
		t.Fatal("ToXrayConfig error:", err)
	}
	fmt.Println(string(data))
}

func TestVMessConfig(t *testing.T) {
	// VMess WS no TLS
	cfg, err := ParseURI("vmess://eyJ2IjoiMiIsInBzIjoiU2VydmNWUE4tVk1lc3MiLCJhZGQiOiIxNTAuMjQxLjExNS4xNDMiLCJwb3J0Ijo4NDQzLCJpZCI6ImJjMmFhMmRjLWY1ZjctNDBhYi05YjUyLTFjYjhjZjE4MWJlMyIsImFpZCI6MCwibmV0Ijoid3MiLCJ0eXBlIjoibm9uZSIsImhvc3QiOiIiLCJwYXRoIjoiL3NlcnZjdnBuIiwidGxzIjoiIiwic25pIjoiIiwiZnAiOiIifQ==")
	if err != nil {
		t.Fatal("Parse error:", err)
	}
	fmt.Printf("Protocol: %s, Network: %s, Security: %s\n", cfg.Protocol, cfg.Network, cfg.Security)
	data, err := cfg.ToXrayConfig("chrome")
	if err != nil {
		t.Fatal("ToXrayConfig error:", err)
	}
	fmt.Println(string(data))
}
