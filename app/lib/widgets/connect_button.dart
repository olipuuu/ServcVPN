import 'package:flutter/material.dart';
import '../models/vpn_state.dart';

class ConnectButton extends StatelessWidget {
  final VpnState state;
  final VoidCallback onPressed;

  const ConnectButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading =
        state == VpnState.connecting || state == VpnState.disconnecting;
    final isConnected = state == VpnState.connected;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isConnected
                ? [const Color(0xFF03DAC6), const Color(0xFF018786)]
                : [const Color(0xFF6C63FF), const Color(0xFF3F3D9E)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isConnected
                      ? const Color(0xFF03DAC6)
                      : const Color(0xFF6C63FF))
                  .withAlpha(80),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  isConnected ? Icons.power_settings_new : Icons.power_settings_new,
                  size: 64,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
