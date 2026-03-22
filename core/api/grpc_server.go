package api

import (
	"context"
	"fmt"
	"net"
	"time"

	"servc_vpn/core/engine"
	"servc_vpn/core/killswitch"
	"servc_vpn/core/leaktest"

	"google.golang.org/grpc"
	pb "servc_vpn/core/api/proto"
)

// VPNServer implements the gRPC VPNService.
type VPNServer struct {
	pb.UnimplementedVPNServiceServer
	engine     *engine.Engine
	killSwitch *killswitch.KillSwitch
	realIP     string
	grpcServer *grpc.Server
}

// NewVPNServer creates a new gRPC VPN server.
func NewVPNServer(eng *engine.Engine, ks *killswitch.KillSwitch) *VPNServer {
	s := &VPNServer{
		engine:     eng,
		killSwitch: ks,
	}
	// Detect real IP at startup (before any VPN connection)
	if ip, err := leaktest.DetectRealIP(); err == nil {
		s.realIP = ip
		fmt.Printf("Real IP detected at startup: %s\n", ip)
	}
	return s
}

// Start starts the gRPC server on the given address.
func (s *VPNServer) Start(addr string) error {
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		return fmt.Errorf("failed to listen on %s: %w", addr, err)
	}

	s.grpcServer = grpc.NewServer()
	pb.RegisterVPNServiceServer(s.grpcServer, s)

	fmt.Printf("gRPC server listening on %s\n", addr)
	return s.grpcServer.Serve(lis)
}

// Stop gracefully stops the gRPC server.
func (s *VPNServer) Stop() {
	if s.grpcServer != nil {
		s.grpcServer.GracefulStop()
	}
}

func (s *VPNServer) Connect(ctx context.Context, req *pb.ConnectRequest) (*pb.ConnectResponse, error) {
	// Detect real IP before connecting (for leak test)
	if s.realIP == "" {
		ip, err := leaktest.DetectRealIP()
		if err == nil {
			s.realIP = ip
		}
	}

	err := s.engine.Connect(req.ConfigUri, req.TlsFingerprint, req.KillSwitch, req.MaskingSni)
	if err != nil {
		return &pb.ConnectResponse{
			Success: false,
			Message: err.Error(),
		}, nil
	}

	// Enable kill switch if requested
	if req.KillSwitch {
		cfg := s.engine.GetConfig()
		if cfg != nil {
			if err := s.killSwitch.Enable(cfg.Address, cfg.Port); err != nil {
				// Kill switch failure shouldn't prevent connection
				fmt.Printf("Warning: kill switch failed: %s\n", err)
			}
		}
	}

	return &pb.ConnectResponse{
		Success:  true,
		Message:  "Connected",
		ServerIp: s.engine.GetConfig().Address,
	}, nil
}

func (s *VPNServer) Disconnect(ctx context.Context, req *pb.DisconnectRequest) (*pb.DisconnectResponse, error) {
	// Disable kill switch
	if s.killSwitch.IsEnabled() {
		_ = s.killSwitch.Disable()
	}

	err := s.engine.Disconnect()
	if err != nil {
		return &pb.DisconnectResponse{
			Success: false,
			Message: err.Error(),
		}, nil
	}

	return &pb.DisconnectResponse{
		Success: true,
		Message: "Disconnected",
	}, nil
}

func (s *VPNServer) GetStats(ctx context.Context, req *pb.StatsRequest) (*pb.StatsResponse, error) {
	stats := s.engine.GetStats()
	return &pb.StatsResponse{
		UploadBytes:    stats.UploadBytes,
		DownloadBytes:  stats.DownloadBytes,
		UploadSpeed:    stats.UploadSpeed,
		DownloadSpeed:  stats.DownloadSpeed,
		PingMs:         stats.PingMs,
		ConnectedSince: stats.ConnectedSince,
		State:          stats.State,
	}, nil
}

