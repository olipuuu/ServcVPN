import 'package:flutter/material.dart';
import '../services/vpn_service.dart';

class SettingsScreen extends StatefulWidget {
  final VpnService vpnService;

  const SettingsScreen({super.key, required this.vpnService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.vpnService.addListener(_update);
  }

  @override
  void dispose() {
    widget.vpnService.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vpn = widget.vpnService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TLS Fingerprint section
          const _SectionHeader(title: 'TLS Fingerprint'),
          const SizedBox(height: 8),
          ..._buildFingerprintOptions(vpn),

          const SizedBox(height: 24),

          // Traffic Masking section
          const _SectionHeader(title: 'Traffic Masking'),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Disguise VPN traffic as visits to popular services',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          ..._buildMaskingOptions(vpn),

          const SizedBox(height: 24),

          // Connection section
          const _SectionHeader(title: 'Connection'),
          const SizedBox(height: 8),
          _buildToggleTile(
            icon: Icons.shield,
            title: 'Kill Switch',
            subtitle: 'Block all traffic if VPN disconnects',
            value: vpn.killSwitchEnabled,
            onChanged: (v) => vpn.setKillSwitch(v),
          ),

          const SizedBox(height: 24),

          // About section
          const _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0 MVP',
          ),
          _buildInfoTile(
            icon: Icons.code,
            title: 'Core Engine',
            subtitle: 'xray-core + uTLS',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFingerprintOptions(VpnService vpn) {
    final profiles = [
      ('chrome', 'Chrome', 'Google Chrome (most common)'),
      ('firefox', 'Firefox', 'Mozilla Firefox'),
      ('safari', 'Safari', 'Apple Safari'),
      ('edge', 'Edge', 'Microsoft Edge'),
      ('ios', 'iOS Safari', 'iOS Safari mobile'),
      ('android', 'Android', 'Android Chrome mobile'),
      ('random', 'Random', 'Random profile each connection'),
      ('randomized', 'Randomized', 'Fully randomized ClientHello'),
      ('auto', 'Auto', 'Automatically select best profile'),
    ];

    final widgets = <Widget>[];

    for (final p in profiles) {
      final (id, name, desc) = p;
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: RadioListTile<String>(
          title: Text(name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(desc,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          value: id,
          groupValue: vpn.fingerprint,
          activeColor: const Color(0xFF6C63FF),
          onChanged: (v) {
            if (v != null) vpn.setFingerprint(v);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: const Color(0xFF1E1E2E),
        ),
      ));
    }

    // Rotation controls
    widgets.add(const SizedBox(height: 16));
    widgets.add(const _SectionHeader(title: 'Auto-Rotation'));
    widgets.add(const SizedBox(height: 8));
    widgets.add(Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.autorenew, color: Color(0xFF6C63FF)),
        title: const Text('Auto-rotate fingerprint',
            style: TextStyle(color: Colors.white)),
        subtitle: Text(
            'Change profile every ${vpn.rotationIntervalMin} min',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        value: vpn.rotationEnabled,
        onChanged: (v) => vpn.setRotation(v),
        activeColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ));

    if (vpn.rotationEnabled) {
      widgets.add(const SizedBox(height: 8));
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer, color: Color(0xFF6C63FF), size: 20),
            const SizedBox(width: 12),
            const Text('Interval',
                style: TextStyle(color: Colors.white)),
            const Spacer(),
            ...[ 10, 15, 30, 60 ].map((min) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ChoiceChip(
                label: Text('${min}m',
                    style: TextStyle(
                      color: vpn.rotationIntervalMin == min
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 12,
                    )),
                selected: vpn.rotationIntervalMin == min,
                selectedColor: const Color(0xFF6C63FF),
                backgroundColor: const Color(0xFF2A2A3E),
                onSelected: (_) =>
                    vpn.setRotation(true, intervalMin: min),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            )),
          ],
        ),
      ));
    }

    return widgets;
  }

  List<Widget> _buildMaskingOptions(VpnService vpn) {
    final presets = [
      ('', 'Off', 'Use original SNI from server config', Icons.public_off),
      ('vk.com', 'VK', 'Mask as vk.com traffic', Icons.people),
      ('ok.ru', 'OK', 'Mask as ok.ru traffic', Icons.emoji_people),
      ('mail.ru', 'Mail.ru', 'Mask as mail.ru traffic', Icons.mail),
      ('dzen.ru', 'Dzen', 'Mask as dzen.ru traffic', Icons.article),
      ('mts.ru', 'MTS', 'Mask as mts.ru traffic', Icons.cell_tower),
    ];

    return presets.map((p) {
      final (sni, name, desc, icon) = p;
      final isSelected = vpn.maskingSni == sni;
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          leading: Icon(icon,
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : Colors.white38),
          title: Text(name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
          subtitle: Text(desc,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Color(0xFF6C63FF))
              : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          tileColor: isSelected
              ? const Color(0xFF6C63FF).withAlpha(25)
              : const Color(0xFF1E1E2E),
          onTap: () => vpn.setMaskingSni(sni),
        ),
      );
    }).toList();
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFF6C63FF)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6C63FF)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }
}
