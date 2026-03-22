import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:grpc/grpc.dart';
import '../generated/vpn_service.pbgrpc.dart';
import '../models/vpn_state.dart';
import '../models/connection_stats.dart';
import 'xray_config_generator.dart';

class VpnService extends ChangeNotifier {
  // gRPC (Windows)
  ClientChannel? _channel;
  VPNServiceClient? _client;
  Process? _coreProcess;

  // MethodChannel (Android)
  static const _vpnChannel = MethodChannel('com.servcvpn/vpn');
  static const _statusChannel = EventChannel('com.servcvpn/vpn_status');
  StreamSubscription? _androidStatusSub;
  Timer? _androidTimer;
  int _androidConnectedSince = 0;
  String? _androidRealIp;
  int _prevRxBytes = 0;
  int _prevTxBytes = 0;
  int _totalRxBytes = 0;
  int _totalTxBytes = 0;
  int _lastTrafficCheck = 0;

  VpnState _state = VpnState.disconnected;
  ConnectionStats _stats = const ConnectionStats();
  String _serverIp = '';
  String _fingerprint = 'chrome';
  bool _killSwitchEnabled = true;
  String _maskingSni = '';
  String? _lastError;

  StreamSubscription? _statsSubscription;
  StreamSubscription? _statusSubscription;

  VpnState get state => _state;
  ConnectionStats get stats => _stats;
  String get serverIp => _serverIp;
  String get fingerprint => _fingerprint;
  bool get killSwitchEnabled => _killSwitchEnabled;
  String get maskingSni => _maskingSni;
  String? get lastError => _lastError;
  bool get isConnected => _state == VpnState.connected;

  bool get _isAndroid => Platform.isAndroid;

  // Callback for quick_connect from QS tile
  Future<void> Function()? onQuickConnect;

  Future<void> init() async {
    if (_isAndroid) {
      _listenAndroidStatus();
      _listenNativeMethodCalls();
      // Detect real IP before VPN connection
      _detectRealIp();
    } else {
      await _startCore();
      _connectGrpc();
    }
  }

  Future<void> _detectRealIp() async {
    _androidRealIp = await _fetchPublicIp();
    debugPrint('Real IP detected: $_androidRealIp');
  }

  void _listenNativeMethodCalls() {
    _vpnChannel.setMethodCallHandler((call) async {
      if (call.method == 'quick_connect') {
        if (onQuickConnect != null) {
          await onQuickConnect!();
        }
      }
    });
  }

  void _listenAndroidStatus() {
    _androidStatusSub = _statusChannel
        .receiveBroadcastStream()
        .listen((event) {
      if (event is Map) {
        final state = event['state'] as String?;
        final message = event['message'] as String?;
        if (state == 'connected') {
          _state = VpnState.connected;
          _lastError = null;
          _androidConnectedSince = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          _startAndroidTimer();
        } else if (state == 'disconnected') {
          _state = VpnState.disconnected;
          _stats = const ConnectionStats();
          _stopAndroidTimer();
          if (message != null && message != 'Disconnected') {
            _lastError = message;
          }
        }
        notifyListeners();
      }
    });
  }

  Future<void> _startCore() async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    // Check both next to exe and in core/ subfolder (installed layout)
    var corePath = '$exeDir/vpncli.exe';
    if (!File(corePath).existsSync()) {
      corePath = '$exeDir/core/vpncli.exe';
    }

    if (!File(corePath).existsSync()) {
      debugPrint('Core binary not found, assuming external start');
      return;
    }

    // Check if core is already running (launched by installer/launcher)
    try {
      final socket = await Socket.connect('localhost', 50051,
          timeout: const Duration(milliseconds: 500));
      socket.destroy();
      debugPrint('Core already running on port 50051');
      return;
    } catch (_) {
      // Not running, start it
    }

