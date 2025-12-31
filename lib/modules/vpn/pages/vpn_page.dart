import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/v2ray_connection_widget.dart';
import '../controllers/v2ray_controller.dart';

class VpnPage extends ConsumerWidget {
  const VpnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(v2rayControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MimiVPN'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showConfigDialog(context, controller);
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            V2RayConnectionWidget(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context, V2RayController controller) {
    final configController = TextEditingController(
      text: controller.getStoredConfig(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('V2Ray Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: configController,
              decoration: const InputDecoration(
                labelText: 'VLESS/VMESS URL',
                hintText: 'vless://...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: controller.getAutoConnect(),
                  onChanged: (value) {
                    controller.setAutoConnect(value ?? false);
                  },
                ),
                const Text('Auto-connect on startup'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.updateConfig(configController.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
