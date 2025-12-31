import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/v2ray_controller.dart';

/// Dialog ساده برای تست و اتصال به کانفیگ‌ها
class SimpleConfigTestDialog extends ConsumerStatefulWidget {
  const SimpleConfigTestDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<SimpleConfigTestDialog> createState() =>
      _SimpleConfigTestDialogState();
}

class _SimpleConfigTestDialogState
    extends ConsumerState<SimpleConfigTestDialog> {
  String _status = 'درحال تست کانفیگ‌ها...';
  int _currentIndex = 0;
  int _totalCount = 0;
  bool _isComplete = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startTesting();
  }

  Future<void> _startTesting() async {
    try {
      final controller = ref.read(v2rayControllerProvider);

      final success = await controller.testAndConnectToFirstWorkingConfig(
        onProgress: (current, total, ping) {
          if (mounted) {
            setState(() {
              _currentIndex = current;
              _totalCount = total;
              if (ping != null && ping > 0) {
                _status = '✅ کانفیگ #$current یافت شد! Ping: ${ping}ms';
              } else {
                _status = '🔄 تست کانفیگ $current/$total...';
              }
            });
          }
        },
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isComplete = true;
          _status = '✅ اتصال برقرار شد';
        });

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _hasError = true;
          _status = '❌ کانفیگ کاری پیدا نشد';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _status = '❌ خطا: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون وضعیت
            if (!_isComplete && !_hasError)
              const CircularProgressIndicator()
            else if (_isComplete)
              const Icon(Icons.check_circle, color: Colors.green, size: 64)
            else
              const Icon(Icons.error, color: Colors.red, size: 64),

            const SizedBox(height: 24),

            // متن وضعیت
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // پیشرفت
            if (_totalCount > 0 && !_isComplete && !_hasError)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _totalCount > 0 ? _currentIndex / _totalCount : 0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_currentIndex / $_totalCount',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

            // دکمه بستن در صورت خطا
            if (_hasError) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('بستن'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
