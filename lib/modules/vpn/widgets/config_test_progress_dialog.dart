import 'package:defyx_vpn/common/services/config_service.dart';
import 'package:defyx_vpn/core/services/config_validator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget برای نمایش پیشرفت تست کانفیگ‌ها
class ConfigTestProgressDialog extends ConsumerStatefulWidget {
  final VoidCallback? onCancel;

  const ConfigTestProgressDialog({
    Key? key,
    this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<ConfigTestProgressDialog> createState() =>
      _ConfigTestProgressDialogState();
}

class _ConfigTestProgressDialogState
    extends ConsumerState<ConfigTestProgressDialog> {
  late ConfigValidatorService _validator;
  String _status = 'درحال بارگذاری کانفیگ‌ها...';
  int _currentIndex = 0;
  int _totalCount = 0;
  int? _currentPing;
  bool _isComplete = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _validator = ConfigValidatorService();
    _startConfigTest();
  }

  Future<void> _startConfigTest() async {
    try {
      // دریافت کانفیگ‌ها
      final configs = await ConfigService.instance.getConfigs();

      if (!mounted) return;

      setState(() {
        _totalCount = configs.length;
        _status = 'درحال تست ${_totalCount} کانفیگ...';
      });

      if (configs.isEmpty) {
        setState(() {
          _hasError = true;
          _status = '❌ هیچ کانفیگی دریافت نشد';
        });
        return;
      }

      // تست کانفیگ‌ها
      final testResult = await _validator.findWorkingConfig(
        configs,
        onProgress: (current, total, ping) {
          if (mounted) {
            setState(() {
              _currentIndex = current;
              _totalCount = total;
              _currentPing = ping;
              if (ping != null && ping > 0) {
                _status = '✅ کانفیگ #$current یافت شد! Ping: ${ping}ms';
              } else {
                _status = '🔄 تست کانفیگ $current/$total...';
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _status = error;
            });
          }
        },
      );

      if (!mounted) return;

      if (testResult != null) {
        setState(() {
          _isComplete = true;
          _status =
              '✅ اتصال آماده است (ایندکس: ${testResult.index}, Ping: ${testResult.ping}ms)';
        });

        // صبر برای نمایش پیام موفقیت
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pop();
          // widget.onSuccess(testResult);
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
          _status = 'خطا: $e';
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
            // عنوان
            Row(
              children: [
                Icon(
                  _hasError ? Icons.error_outline : Icons.cloud_queue,
                  color: _hasError ? Colors.red : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _hasError ? 'خطا در تست' : 'تست کانفیگ‌ها',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // نوار پیشرفت
            if (_totalCount > 0 && !_hasError)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _currentIndex / _totalCount,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentPing != null ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_currentIndex / _totalCount * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // وضعیت
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasError ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasError ? Colors.red[200]! : Colors.blue[200]!,
                ),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _hasError ? Colors.red[700] : Colors.blue[700],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // شمارنده
            Text(
              'کانفیگ: $_currentIndex / $_totalCount',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            if (_currentPing != null) ...[
              const SizedBox(height: 8),
              Text(
                'Ping: $_currentPing ms',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // دکمه‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_hasError)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onCancel?.call();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('بستن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (!_isComplete && !_hasError)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onCancel?.call();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('متوقف کنید'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
