import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:defyx_vpn/modules/main/application/main_screen_provider.dart';
import 'package:defyx_vpn/core/services/v2ray_service.dart';
import 'package:defyx_vpn/shared/providers/connection_state_provider.dart'
    as vpn_connection;

class MainConnectionButton extends ConsumerWidget {
  const MainConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(vpn_connection.connectionStateProvider);
    final v2rayState = ref.watch(v2rayServiceProvider);
    final logic = MainScreenLogic(ref);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Connection Status Display
        _buildStatusDisplay(connectionState, v2rayState),

        const SizedBox(height: 20),

        // Main Connection Button
        _buildConnectionButton(logic, connectionState, v2rayState, context),

        const SizedBox(height: 16),

        // V2Ray Info
        if (v2rayState.status == V2RayConnectionStatus.connected)
          _buildV2RayInfo(v2rayState),

        const SizedBox(height: 16),

        // Refresh Ping Button
        _buildRefreshButton(logic),
      ],
    );
  }

  Widget _buildStatusDisplay(vpn_connection.ConnectionState connectionState,
      V2RayConnectionState v2rayState) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    // Determine status based on V2Ray state
    switch (v2rayState.status) {
      case V2RayConnectionStatus.connected:
        statusText = 'Connected';
        statusColor = Colors.green;
        statusIcon = Icons.shield;
        break;
      case V2RayConnectionStatus.connecting:
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case V2RayConnectionStatus.disconnecting:
        statusText = 'Disconnecting...';
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case V2RayConnectionStatus.error:
        statusText = 'Error: ${v2rayState.errorMessage ?? 'Unknown error'}';
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusText = 'Disconnected';
        statusColor = Colors.grey;
        statusIcon = Icons.shield_outlined;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 12),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton(
    MainScreenLogic logic,
    vpn_connection.ConnectionState connectionState,
    V2RayConnectionState v2rayState,
    BuildContext context,
  ) {
    final isLoading =
        connectionState.status == vpn_connection.ConnectionStatus.loading ||
            v2rayState.status == V2RayConnectionStatus.connecting ||
            v2rayState.status == V2RayConnectionStatus.disconnecting;

    final isConnected = v2rayState.status == V2RayConnectionStatus.connected;

    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                await logic.connectOrDisconnect();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected ? Colors.red[400] : Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isConnected ? 'Disconnect' : 'Connect',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildV2RayInfo(V2RayConnectionState v2rayState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'V2Ray Connection Info',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (v2rayState.ping != null)
              _buildInfoRow(Icons.speed, 'Ping', '${v2rayState.ping}ms'),
            if (v2rayState.duration != null)
              _buildInfoRow(Icons.timer, 'Duration', v2rayState.duration!),
            if (v2rayState.serverCountry != null)
              _buildInfoRow(Icons.flag, 'Server', v2rayState.serverCountry!),
            if (v2rayState.downloadSpeed != null)
              _buildInfoRow(
                  Icons.download, 'Download', v2rayState.downloadSpeed!),
            if (v2rayState.uploadSpeed != null)
              _buildInfoRow(Icons.upload, 'Upload', v2rayState.uploadSpeed!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(MainScreenLogic logic) {
    return TextButton.icon(
      onPressed: () async {
        await logic.refreshPing();
      },
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
    );
  }
}
