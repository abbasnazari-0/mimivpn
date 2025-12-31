import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/v2ray_controller.dart';
import '../../../core/services/v2ray_service.dart';
import 'simple_config_test_dialog.dart';

class V2RayConnectionWidget extends ConsumerWidget {
  const V2RayConnectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(v2rayControllerProvider);
    final connectionState = ref.watch(v2rayServiceProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connection Status
            _buildStatusHeader(connectionState),

            const SizedBox(height: 20),

            // Connect/Disconnect Button
            _buildConnectionButton(controller, connectionState, context),

            const SizedBox(height: 16),

            // Connection Info
            if (connectionState.status == V2RayConnectionStatus.connected)
              _buildConnectionInfo(connectionState),

            // Error Message
            if (connectionState.errorMessage != null)
              _buildErrorMessage(connectionState.errorMessage!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(V2RayConnectionState state) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (state.status) {
      case V2RayConnectionStatus.connected:
        statusColor = Colors.green;
        statusIcon = Icons.shield_outlined;
        statusText = 'Connected';
        break;
      case V2RayConnectionStatus.connecting:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Connecting...';
        break;
      case V2RayConnectionStatus.disconnecting:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Disconnecting...';
        break;
      case V2RayConnectionStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusText = 'Error';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.shield_outlined;
        statusText = 'Disconnected';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          statusIcon,
          color: statusColor,
          size: 32,
        ),
        const SizedBox(width: 12),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionButton(V2RayController controller,
      V2RayConnectionState state, BuildContext context) {
    final isLoading = state.status == V2RayConnectionStatus.connecting ||
        state.status == V2RayConnectionStatus.disconnecting;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                // اگر قصد اتصال است، ابتدا تست کانفیگ‌ها را نمایش بده
                if (state.status != V2RayConnectionStatus.connected) {
                  _showConfigTestDialog(context, controller);
                } else {
                  // اگر قبلاً متصل است، قطع کن
                  final success = await controller.toggle();
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(state.errorMessage ?? 'Connection failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: state.status == V2RayConnectionStatus.connected
              ? Colors.red[400]
              : Colors.blue[600],
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
                state.status == V2RayConnectionStatus.connected
                    ? 'Disconnect'
                    : 'Connect',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showConfigTestDialog(BuildContext context, V2RayController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SimpleConfigTestDialog(),
    );
  }

  Widget _buildConnectionInfo(V2RayConnectionState state) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),

        // Server Info
        if (state.serverCountry != null)
          _buildInfoRow(
            icon: Icons.flag,
            label: 'Server',
            value: state.serverCountry!,
          ),

        // Ping
        if (state.ping != null)
          _buildInfoRow(
            icon: Icons.speed,
            label: 'Ping',
            value: '${state.ping}ms',
          ),

        // Duration
        if (state.duration != null)
          _buildInfoRow(
            icon: Icons.timer,
            label: 'Duration',
            value: state.duration!,
          ),

        // Speed Info
        if (state.uploadSpeed != null || state.downloadSpeed != null)
          Column(
            children: [
              if (state.downloadSpeed != null)
                _buildInfoRow(
                  icon: Icons.download,
                  label: 'Download',
                  value: state.downloadSpeed!,
                ),
              if (state.uploadSpeed != null)
                _buildInfoRow(
                  icon: Icons.upload,
                  label: 'Upload',
                  value: state.uploadSpeed!,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
