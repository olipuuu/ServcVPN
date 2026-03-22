import 'package:flutter/material.dart';
import '../models/connection_stats.dart';

class StatsPanel extends StatelessWidget {
  final ConnectionStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Duration
          Text(
            stats.durationFormatted,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),

          // Upload / Download
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_upward,
                  color: const Color(0xFF6C63FF),
                  label: 'Upload',
                  value: stats.uploadFormatted,
                  speed: stats.uploadSpeedFormatted,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white12,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF03DAC6),
                  label: 'Download',
                  value: stats.downloadFormatted,
                  speed: stats.downloadSpeedFormatted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ping
          if (stats.pingMs > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, size: 16, color: Colors.white38),
                const SizedBox(width: 6),
                Text(
                  '${stats.pingMs} ms',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String speed;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          speed,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}
