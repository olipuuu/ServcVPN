enum VpnState {
  disconnected,
  connecting,
  connected,
  disconnecting;

  static VpnState fromString(String s) {
    switch (s.toLowerCase()) {
      case 'connected':
        return VpnState.connected;
      case 'connecting':
        return VpnState.connecting;
      case 'disconnecting':
        return VpnState.disconnecting;
      default:
        return VpnState.disconnected;
    }
  }

  String get label {
    switch (this) {
      case VpnState.disconnected:
        return 'Disconnected';
      case VpnState.connecting:
        return 'Connecting...';
      case VpnState.connected:
        return 'Connected';
      case VpnState.disconnecting:
        return 'Disconnecting...';
    }
  }
}
