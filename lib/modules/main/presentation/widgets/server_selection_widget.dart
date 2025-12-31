import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:defyx_vpn/core/services/v2ray_service.dart';
import 'package:defyx_vpn/modules/main/data/models/vpn_config.dart';

class ServerSelectionWidget extends ConsumerWidget {
  const ServerSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableServers = ref.watch(availableServersProvider);
    final selectedIndex = ref.watch(selectedServerIndexProvider);
    final v2rayService = ref.read(v2rayServiceProvider.notifier);
    final connectionStatus = ref.watch(v2rayStatusProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.dns, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Select Server',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed:
                      connectionStatus == V2RayConnectionStatus.disconnected
                          ? () async {
                              await v2rayService.refreshConfigs();
                            }
                          : null,
                  tooltip: 'Refresh servers',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Server List
          if (availableServers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading servers...'),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableServers.length,
              itemBuilder: (context, index) {
                final server = availableServers[index];
                final isSelected = index == selectedIndex;
                final isConnected =
                    connectionStatus == V2RayConnectionStatus.connected &&
                        isSelected;

                return ServerTile(
                  server: server,
                  isSelected: isSelected,
                  isConnected: isConnected,
                  isDisabled: connectionStatus ==
                          V2RayConnectionStatus.connecting ||
                      connectionStatus == V2RayConnectionStatus.disconnecting,
                  onTap: connectionStatus == V2RayConnectionStatus.disconnected
                      ? () async {
                          await v2rayService.selectServer(index);
                        }
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class ServerTile extends StatelessWidget {
  final VpnConfig server;
  final bool isSelected;
  final bool isConnected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.isConnected,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isConnected
            ? Colors.green.withOpacity(0.2)
            : isSelected
                ? Colors.blue.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
        child: Text(
          server.flag,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              server.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isConnected
                    ? Colors.green
                    : isSelected
                        ? Colors.blue
                        : null,
              ),
            ),
          ),
          if (server.premium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Pro',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Text('${server.country.toUpperCase()}'),
          if (server.ping != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.speed,
              size: 12,
              color: _getPingColor(server.ping!),
            ),
            const SizedBox(width: 4),
            Text(
              '${server.ping}ms',
              style: TextStyle(
                color: _getPingColor(server.ping!),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isConnected)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            )
          else if (isSelected)
            const Icon(
              Icons.radio_button_checked,
              color: Colors.blue,
              size: 20,
            )
          else
            const Icon(
              Icons.radio_button_unchecked,
              color: Colors.grey,
              size: 20,
            ),
        ],
      ),
      enabled: !isDisabled && onTap != null,
      onTap: onTap,
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isConnected ? Colors.green : Colors.blue,
                width: 2,
              ),
            )
          : null,
      tileColor: isSelected
          ? (isConnected
              ? Colors.green.withOpacity(0.05)
              : Colors.blue.withOpacity(0.05))
          : null,
    );
  }

  Color _getPingColor(int ping) {
    if (ping < 100) return Colors.green;
    if (ping < 200) return Colors.orange;
    return Colors.red;
  }
}

class ServerSelectionBottomSheet extends ConsumerWidget {
  const ServerSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ServerSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Select Server',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Server List
          const Expanded(
            child: ServerSelectionWidget(),
          ),
        ],
      ),
    );
  }
}
