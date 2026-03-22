class ServerInfo {
  final String name;
  final String address;
  final int port;
  final String protocol;
  final int pingMs;
  final String configUri;

  const ServerInfo({
    required this.name,
    required this.address,
    required this.port,
    required this.protocol,
    this.pingMs = 0,
    required this.configUri,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'port': port,
      'protocol': protocol,
      'pingMs': pingMs,
      'configUri': configUri,
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
    );
  }

  ServerInfo copyWith({
    String? name,
    String? address,
    int? port,
    String? protocol,
    int? pingMs,
    String? configUri,
  }) {
    return ServerInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      pingMs: pingMs ?? this.pingMs,
      configUri: configUri ?? this.configUri,
    );
  }
}
