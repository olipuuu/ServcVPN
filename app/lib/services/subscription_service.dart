import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/server.dart';
import 'config_import.dart';

class SubscriptionService {
  Timer? _refreshTimer;

  /// Fetch and parse a subscription URL into a list of server configs.
  /// Subscription content can be base64-encoded or plain text, with one URI per line.
  Future<List<ServerInfo>> fetchSubscription(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = response.body.trim();
      return parseSubscriptionContent(body);
    } catch (e) {
      debugPrint('Subscription fetch error: $e');
      rethrow;
    }
  }

  /// Parse subscription content (base64 or plain text) into server list.
  List<ServerInfo> parseSubscriptionContent(String content) {
    String decoded;

    // Try base64 decode first
    try {
      decoded = utf8.decode(base64.decode(content.trim()));
    } catch (_) {
      // Not valid base64, treat as plain text
      decoded = content;
    }

    final lines = decoded
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final servers = <ServerInfo>[];
    for (final line in lines) {
      if (ConfigImport.isValidUri(line)) {
        final server = ConfigImport.parseServerFromUri(line);
        if (server != null) {
          servers.add(server);
        }
      }
    }

    return servers;
  }

  /// Start periodic auto-refresh of a subscription.
  void startAutoRefresh({
    required String url,
    required Duration interval,
    required Future<void> Function(List<ServerInfo> servers) onRefresh,
  }) {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(interval, (_) async {
      try {
        final servers = await fetchSubscription(url);
        await onRefresh(servers);
      } catch (e) {
        debugPrint('Auto-refresh failed: $e');
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void dispose() {
    stopAutoRefresh();
  }
}
