package engine

import (
	"math/rand"
	"sync"
	"time"
)

// TLSProfile represents a browser TLS fingerprint profile.
type TLSProfile struct {
	Name        string `json:"name"`
	Fingerprint string `json:"fingerprint"` // uTLS identifier used by xray-core
	Description string `json:"description"`
}

// BuiltinProfiles contains all supported browser TLS profiles.
var BuiltinProfiles = []TLSProfile{
	{Name: "Chrome", Fingerprint: "chrome", Description: "Google Chrome (latest)"},
	{Name: "Firefox", Fingerprint: "firefox", Description: "Mozilla Firefox (latest)"},
	{Name: "Safari", Fingerprint: "safari", Description: "Apple Safari (latest)"},
	{Name: "Edge", Fingerprint: "edge", Description: "Microsoft Edge (latest)"},
	{Name: "iOS Safari", Fingerprint: "ios", Description: "iOS Safari"},
	{Name: "Android", Fingerprint: "android", Description: "Android Chrome"},
	{Name: "Random", Fingerprint: "random", Description: "Random browser fingerprint on each connection"},
	{Name: "Randomized", Fingerprint: "randomized", Description: "Randomized ClientHello"},
}

// TLSProfileManager manages TLS fingerprint selection and rotation.
type TLSProfileManager struct {
	mu               sync.RWMutex
	activeProfile    string
	rotationEnabled  bool
	rotationInterval time.Duration
	rotationStop     chan struct{}
	onProfileChange  func(profile string)
}

// NewTLSProfileManager creates a new TLS profile manager with chrome as default.
func NewTLSProfileManager() *TLSProfileManager {
	return &TLSProfileManager{
		activeProfile:    "chrome",
		rotationInterval: 30 * time.Minute,
	}
}

// SetProfile sets the active TLS fingerprint profile.
func (m *TLSProfileManager) SetProfile(fingerprint string) {
	m.mu.Lock()
	defer m.mu.Unlock()

	if fingerprint == "auto" {
		fingerprint = selectBestProfile()
	}

	m.activeProfile = fingerprint
	if m.onProfileChange != nil {
		go m.onProfileChange(fingerprint)
	}
}

// GetActiveFingerprint returns the currently active fingerprint identifier.
func (m *TLSProfileManager) GetActiveFingerprint() string {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.activeProfile == "random" {
		return randomProfile()
	}

	return m.activeProfile
}

// GetActiveProfileName returns the human-readable name of the active profile.
func (m *TLSProfileManager) GetActiveProfileName() string {
	m.mu.RLock()
	fp := m.activeProfile
	m.mu.RUnlock()

	for _, p := range BuiltinProfiles {
		if p.Fingerprint == fp {
			return p.Name
		}
	}
	return fp
}

// EnableRotation starts automatic TLS profile rotation.
func (m *TLSProfileManager) EnableRotation(interval time.Duration) {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.rotationEnabled {
		return
	}

	m.rotationEnabled = true
	m.rotationInterval = interval
	m.rotationStop = make(chan struct{})

	go m.rotationLoop()
}

// DisableRotation stops automatic TLS profile rotation.
func (m *TLSProfileManager) DisableRotation() {
	m.mu.Lock()
	defer m.mu.Unlock()

	if !m.rotationEnabled {
		return
	}

	m.rotationEnabled = false
	close(m.rotationStop)
}

// IsRotationEnabled returns whether rotation is active.
func (m *TLSProfileManager) IsRotationEnabled() bool {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.rotationEnabled
}

// SetOnProfileChange sets a callback for profile changes.
func (m *TLSProfileManager) SetOnProfileChange(cb func(string)) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.onProfileChange = cb
}

// GetAvailableProfiles returns all available TLS profiles.
func (m *TLSProfileManager) GetAvailableProfiles() []TLSProfile {
	return BuiltinProfiles
}

func (m *TLSProfileManager) rotationLoop() {
	ticker := time.NewTicker(m.rotationInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			profile := randomProfile()
			m.mu.Lock()
			m.activeProfile = profile
			cb := m.onProfileChange
			m.mu.Unlock()
			if cb != nil {
				go cb(profile)
			}
		case <-m.rotationStop:
			return
		}
	}
}

func selectBestProfile() string {
	// Auto mode: select Chrome as it's the most common browser
	return "chrome"
}

func randomProfile() string {
	profiles := []string{"chrome", "firefox", "safari", "edge", "ios", "android"}
	return profiles[rand.Intn(len(profiles))]
}
