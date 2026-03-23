class ServerInfo {
  final String name;
  final String address;
  final int port;
  final String protocol;
  final int pingMs;
  final String configUri;
  final List<String> fallbackUris; // alternative protocol URIs for same server

  const ServerInfo({
    required this.name,
    required this.address,
    required this.port,
    required this.protocol,
    this.pingMs = 0,
    required this.configUri,
    this.fallbackUris = const [],
  });

  /// All URIs: primary + fallbacks
  List<String> get allUris => [configUri, ...fallbackUris];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'port': port,
      'protocol': protocol,
      'pingMs': pingMs,
      'configUri': configUri,
      'fallbackUris': fallbackUris,
    };
  }

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      name: json['name'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? '',
      port: json['port'] as int? ?? 0,
      protocol: json['protocol'] as String? ?? '',
      pingMs: json['pingMs'] as int? ?? 0,
      configUri: json['configUri'] as String? ?? '',
      fallbackUris: (json['fallbackUris'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  ServerInfo copyWith({
    String? name,
    String? address,
    int? port,
    String? protocol,
    int? pingMs,
    String? configUri,
    List<String>? fallbackUris,
  }) {
    return ServerInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      pingMs: pingMs ?? this.pingMs,
      configUri: configUri ?? this.configUri,
      fallbackUris: fallbackUris ?? this.fallbackUris,
    );
  }
}
