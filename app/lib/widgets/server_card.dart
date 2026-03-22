import 'package:flutter/material.dart';
import '../models/server.dart';

class ServerCard extends StatelessWidget {
  final ServerInfo server;
  final bool isSelected;
  final VoidCallback onTap;

  const ServerCard({
    super.key,
    required this.server,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withAlpha(25)
              : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF6C63FF), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Protocol badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _protocolColor(server.protocol).withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                server.protocol.toUpperCase(),
                style: TextStyle(
                  color: _protocolColor(server.protocol),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Server info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${server.address}:${server.port}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Ping
            if (server.pingMs > 0)
              Text(
                '${server.pingMs}ms',
                style: TextStyle(
                  color: _pingColor(server.pingMs),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _protocolColor(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'vless':
        return const Color(0xFF6C63FF);
      case 'trojan':
        return const Color(0xFF03DAC6);
      case 'vmess':
        return const Color(0xFFFFB74D);
      default:
        return Colors.white54;
    }
  }

  Color _pingColor(int ms) {
    if (ms < 100) return const Color(0xFF03DAC6);
    if (ms < 200) return const Color(0xFFFFB74D);
    return Colors.red;
  }
}
