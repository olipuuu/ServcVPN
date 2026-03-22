class ConnectionStats {
  final int uploadBytes;
  final int downloadBytes;
  final int uploadSpeed;
  final int downloadSpeed;
  final int pingMs;
  final int connectedSince;

  const ConnectionStats({
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.pingMs = 0,
    this.connectedSince = 0,
  });

  String get uploadFormatted => _formatBytes(uploadBytes);
  String get downloadFormatted => _formatBytes(downloadBytes);
  String get uploadSpeedFormatted => '${_formatBytes(uploadSpeed)}/s';
  String get downloadSpeedFormatted => '${_formatBytes(downloadSpeed)}/s';

  Duration get connectedDuration {
    if (connectedSince == 0) return Duration.zero;
    return DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(connectedSince * 1000),
    );
  }

  String get durationFormatted {
    final d = connectedDuration;
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
