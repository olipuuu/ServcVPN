import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/server.dart';
import '../services/vpn_service.dart';
import '../services/server_storage.dart';
import '../services/config_import.dart';
import '../services/subscription_service.dart';
import '../widgets/server_card.dart';

class ServersScreen extends StatefulWidget {
  final VpnService vpnService;
  final ServerStorage serverStorage;

  const ServersScreen({
    super.key,
    required this.vpnService,
    required this.serverStorage,
  });

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isPinging = false;

  @override
  void initState() {
    super.initState();
    widget.serverStorage.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.serverStorage.removeListener(_onUpdate);
    _subscriptionService.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final servers = widget.serverStorage.servers;
    final activeIndex = widget.serverStorage.activeIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servers'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (servers.isNotEmpty)
            IconButton(
              icon: _isPinging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : const Icon(Icons.speed, color: Colors.white54),
              onPressed: _isPinging ? null : _pingAllServers,
              tooltip: 'Ping all servers',
            ),
          if (servers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white54),
              onPressed: _confirmClearAll,
              tooltip: 'Remove all servers',
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: servers.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dns, size: 64, color: Colors.white24),
                    SizedBox(height: 16),
                    Text(
                      'No servers yet',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add a server by link\nor import from a subscription URL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                final isActive = index == activeIndex;

                return Dismissible(
                  key: ValueKey('${server.configUri}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onDismissed: (_) {
                    widget.serverStorage.removeServer(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed ${server.name}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: _buildServerTile(server, index, isActive),
                );
              },
            ),
    );
  }

  Widget _buildServerTile(ServerInfo server, int index, bool isActive) {
    return ServerCard(
      server: server,
      isSelected: isActive,
      onTap: () {
        widget.serverStorage.setActiveIndex(index);
      },
      onLongPress: () => _showServerOptions(server, index),
    );
  }

  void _showServerOptions(ServerInfo server, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(server.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${server.protocol.toUpperCase()} - ${server.address}:${server.port}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13)),
                if (server.fallbackUris.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...server.fallbackUris.asMap().entries.map((entry) {
                    final uri = entry.value;
                    final proto = _extractProtocol(uri);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alt_route, color: Color(0xFF6C63FF), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Fallback: $proto',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final newFallbacks = List<String>.from(server.fallbackUris);
                              newFallbacks.removeAt(entry.key);
                              widget.serverStorage.updateServer(
                                index,
                                server.copyWith(fallbackUris: newFallbacks),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 12),
                _menuItem(
                  icon: Icons.alt_route,
                  title: 'Add fallback protocol',
                  subtitle: 'Alternative connection if primary fails',
                  onTap: () {
                    Navigator.pop(context);
                    _showAddFallbackDialog(server, index);
                  },
                ),
                const SizedBox(height: 8),
                _menuItem(
                  icon: Icons.delete,
                  title: 'Remove server',
                  subtitle: 'Delete this server',
                  onTap: () {
                    Navigator.pop(context);
                    widget.serverStorage.removeServer(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddFallbackDialog(ServerInfo server, int index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Add fallback protocol',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add an alternative protocol URI for the same server. '
                'If the primary connection fails, fallbacks will be tried in order.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'vless://... or trojan://... or vmess://...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste, color: Colors.white38),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) controller.text = data!.text!;
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              onPressed: () {
                final uri = controller.text.trim();
                if (ConfigImport.isValidUri(uri)) {
                  final newFallbacks = [...server.fallbackUris, uri];
                  widget.serverStorage.updateServer(
                    index,
                    server.copyWith(fallbackUris: newFallbacks),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Added ${_extractProtocol(uri)} fallback')),
                  );
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Invalid URI format')),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _extractProtocol(String uri) {
    final idx = uri.indexOf('://');
    return idx > 0 ? uri.substring(0, idx).toUpperCase() : 'UNKNOWN';
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _menuItem(
                  icon: Icons.link,
                  title: 'Add by link',
                  subtitle: 'Paste a VLESS, VMess, or Trojan URI',
                  onTap: () {
                    Navigator.pop(context);
                    _showAddByLinkDialog();
                  },
                ),
                const SizedBox(height: 8),
                _menuItem(
                  icon: Icons.cloud_download,
                  title: 'Add by subscription',
                  subtitle: 'Import servers from a subscription URL',
                  onTap: () {
                    Navigator.pop(context);
                    _showAddBySubscriptionDialog();
                  },
                ),
                const SizedBox(height: 8),
                _menuItem(
                  icon: Icons.content_paste,
                  title: 'Paste from clipboard',
                  subtitle: 'Auto-detect server link from clipboard',
                  onTap: () {
                    Navigator.pop(context);
                    _pasteFromClipboard();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: const Color(0xFF2A2A3E),
      onTap: onTap,
    );
  }

  void _showAddByLinkDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Add by link',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'vless://... or trojan://... or vmess://...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste,
                        color: Colors.white38),
                    onPressed: () async {
                      final data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        controller.text = data!.text!;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              onPressed: () => _addServerByLink(context, controller.text),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addServerByLink(BuildContext dialogContext, String uri) {
    final trimmed = uri.trim();
    if (!ConfigImport.isValidUri(trimmed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URI format')),
      );
      return;
    }

    final server = ConfigImport.parseServerFromUri(trimmed);
    if (server != null) {
      widget.serverStorage.addServer(server);
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${server.name}')),
      );
    }
  }

  void _showAddBySubscriptionDialog() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              title: const Text('Import subscription',
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'https://example.com/subscribe/...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: const Color(0xFF2A2A3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white54)),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final url = controller.text.trim();
                          if (url.isEmpty) return;

                          setDialogState(() => isLoading = true);

                          try {
                            final servers = await _subscriptionService
                                .fetchSubscription(url);
                            if (servers.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'No valid servers found in subscription')),
                                );
                              }
                            } else {
                              await widget.serverStorage.addServers(servers);
                              if (context.mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Imported ${servers.length} servers')),
                                );
                              }
                            }
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to fetch subscription: $e')),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                  child: const Text('Import'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';

    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty')),
        );
      }
      return;
    }

    if (ConfigImport.isValidUri(text)) {
      final server = ConfigImport.parseServerFromUri(text);
      if (server != null) {
        await widget.serverStorage.addServer(server);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${server.name}')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid server URI in clipboard')),
        );
      }
    }
  }

  Future<void> _pingAllServers() async {
    setState(() => _isPinging = true);
    final servers = widget.serverStorage.servers;
    for (int i = 0; i < servers.length; i++) {
      final server = servers[i];
      final pingMs = await widget.vpnService.pingServer(
        server.address,
        server.port,
      );
      if (pingMs > 0) {
        await widget.serverStorage.updateServer(
          i,
          server.copyWith(pingMs: pingMs),
        );
      }
    }
    if (mounted) setState(() => _isPinging = false);
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Remove all servers',
              style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to remove all saved servers?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              onPressed: () {
                widget.serverStorage.clearAll();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove all'),
            ),
          ],
        );
      },
    );
  }
}