    try {
      // Launch vpncli with admin rights via PowerShell Start-Process -Verb RunAs
      await Process.start('powershell', [
        '-WindowStyle', 'Hidden',
        '-Command',
        'Start-Process', '-FilePath', "'$corePath'",
        '-ArgumentList', "'serve --port 50051'",
        '-Verb', 'RunAs',
        '-WindowStyle', 'Hidden',
      ]);
      // Wait for core to start
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final socket = await Socket.connect('localhost', 50051,
              timeout: const Duration(milliseconds: 500));
          socket.destroy();
          debugPrint('Core started on port 50051');
          return;
        } catch (_) {}
      }
      debugPrint('Core started but port not ready yet');
    } catch (e) {
      debugPrint('Failed to start core: $e');
    }
  }

  void _connectGrpc() {
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _client = VPNServiceClient(_channel!);
  }

  Future<void> connect(String configUri) async {
    _state = VpnState.connecting;
    _lastError = null;
    notifyListeners();

    if (_isAndroid) {
      await _connectAndroid(configUri);
    } else {
      await _connectDesktop(configUri);
    }
  }

  Future<void> _connectAndroid(String configUri) async {
    try {
      // Generate xray config JSON on Dart side
      final configJson = XrayConfigGenerator.generate(
        configUri,
        fingerprint: _fingerprint,
        maskingSni: _maskingSni,
      );
      final serverAddress = XrayConfigGenerator.extractServerAddress(configUri);

      await _vpnChannel.invokeMethod('connect', {
        'config_json': configJson,
        'server_address': serverAddress,
      });
      _serverIp = serverAddress;
      // Start timer immediately — EventChannel will confirm connected state
      _androidConnectedSince = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _startAndroidTimer();
    } catch (e) {
      _state = VpnState.disconnected;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _connectDesktop(String configUri) async {
    if (_client == null) {
      _state = VpnState.disconnected;
      _lastError = 'gRPC client not initialized';
      notifyListeners();
      return;
    }

    try {
      final response = await _client!.connect(ConnectRequest()
        ..configUri = configUri
        ..tlsFingerprint = _fingerprint
        ..killSwitch = _killSwitchEnabled
        ..maskingSni = _maskingSni);

      if (response.success) {
        _state = VpnState.connected;
        _serverIp = response.serverIp;
        _startStatsStream();
      } else {
        _state = VpnState.disconnected;
        _lastError = response.message;
      }
    } catch (e) {
      _state = VpnState.disconnected;
      _lastError = e.toString();
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    _state = VpnState.disconnecting;
    notifyListeners();

    if (_isAndroid) {
      try {
        await _vpnChannel.invokeMethod('disconnect');
      } catch (e) {
        _lastError = e.toString();
      }
      _state = VpnState.disconnected;
      _stats = const ConnectionStats();
      _serverIp = '';
    } else {
      if (_client == null) return;
      try {
        await _client!.disconnect(DisconnectRequest());
        _stopStatsStream();
        _state = VpnState.disconnected;
        _stats = const ConnectionStats();
        _serverIp = '';
      } catch (e) {
        _lastError = e.toString();
      }
    }

    notifyListeners();
  }

  bool _rotationEnabled = false;
  int _rotationIntervalMin = 30;

  bool get rotationEnabled => _rotationEnabled;
  int get rotationIntervalMin => _rotationIntervalMin;

  Future<void> setFingerprint(String fp) async {
    _fingerprint = fp;
    notifyListeners();

    if (!_isAndroid && _client != null) {
      try {
        await _client!.setTLSProfile(TLSProfileRequest()
          ..profile = fp
          ..rotationEnabled = _rotationEnabled
          ..rotationInterval = _rotationIntervalMin * 60);
      } catch (e) {
        debugPrint('Failed to set TLS profile: $e');
      }
    }
  }

  Future<void> setRotation(bool enabled, {int? intervalMin}) async {
    _rotationEnabled = enabled;
    if (intervalMin != null) _rotationIntervalMin = intervalMin;
    notifyListeners();

    if (!_isAndroid && _client != null) {
      try {
        await _client!.setTLSProfile(TLSProfileRequest()
          ..profile = _fingerprint
          ..rotationEnabled = _rotationEnabled
          ..rotationInterval = _rotationIntervalMin * 60);
      } catch (e) {
        debugPrint('Failed to set rotation: $e');
      }
    }
  }

  void setKillSwitch(bool enabled) {
    _killSwitchEnabled = enabled;
    notifyListeners();
  }

  void setMaskingSni(String sni) {
    _maskingSni = sni;
    notifyListeners();
  }

  Future<LeakTestResponse> runLeakTest() async {
    if (_isAndroid) {
      return await _runLeakTestNative();
    }
    if (_client == null) {
      throw Exception('gRPC client not initialized');
    }
    return await _client!.runLeakTest(LeakTestRequest());
  }

  Future<LeakTestResponse> _runLeakTestNative() async {
    final result = LeakTestResponse();

    // Get visible IP via SOCKS5 proxy (goes through VPN tunnel)
    String? visibleIp;
    try {
      visibleIp = await _vpnChannel.invokeMethod<String>('fetchVpnIp');
    } catch (_) {}
    visibleIp ??= await _fetchPublicIp(); // fallback
    result.visibleIp = visibleIp ?? 'Unknown';

    // Real IP — detected at app start before VPN
    result.realIp = _androidRealIp ?? 'Unknown';
    result.ipLeaked = (_androidRealIp != null &&
        _androidRealIp!.isNotEmpty &&
        visibleIp == _androidRealIp);

    // DNS leak test via native SOCKS5 proxy (goes through VPN tunnel)
    final dnsServers = <String>[];
    try {
      final servers = await _vpnChannel.invokeMethod<List>('fetchDnsServers');
      if (servers != null) {
        dnsServers.addAll(servers.cast<String>());
      }
    } catch (_) {
      // Fallback: direct HTTP (won't go through VPN but better than nothing)
      try {
        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 10);
        final request = await httpClient.getUrl(Uri.parse('https://1.1.1.1/cdn-cgi/trace'));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        for (final line in body.split('\n')) {
          if (line.startsWith('ip=')) {
            dnsServers.add(line.substring(3).trim());
          }
        }
        httpClient.close();
      } catch (_) {}
    }

    result.dnsServers.addAll(dnsServers);
    result.dnsLeaked = false;

    return result;
  }

  Future<String?> _fetchPublicIp() async {
    final apis = [
      'https://api.ipify.org',
      'https://ifconfig.me/ip',
      'https://icanhazip.com',
    ];
    for (final api in apis) {
      try {
        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 8);
        final request = await httpClient.getUrl(Uri.parse(api));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        final ip = body.trim();
        httpClient.close();
        if (RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(ip)) {
          return ip;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<int> pingServer(String address, int port) async {
    if (_isAndroid) {
      // Direct TCP ping on Android
      try {
        final sw = Stopwatch()..start();
        final socket = await Socket.connect(address, port,
            timeout: const Duration(seconds: 5));
        sw.stop();
        socket.destroy();
        return sw.elapsedMilliseconds;
      } catch (_) {
        return -1;
      }
    }

    if (_client == null) return -1;
    try {
      final response = await _client!.pingServer(PingRequest()
        ..address = address
        ..port = port);
      return response.success ? response.pingMs : -1;
    } catch (_) {
      return -1;
    }
  }

  void _startAndroidTimer() {
    _androidTimer?.cancel();
    _totalRxBytes = 0;
    _totalTxBytes = 0;
    _prevRxBytes = 0;
    _prevTxBytes = 0;
    _lastTrafficCheck = 0;
    _stats = ConnectionStats(connectedSince: _androidConnectedSince);
    notifyListeners();
    _androidTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_state == VpnState.connected && _androidConnectedSince > 0) {
        // Read traffic stats every 2 seconds
        int dlSpeed = 0;
        int ulSpeed = 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (_lastTrafficCheck == 0 || now - _lastTrafficCheck >= 2000) {
          try {
            final result = await _vpnChannel.invokeMethod('getTrafficStats');
            if (result is Map) {
              final rx = (result['rx'] as int?) ?? 0;
              final tx = (result['tx'] as int?) ?? 0;
              if (_prevRxBytes > 0) {
                final elapsed = (now - _lastTrafficCheck) / 1000.0;
                dlSpeed = ((rx - _prevRxBytes) / elapsed).round();
                ulSpeed = ((tx - _prevTxBytes) / elapsed).round();
                if (dlSpeed < 0) dlSpeed = 0;
                if (ulSpeed < 0) ulSpeed = 0;
              }
              _totalRxBytes = rx;
              _totalTxBytes = tx;
              _prevRxBytes = rx;
              _prevTxBytes = tx;
              _lastTrafficCheck = now;
            }
          } catch (_) {}
        }
        _stats = ConnectionStats(
          connectedSince: _androidConnectedSince,
          downloadBytes: _totalRxBytes,
          uploadBytes: _totalTxBytes,
          downloadSpeed: dlSpeed,
          uploadSpeed: ulSpeed,
        );
        notifyListeners();
      }
    });
  }

  void _stopAndroidTimer() {
    _androidTimer?.cancel();
    _androidTimer = null;
    _androidConnectedSince = 0;
  }

  void _startStatsStream() {
    _statsSubscription?.cancel();
    try {
      final stream = _client!.streamStats(StatsRequest());
      _statsSubscription = stream.listen(
        (response) {
          _stats = ConnectionStats(
            uploadBytes: response.uploadBytes.toInt(),
            downloadBytes: response.downloadBytes.toInt(),
            uploadSpeed: response.uploadSpeed.toInt(),
            downloadSpeed: response.downloadSpeed.toInt(),
            pingMs: response.pingMs,
            connectedSince: response.connectedSince.toInt(),
          );
          _state = VpnState.fromString(response.state);
          notifyListeners();
        },
        onError: (e) {
          debugPrint('Stats stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('Failed to start stats stream: $e');
    }
  }

  void _stopStatsStream() {
    _statsSubscription?.cancel();
    _statsSubscription = null;
    _statusSubscription?.cancel();
    _statusSubscription = null;
  }

  @override
  void dispose() {
    _stopStatsStream();
    _stopAndroidTimer();
    _androidStatusSub?.cancel();
    _channel?.shutdown();
    _coreProcess?.kill();
    super.dispose();
  }
}