func (s *VPNServer) SetTLSProfile(ctx context.Context, req *pb.TLSProfileRequest) (*pb.TLSProfileResponse, error) {
	mgr := s.engine.TLSProfile()
	mgr.SetProfile(req.Profile)

	if req.RotationEnabled {
		mgr.EnableRotation(time.Duration(req.RotationInterval) * time.Second)
	} else {
		mgr.DisableRotation()
	}

	return &pb.TLSProfileResponse{
		Success:       true,
		ActiveProfile: mgr.GetActiveProfileName(),
	}, nil
}

func (s *VPNServer) RunLeakTest(ctx context.Context, req *pb.LeakTestRequest) (*pb.LeakTestResponse, error) {
	serverIP := ""
	if cfg := s.engine.GetConfig(); cfg != nil {
		serverIP = cfg.Address
	}
	result, err := leaktest.RunTest(s.realIP, serverIP)
	if err != nil {
		return nil, fmt.Errorf("leak test failed: %w", err)
	}

	return &pb.LeakTestResponse{
		VisibleIp:  result.VisibleIP,
		RealIp:     result.RealIP,
		IpLeaked:   result.IPLeaked,
		DnsServers: result.DNSServers,
		DnsLeaked:  result.DNSLeaked,
	}, nil
}

func (s *VPNServer) PingServer(ctx context.Context, req *pb.PingRequest) (*pb.PingResponse, error) {
	addr := fmt.Sprintf("%s:%d", req.Address, req.Port)
	start := time.Now()
	conn, err := net.DialTimeout("tcp", addr, 5*time.Second)
	if err != nil {
		return &pb.PingResponse{
			Success: false,
			Error:   err.Error(),
			PingMs:  -1,
		}, nil
	}
	conn.Close()
	pingMs := int32(time.Since(start).Milliseconds())
	return &pb.PingResponse{
		Success: true,
		PingMs:  pingMs,
	}, nil
}

func (s *VPNServer) GetServers(ctx context.Context, req *pb.ServersRequest) (*pb.ServersResponse, error) {
	// TODO: Implement server list from subscription
	return &pb.ServersResponse{
		Servers: []*pb.ServerInfo{},
	}, nil
}

func (s *VPNServer) RefreshSubscription(ctx context.Context, req *pb.SubscriptionRequest) (*pb.SubscriptionResponse, error) {
	// TODO: Implement subscription refresh
	return &pb.SubscriptionResponse{
		Success:      false,
		Message:      "Not implemented yet",
		ServersCount: 0,
	}, nil
}

func (s *VPNServer) OnStatusChange(req *pb.StatusRequest, stream pb.VPNService_OnStatusChangeServer) error {
	// Set up status callback to send events to the stream
	ch := make(chan engine.State, 10)
	s.engine.SetStatusCallback(func(state engine.State, message string) {
		select {
		case ch <- state:
		default:
		}
	})

	// Send initial state
	_ = stream.Send(&pb.StatusEvent{
		State:     string(s.engine.GetState()),
		Message:   "initial",
		Timestamp: time.Now().Unix(),
	})

	for {
		select {
		case state := <-ch:
			if err := stream.Send(&pb.StatusEvent{
				State:     string(state),
				Message:   string(state),
				Timestamp: time.Now().Unix(),
			}); err != nil {
				return err
			}
		case <-stream.Context().Done():
			return nil
		}
	}
}

func (s *VPNServer) StreamStats(req *pb.StatsRequest, stream pb.VPNService_StreamStatsServer) error {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			stats := s.engine.GetStats()
			if err := stream.Send(&pb.StatsResponse{
				UploadBytes:    stats.UploadBytes,
				DownloadBytes:  stats.DownloadBytes,
				UploadSpeed:    stats.UploadSpeed,
				DownloadSpeed:  stats.DownloadSpeed,
				PingMs:         stats.PingMs,
				ConnectedSince: stats.ConnectedSince,
				State:          stats.State,
			}); err != nil {
				return err
			}
		case <-stream.Context().Done():
			return nil
		}
	}
}
