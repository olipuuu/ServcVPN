import 'package:flutter/material.dart';
import '../services/vpn_service.dart';
import '../generated/vpn_service.pbgrpc.dart';

class LeakTestScreen extends StatefulWidget {
  final VpnService vpnService;

  const LeakTestScreen({super.key, required this.vpnService});

  @override
  State<LeakTestScreen> createState() => _LeakTestScreenState();
}

class _LeakTestScreenState extends State<LeakTestScreen>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  LeakTestResponse? _result;
  String? _error;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    if (!widget.vpnService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect to VPN first'),
          backgroundColor: Color(0xFF2A2A3E),
        ),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await widget.vpnService.runLeakTest();
      if (mounted) {
        setState(() {
          _result = response;
          _isRunning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leak Test'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status indicator
            if (!widget.vpnService.isConnected) ...[
              const Spacer(),
              _buildNotConnectedView(),
              const Spacer(),
            ] else if (_isRunning) ...[
              const Spacer(),
              _buildLoadingView(),
              const Spacer(),
            ] else if (_result != null) ...[
              Expanded(child: _buildResultsView(_result!)),
            ] else if (_error != null) ...[
              const Spacer(),
              _buildErrorView(),
              const Spacer(),
            ] else ...[
              const Spacer(),
              _buildIdleView(),
              const Spacer(),
            ],

            const SizedBox(height: 20),

            // Run Test button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isRunning ? null : _runTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  disabledBackgroundColor: const Color(0xFF2A2A3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isRunning
                      ? 'Testing...'
                      : _result != null
                          ? 'Run Again'
                          : 'Run Test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotConnectedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.vpn_lock,
            size: 40,
            color: Color(0xFFFFB74D),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Connect to VPN First',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You need an active VPN connection\nto run a leak test.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF)
                    .withAlpha((40 + 40 * _pulseController.value).toInt()),
              ),
              child: const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Running Leak Test...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Checking IP and DNS for leaks',
          style: TextStyle(fontSize: 14, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildIdleView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.security,
            size: 40,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Test Your Connection',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check if your IP or DNS is leaking\noutside the VPN tunnel.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Test Failed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(LeakTestResponse result) {
    final ipSafe = !result.ipLeaked;
    final dnsSafe = !result.dnsLeaked;
    final allSafe = ipSafe && dnsSafe;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Overall status
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (allSafe ? const Color(0xFF03DAC6) : Colors.red)
                  .withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allSafe ? Icons.check_circle : Icons.warning,
              size: 44,
              color: allSafe ? const Color(0xFF03DAC6) : Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            allSafe ? 'No Leaks Detected' : 'Leak Detected!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: allSafe ? const Color(0xFF03DAC6) : Colors.red,
            ),
          ),

          const SizedBox(height: 24),

          // IP Leak status
          _buildStatusCard(
            icon: ipSafe ? Icons.check_circle : Icons.cancel,
            iconColor: ipSafe ? const Color(0xFF03DAC6) : Colors.red,
            title: 'IP Leak Test',
            status: ipSafe ? 'PASSED' : 'FAILED',
            statusColor: ipSafe ? const Color(0xFF03DAC6) : Colors.red,
          ),

          const SizedBox(height: 10),

          // Visible IP
          _buildInfoCard(
            label: 'Visible IP (through VPN)',
            value: result.visibleIp.isNotEmpty
                ? result.visibleIp
                : 'Unknown',
            icon: Icons.public,
          ),

          const SizedBox(height: 10),

          // Real IP
          _buildInfoCard(
            label: 'Your Real IP',
            value:
                result.realIp.isNotEmpty ? result.realIp : 'Unknown',
            icon: Icons.home,
          ),

          const SizedBox(height: 16),

          // DNS Leak status
          _buildStatusCard(
            icon: dnsSafe ? Icons.check_circle : Icons.cancel,
            iconColor: dnsSafe ? const Color(0xFF03DAC6) : Colors.red,
            title: 'DNS Leak Test',
            status: dnsSafe ? 'PASSED' : 'FAILED',
            statusColor: dnsSafe ? const Color(0xFF03DAC6) : Colors.red,
          ),

          const SizedBox(height: 10),

          // DNS Servers
          _buildDnsCard(result.dnsServers),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Consolas',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDnsCard(List<String> dnsServers) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dns, color: Color(0xFF6C63FF), size: 22),
              const SizedBox(width: 12),
              const Text(
                'DNS Servers Detected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${dnsServers.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
          if (dnsServers.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...dnsServers.map(
              (server) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  server,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Consolas',
                  ),
                ),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'No DNS servers detected',
                style: TextStyle(fontSize: 13, color: Colors.white24),
              ),
            ),
        ],
      ),
    );
  }
}
