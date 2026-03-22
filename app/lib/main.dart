import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/vpn_service.dart';
import 'services/server_storage.dart';

void main() {
  runApp(const ServcVPNApp());
}

class ServcVPNApp extends StatefulWidget {
  const ServcVPNApp({super.key});

  @override
  State<ServcVPNApp> createState() => _ServcVPNAppState();
}

class _ServcVPNAppState extends State<ServcVPNApp> {
  late VpnService _vpnService;
  late ServerStorage _serverStorage;

  @override
  void initState() {
    super.initState();
    _vpnService = VpnService();
    _serverStorage = ServerStorage();

    // Wire quick_connect from QS tile
    _vpnService.onQuickConnect = () async {
      if (_vpnService.isConnected) return;
      final server = _serverStorage.getActiveServer();
      if (server != null) {
        await _vpnService.connect(server.configUri);
      }
    };

    _vpnService.init();
    _serverStorage.loadServers();
  }

  @override
  void dispose() {
    _vpnService.dispose();
    _serverStorage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServcVPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF03DAC6),
          surface: const Color(0xFF1E1E2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: HomeScreen(
        vpnService: _vpnService,
        serverStorage: _serverStorage,
      ),
    );
  }
}
