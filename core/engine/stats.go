package engine

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	statsService "github.com/xtls/xray-core/app/stats/command"
)

// StatsSnapshot holds a point-in-time view of connection statistics.
type StatsSnapshot struct {
	UploadBytes    int64  `json:"uploadBytes"`
	DownloadBytes  int64  `json:"downloadBytes"`
	UploadSpeed    int64  `json:"uploadSpeed"`    // bytes/sec
	DownloadSpeed  int64  `json:"downloadSpeed"`  // bytes/sec
	PingMs         int32  `json:"pingMs"`
	ConnectedSince int64  `json:"connectedSince"` // unix timestamp
	State          string `json:"state"`
}

// Stats tracks VPN connection statistics in real-time.
type Stats struct {
	uploadBytes   atomic.Int64
	downloadBytes atomic.Int64
	uploadSpeed   atomic.Int64
	downloadSpeed atomic.Int64
	pingMs        atomic.Int32

	mu         sync.Mutex
	running    bool
	stopCh     chan struct{}
	lastUpload int64
	lastDown   int64
	conn       *grpc.ClientConn
}

// NewStats creates a new Stats tracker.
func NewStats() *Stats {
	return &Stats{}
}

// Reset clears all statistics.
func (s *Stats) Reset() {
	s.uploadBytes.Store(0)
	s.downloadBytes.Store(0)
	s.uploadSpeed.Store(0)
	s.downloadSpeed.Store(0)
	s.pingMs.Store(0)
	s.lastUpload = 0
	s.lastDown = 0
}

// Start begins periodic stats polling from xray API.
func (s *Stats) Start() {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.running {
		return
	}

	s.running = true
	s.stopCh = make(chan struct{})

	go s.pollLoop()
}

// Stop halts the stats polling.
func (s *Stats) Stop() {
	s.mu.Lock()
	defer s.mu.Unlock()

	if !s.running {
		return
	}

	s.running = false
	close(s.stopCh)

	if s.conn != nil {
		s.conn.Close()
		s.conn = nil
	}
}

// Snapshot returns the current statistics.
func (s *Stats) Snapshot() StatsSnapshot {
	return StatsSnapshot{
		UploadBytes:   s.uploadBytes.Load(),
		DownloadBytes: s.downloadBytes.Load(),
		UploadSpeed:   s.uploadSpeed.Load(),
		DownloadSpeed: s.downloadSpeed.Load(),
		PingMs:        s.pingMs.Load(),
	}
}

func (s *Stats) connectAPI() error {
	if s.conn != nil {
		return nil
	}
	conn, err := grpc.NewClient("127.0.0.1:11810",
		grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return fmt.Errorf("failed to connect to xray stats API: %w", err)
	}
	s.conn = conn
	return nil
}

func (s *Stats) queryStats(name string, reset bool) int64 {
	if s.conn == nil {
		return 0
	}
	client := statsService.NewStatsServiceClient(s.conn)
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	resp, err := client.GetStats(ctx, &statsService.GetStatsRequest{
		Name:   name,
		Reset_: reset,
	})
	if err != nil {
		return 0
	}
	return resp.GetStat().GetValue()
}

func (s *Stats) pollLoop() {
	// Wait for xray API to become available
	time.Sleep(3 * time.Second)

	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			if err := s.connectAPI(); err != nil {
				continue
			}

			// Query and reset stats (get delta since last query)
			upDelta := s.queryStats("outbound>>>proxy>>>traffic>>>uplink", true)
			downDelta := s.queryStats("outbound>>>proxy>>>traffic>>>downlink", true)

			s.uploadBytes.Add(upDelta)
			s.downloadBytes.Add(downDelta)

			// Speed = delta per second (since we poll every 1s)
			s.uploadSpeed.Store(upDelta)
			s.downloadSpeed.Store(downDelta)

		case <-s.stopCh:
			return
		}
	}
}
