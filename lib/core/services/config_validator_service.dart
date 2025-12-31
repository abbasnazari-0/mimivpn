import 'dart:async';
import 'dart:developer';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:defyx_vpn/modules/main/data/models/vpn_config.dart';

/// نتیجه تست - شامل کانفیگ و index آن
class TestResult {
  final VpnConfig config;
  final int index;
  final int ping;

  TestResult({
    required this.config,
    required this.index,
    required this.ping,
  });

  @override
  String toString() => 'TestResult(${config.name}, index: $index, ping: $ping)';
}

/// Service برای اعتبارسنجی و ping کردن کانفیگ‌های VPN
class ConfigValidatorService {
  static const Duration pingTimeout = Duration(seconds: 15);
  static const Duration maxWaitTime = Duration(minutes: 3);

  final V2ray _v2ray;

  ConfigValidatorService() : _v2ray = V2ray(onStatusChanged: (_) {});

  /// تست کردن لیستی از کانفیگ‌ها و برگرداندن اولین کانفیگ کاری به همراه index
  Future<TestResult?> findWorkingConfig(
    List<VpnConfig> configs, {
    required Function(int current, int total, int? ping) onProgress,
    required Function(String error) onError,
  }) async {
    if (configs.isEmpty) {
      onError('❌ هیچ کانفیگی برای تست وجود ندارد');
      return null;
    }

    log('🔄 شروع تست ${configs.length} کانفیگ...');

    final startTime = DateTime.now();

    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];

      // بررسی مدت زمان
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        onError('❌ تجاوز از زمان مجاز');
        log('❌ تجاوز از زمان مجاز');
        return null;
      }

      try {
        log('🧪 تست کانفیگ ${i + 1}/${configs.length}: ${config.name}');

        // تست ping
        final ping = await testConfigPing(config.config);

        log('📊 نتیجه: ${config.name} - Ping: $ping ms');

        if (ping != null && ping > 0) {
          log('✅ کانفیگ کاری یافت شد: ${config.name} - Ping: ${ping}ms - Index: $i');
          onProgress(i + 1, configs.length, ping);
          return TestResult(config: config, index: i, ping: ping);
        } else {
          log('⚠️ کانفیگ ${config.name} پاسخ نداد');
          onProgress(i + 1, configs.length, null);
        }
      } catch (e) {
        log('❌ خطا در تست ${config.name}: $e');
        onProgress(i + 1, configs.length, null);
      }

      // صبر قبل از تست بعدی
      await Future.delayed(const Duration(milliseconds: 300));
    }

    onError('❌ هیچ کانفیگ کاری پیدا نشد');
    log('❌ تمام کانفیگ‌ها تست شدند');
    return null;
  }

  /// تست ping یک کانفیگ - روش ساده و مستقیم
  Future<int?> testConfigPing(String config) async {
    try {
      log('🔍 پارس کانفیگ...');

      // پارس کردن کانفیگ
      final V2RayURL parser;
      try {
        parser = V2ray.parseFromURL(config);
      } catch (e) {
        log('❌ خطا در پارس: $e');
        return null;
      }

      final fullConfig = parser.getFullConfiguration();
      log('📝 کانفیگ آماده: ${fullConfig.substring(0, 50)}...');

      // تست ping با timeout
      final ping = await _getServerDelayWithTimeout(fullConfig);

      log('📊 Ping نتیجه: $ping ms');
      return ping;
    } catch (e) {
      log('❌ خطا در testConfigPing: $e');
      return null;
    }
  }

  /// دریافت delay سرور با timeout
  Future<int?> _getServerDelayWithTimeout(String fullConfig) async {
    try {
      log('⏱️ شروع اندازه‌گیری delay...');

      final completer = Completer<int?>();
      final timeoutTimer = Timer(pingTimeout, () {
        if (!completer.isCompleted) {
          log('⏲️ Timeout - delay بیش از ${pingTimeout.inSeconds} ثانیه');
          completer.complete(null);
        }
      });

      try {
        final delay = await _v2ray.getServerDelay(config: fullConfig);

        if (!completer.isCompleted) {
          timeoutTimer.cancel();
          log('✅ Delay دریافت شد: $delay ms');
          completer.complete(delay);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          timeoutTimer.cancel();
          log('❌ Exception در getServerDelay: $e');
          completer.complete(null);
        }
      }

      return await completer.future;
    } catch (e) {
      log('❌ خطا در _getServerDelayWithTimeout: $e');
      return null;
    }
  }

  /// تست سریع یک کانفیگ برای بررسی درست‌بودنش
  Future<bool> isConfigValid(String config) async {
    try {
      final V2RayURL parser = V2ray.parseFromURL(config);
      return parser.getFullConfiguration().isNotEmpty;
    } catch (e) {
      log('❌ کانفیگ نامعتبر: $e');
      return false;
    }
  }
}
