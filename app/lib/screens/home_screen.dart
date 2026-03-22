import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/vpn_service.dart';
import '../services/server_storage.dart';
import '../services/config_import.dart';
import '../models/vpn_state.dart';
import '../widgets/connect_button.dart';
import '../widgets/stats_panel.dart';
import 'settings_screen.dart';
import 'servers_screen.dart';
import 'leak_test_screen.dart';

class HomeScreen extends StatefulWidget {
  final VpnService vpnService;
  final ServerStorage serverStorage;

  const HomeScreen({
    super.key,
    required this.vpnService,
    required this.serverStorage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.vpnService.addListener(_onServiceUpdate);
    widget.serverStorage.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.vpnService.removeListener(_onServiceUpdate);
    widget.serverStorage.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vpn = widget.vpnService;
    final activeServer = widget.serverStorage.getActiveServer();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ServcVPN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // TLS Fingerprint indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A3E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fingerprint,
                                size: 16, color: Color(0xFF6C63FF)),
                            const SizedBox(width: 6),
                            Text(
                              vpn.fingerprint.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.security, color: Colors.white70),
                        tooltip: 'Leak Test',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LeakTestScreen(vpnService: vpn),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SettingsScreen(vpnService: vpn),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Connection status
              Text(
                vpn.state.label,
                style: TextStyle(
                  fontSize: 18,
                  color: _stateColor(vpn.state),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (vpn.serverIp.isNotEmpty)
                Text(
                  vpn.serverIp,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white38,
                  ),
                ),
              const SizedBox(height: 32),

              // Connect button
              ConnectButton(
                state: vpn.state,
                onPressed: () => _handleToggle(vpn),
              ),

              const SizedBox(height: 32),

              // Error message
              if (vpn.lastError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vpn.lastError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Stats panel (visible when connected)
              if (vpn.isConnected) StatsPanel(stats: vpn.stats),

              const SizedBox(height: 16),

              // Active server info - tap to go to servers screen
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServersScreen(
                        vpnService: vpn,
                        serverStorage: widget.serverStorage,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeServer != null
                              ? const Color(0xFF03DAC6)
                              : Colors.white24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeServer?.name ?? 'No server selected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (activeServer != null)
                              Text(
                                '${activeServer.address}:${activeServer.port} - ${activeServer.protocol}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Clipboard paste button
                      IconButton(
                        icon: const Icon(Icons.content_paste,
                            color: Colors.white38),
                        onPressed: _pasteFromClipboard,
                        tooltip: 'Add server from clipboard',
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white24, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Kill switch toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield, color: Colors.white54, size: 20),
                        SizedBox(width: 8),
                        Text('Kill Switch',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Switch(
                      value: vpn.killSwitchEnabled,
                      onChanged: (v) => vpn.setKillSwitch(v),
                      activeColor: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleToggle(VpnService vpn) {
    if (vpn.isConnected) {
      vpn.disconnect();
    } else {
      final activeServer = widget.serverStorage.getActiveServer();
      if (activeServer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No server selected. Tap the server bar to add one.'),
          ),
        );
        return;
      }
      vpn.connect(activeServer.configUri);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';

    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty')),
        );
      }
      return;
    }

    if (ConfigImport.isValidUri(text)) {
      final server = ConfigImport.parseServerFromUri(text);
      if (server != null) {
        await widget.serverStorage.addServer(server);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${server.name}')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid server URI in clipboard')),
        );
      }
    }
  }

  Color _stateColor(VpnState state) {
    switch (state) {
      case VpnState.connected:
        return const Color(0xFF03DAC6);
      case VpnState.connecting:
      case VpnState.disconnecting:
        return const Color(0xFFFFB74D);
      case VpnState.disconnected:
        return Colors.white54;
    }
  }
}
