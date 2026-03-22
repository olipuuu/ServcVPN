import 'dart:convert';
import '../models/server.dart';

class ConfigImport {
  static bool isValidUri(String uri) {
    return uri.startsWith('vless://') ||
        uri.startsWith('trojan://') ||
        uri.startsWith('vmess://');
  }

  static String? getProtocol(String uri) {
    if (uri.startsWith('vless://')) return 'VLESS';
    if (uri.startsWith('trojan://')) return 'Trojan';
    if (uri.startsWith('vmess://')) return 'VMess';
    return null;
  }

  static String? getRemark(String uri) {
    final hashIndex = uri.lastIndexOf('#');
    if (hashIndex == -1) return null;
    return Uri.decodeComponent(uri.substring(hashIndex + 1));
  }

  /// Parse a proxy URI into a ServerInfo object.
  /// Supports vless://, trojan://, and vmess:// formats.
  static ServerInfo? parseServerFromUri(String uri) {
    final protocol = getProtocol(uri);
    if (protocol == null) return null;

    final name = getRemark(uri) ?? 'Server';

    try {
      if (protocol == 'VMess') {
        return _parseVmess(uri, name);
      } else {
        // VLESS and Trojan share a similar URI format
        return _parseVlessTrojan(uri, protocol, name);
      }
    } catch (e) {
      // Fallback: return a minimal server with what we know
      return ServerInfo(
        name: name,
        address: '',
        port: 0,
        protocol: protocol,
        configUri: uri,
      );
    }
  }

  /// Parse vless:// or trojan:// URI.
  /// Format: protocol://uuid@host:port?params#name
  static ServerInfo? _parseVlessTrojan(
      String uri, String protocol, String name) {
    // Strip the fragment (name) first
    String working = uri;
    final hashIndex = working.lastIndexOf('#');
    if (hashIndex != -1) {
      working = working.substring(0, hashIndex);
    }

    // Strip protocol scheme
    final schemeEnd = working.indexOf('://');
    if (schemeEnd == -1) return null;
    working = working.substring(schemeEnd + 3);

    // Split at @ to get user info and host
    final atIndex = working.indexOf('@');
    if (atIndex == -1) return null;
    final hostPart = working.substring(atIndex + 1);

    // Split host and query params
    String hostPort;
    final queryIndex = hostPart.indexOf('?');
    if (queryIndex != -1) {
      hostPort = hostPart.substring(0, queryIndex);
    } else {
      hostPort = hostPart;
    }

    // Parse host:port (handle IPv6 brackets)
    String address;
    int port;
    if (hostPort.startsWith('[')) {
      // IPv6
      final closeBracket = hostPort.indexOf(']');
      address = hostPort.substring(1, closeBracket);
      final colonAfter = hostPort.indexOf(':', closeBracket);
      port = colonAfter != -1
          ? int.tryParse(hostPort.substring(colonAfter + 1)) ?? 443
          : 443;
    } else {
      final parts = hostPort.split(':');
      address = parts[0];
      port = parts.length > 1 ? int.tryParse(parts[1]) ?? 443 : 443;
    }

    return ServerInfo(
      name: name,
      address: address,
      port: port,
      protocol: protocol,
      configUri: uri,
    );
  }

  /// Parse vmess:// URI.
  /// VMess URIs are typically base64-encoded JSON after vmess://
  static ServerInfo? _parseVmess(String uri, String name) {
    final payload = uri.substring('vmess://'.length);

    // Strip fragment if present before decoding
    String base64Part = payload;
    final hashIndex = base64Part.lastIndexOf('#');
    if (hashIndex != -1) {
      base64Part = base64Part.substring(0, hashIndex);
    }

    try {
      final decoded = utf8.decode(base64.decode(base64Part.trim()));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final address = json['add'] as String? ?? '';
      final port = json['port'] is int
          ? json['port'] as int
          : int.tryParse(json['port']?.toString() ?? '') ?? 443;
      final serverName =
          (json['ps'] as String?)?.isNotEmpty == true ? json['ps'] as String : name;

      return ServerInfo(
        name: serverName,
        address: address,
        port: port,
        protocol: 'VMess',
        configUri: uri,
      );
    } catch (_) {
      // Fallback for non-standard vmess URIs
      return ServerInfo(
        name: name,
        address: '',
        port: 0,
        protocol: 'VMess',
        configUri: uri,
      );
    }
  }
}
