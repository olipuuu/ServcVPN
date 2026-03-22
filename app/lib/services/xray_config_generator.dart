import 'dart:convert';

class XrayConfigGenerator {
  /// Generate xray-core JSON config from a protocol URI.
  static String generate(String uri, {String fingerprint = 'chrome', String maskingSni = ''}) {
    final parsed = _parseUri(uri);
    if (maskingSni.isNotEmpty) {
      parsed['sni'] = maskingSni;
    }
    if (fingerprint.isNotEmpty) {
      parsed['fingerprint'] = fingerprint;
    }

    final config = {
      'log': {'loglevel': 'info'},
      'inbounds': [
        {
          'tag': 'socks-in',
          'port': 11808,
          'protocol': 'socks',
          'settings': {'udp': true},
          'sniffing': {
            'enabled': true,
            'destOverride': ['http', 'tls'],
          },
        },
      ],
      'outbounds': [
        _buildOutbound(parsed),
        {'tag': 'direct', 'protocol': 'freedom'},
        {'tag': 'block', 'protocol': 'blackhole'},
      ],
      'routing': {
        'domainStrategy': 'AsIs',
        'rules': [
          {
            'type': 'field',
            'outboundTag': 'direct',
            'ip': ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', '127.0.0.0/8'],
          },
        ],
      },
    };

    return jsonEncode(config);
  }

  /// Extract server address from URI.
  static String extractServerAddress(String uri) {
    try {
      if (uri.startsWith('vmess://')) {
        final raw = uri.substring(8);
        final decoded = utf8.decode(base64Decode(_padBase64(raw)));
        final json = jsonDecode(decoded) as Map;
        return json['add'] as String? ?? '';
      }
      final parsed = Uri.parse(uri);
      return parsed.host;
    } catch (_) {
      return '';
    }
  }

  static Map<String, dynamic> _parseUri(String uri) {
    if (uri.startsWith('vless://')) return _parseVless(uri);
    if (uri.startsWith('trojan://')) return _parseTrojan(uri);
    if (uri.startsWith('vmess://')) return _parseVmess(uri);
    throw Exception('Unsupported protocol: $uri');
  }

  static Map<String, dynamic> _parseVless(String uri) {
    final parsed = Uri.parse(uri);
    final params = parsed.queryParameters;
    return {
      'protocol': 'vless',
      'uuid': parsed.userInfo,
      'address': parsed.host,
      'port': parsed.port,
      'encryption': params['encryption'] ?? 'none',
      'flow': params['flow'] ?? '',
      'security': params['security'] ?? 'none',
      'sni': params['sni'] ?? '',
      'fingerprint': params['fp'] ?? 'chrome',
      'publicKey': params['pbk'] ?? '',
      'shortId': params['sid'] ?? '',
      'spiderX': params['spx'] ?? '',
      'network': params['type'] ?? 'tcp',
      'alpn': params['alpn'] ?? '',
    };
  }

  static Map<String, dynamic> _parseTrojan(String uri) {
    final parsed = Uri.parse(uri);
    final params = parsed.queryParameters;
    return {
      'protocol': 'trojan',
      'uuid': parsed.userInfo,
      'address': parsed.host,
      'port': parsed.port,
      'security': params['security'] ?? 'tls',
      'sni': params['sni'] ?? '',
      'fingerprint': params['fp'] ?? 'chrome',
      'network': params['type'] ?? 'tcp',
      'alpn': params['alpn'] ?? '',
    };
  }

  static Map<String, dynamic> _parseVmess(String uri) {
    final raw = uri.substring(8);
    final decoded = utf8.decode(base64Decode(_padBase64(raw)));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    return {
      'protocol': 'vmess',
      'uuid': json['id'] ?? '',
      'address': json['add'] ?? '',
      'port': int.tryParse('${json['port']}') ?? 0,
      'network': json['net'] ?? 'tcp',
      'security': json['tls'] ?? '',
      'sni': json['sni'] ?? '',
      'fingerprint': json['fp'] ?? 'chrome',
      'host': json['host'] ?? '',
      'path': json['path'] ?? '',
      'alpn': json['alpn'] ?? '',
    };
  }

  static Map<String, dynamic> _buildOutbound(Map<String, dynamic> cfg) {
    final protocol = cfg['protocol'] as String;
    final outbound = <String, dynamic>{
      'tag': 'proxy',
      'protocol': protocol,
    };

    switch (protocol) {
      case 'vless':
        outbound['settings'] = {
          'vnext': [
            {
              'address': cfg['address'],
              'port': cfg['port'],
              'users': [
                {
                  'id': cfg['uuid'],
                  'encryption': cfg['encryption'] ?? 'none',
                  'flow': cfg['flow'] ?? '',
                },
              ],
            },
          ],
        };
        break;
      case 'vmess':
        outbound['settings'] = {
          'vnext': [
            {
              'address': cfg['address'],
              'port': cfg['port'],
              'users': [
                {
                  'id': cfg['uuid'],
                  'security': 'auto',
                },
              ],
            },
          ],
        };
        break;
      case 'trojan':
        outbound['settings'] = {
          'servers': [
            {
              'address': cfg['address'],
              'port': cfg['port'],
              'password': cfg['uuid'],
            },
          ],
        };
        break;
    }

    // Stream settings
    final streamSettings = <String, dynamic>{
      'network': cfg['network'] ?? 'tcp',
    };

    final security = cfg['security'] as String? ?? 'none';
    switch (security) {
      case 'reality':
        streamSettings['security'] = 'reality';
        streamSettings['realitySettings'] = {
          'fingerprint': cfg['fingerprint'] ?? 'chrome',
          'serverName': cfg['sni'] ?? '',
          'publicKey': cfg['publicKey'] ?? '',
          'shortId': cfg['shortId'] ?? '',
          'spiderX': cfg['spiderX'] ?? '',
        };
        break;
      case 'tls':
        streamSettings['security'] = 'tls';
        final tlsSettings = <String, dynamic>{
          'fingerprint': cfg['fingerprint'] ?? 'chrome',
          'serverName': cfg['sni'] ?? '',
        };
        final alpn = cfg['alpn'] as String? ?? '';
        if (alpn.isNotEmpty) {
          tlsSettings['alpn'] = alpn.split(',');
        }
        streamSettings['tlsSettings'] = tlsSettings;
        break;
      default:
        streamSettings['security'] = 'none';
    }

    // Network settings
    final network = cfg['network'] as String? ?? 'tcp';
    if (network == 'ws') {
      final wsSettings = <String, dynamic>{};
      if ((cfg['path'] as String?)?.isNotEmpty == true) {
        wsSettings['path'] = cfg['path'];
      }
      if ((cfg['host'] as String?)?.isNotEmpty == true) {
        wsSettings['headers'] = {'Host': cfg['host']};
      }
      streamSettings['wsSettings'] = wsSettings;
    }

    outbound['streamSettings'] = streamSettings;
    return outbound;
  }

  static String _padBase64(String input) {
    var s = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (s.length % 4) {
      case 2:
        s += '==';
        break;
      case 3:
        s += '=';
        break;
    }
    return s;
  }
}
