import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:defyx_vpn/modules/main/application/main_screen_provider.dart';

class SimpleConnectPage extends ConsumerWidget {
  const SimpleConnectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = MainScreenLogic(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MimiVPN - Updated'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'تست اتصال V2Ray',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await logic.connectOrDisconnect();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('درخواست اتصال/قطع ارسال شد'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Connect/Disconnect V2Ray',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await logic.refreshPing();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('اطلاعات ping بروزرسانی شد'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Refresh Ping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'حالا از سرویس V2Ray استفاده می‌کنه!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
