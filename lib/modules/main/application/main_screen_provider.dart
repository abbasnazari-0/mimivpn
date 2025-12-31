import 'dart:async';

import 'package:defyx_vpn/core/data/local/secure_storage/secure_storage.dart';
import 'package:defyx_vpn/modules/main/presentation/widgets/google_ads.dart';
import 'package:defyx_vpn/modules/main/presentation/widgets/rewarded_ad_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:defyx_vpn/modules/core/network.dart';
import 'package:defyx_vpn/shared/providers/connection_state_provider.dart';
import 'package:defyx_vpn/core/services/v2ray_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

final pingLoadingProvider = StateProvider<bool>((ref) => false);
final flagLoadingProvider = StateProvider<bool>((ref) => false);

final pingProvider = StateProvider<String>((ref) => '0');

final flagProvider = FutureProvider<String>((ref) async {
  final isLoading = ref.watch(flagLoadingProvider);
  final network = NetworkStatus();

  if (isLoading) {
    final flag = await network.getFlag();
    ref.read(flagLoadingProvider.notifier).state = false;
    return flag;
  }
  return await network.getFlag();
});

class MainScreenLogic {
  final WidgetRef ref;
  static const platform = MethodChannel('com.mimivpn.vpn');

  MainScreenLogic(this.ref);

  Future<void> refreshPing() async {
    print("=== refreshPing CALLED ===");
    // Manually refresh ping from V2Ray service
    final v2rayService = ref.read(v2rayServiceProvider.notifier);
    final v2rayState = ref.read(v2rayServiceProvider);

    print("Current V2Ray status: ${v2rayState.status}");
    print("Current ping value: ${v2rayState.ping}");

    if (v2rayState.status == V2RayConnectionStatus.connected) {
      print("Calling v2rayService.refreshPing()...");
      await v2rayService.refreshPing();
      final newPing = ref.read(v2rayServiceProvider).ping;
      print("V2Ray ping refreshed: $newPing ms");
    } else {
      print("Cannot refresh ping - not connected");
    }
  }

  Future<void> connectOrDisconnect() async {
    final connectionNotifier = ref.read(connectionStateProvider.notifier);
    final v2rayService = ref.read(v2rayServiceProvider.notifier);
    final v2rayState = ref.read(v2rayServiceProvider);

    try {
      bool success = false;

      if (v2rayState.status == V2RayConnectionStatus.connected) {
        // STEP 1: Show Rewarded Ad before disconnecting
        print('🎬 Step 1: Showing Rewarded Ad before disconnect...');
        final adService = RewardedAdService();

        // Try to show ad (if fails, still allow disconnect)
        try {
          await adService.showAd();
          print('✅ Rewarded Ad shown/dismissed');
        } catch (e) {
          print('⚠️ Rewarded Ad error (continuing with disconnect): $e');
        } finally {
          adService.dispose();
        }

        // STEP 2: Disconnect V2Ray (regardless of ad result)
        print('🔌 Step 2: Disconnecting VPN...');
        connectionNotifier.setDisconnecting();
        success = await v2rayService.disconnect();
        if (success) {
          connectionNotifier.setDisconnected();
          print('✅ VPN disconnected successfully');
        }
      } else {
        // STEP 1: Preload ads with real IP (before VPN connection)
        print('🎯 Step 1: Preloading ads before VPN connection...');
        ref.read(preloadAdsProvider.notifier).state = true;

        // Wait a bit for ads to start loading
        await Future.delayed(const Duration(milliseconds: 500));

        // STEP 2: Connect V2Ray
        print('🔌 Step 2: Connecting VPN...');
        connectionNotifier.setLoading();
        success = await v2rayService.connectWithDefaultConfig();
        if (success) {
          connectionNotifier.setConnected();
          print('✅ VPN connected successfully');
        }
      }

      if (!success) {
        connectionNotifier.setError();
      }
    } catch (e) {
      print("V2Ray connection error: $e");
      connectionNotifier.setError();
    }
  }

  Future<void> checkAndReconnect() async {
    final connectionState = ref.read(connectionStateProvider);
    final v2rayState = ref.read(v2rayServiceProvider);

    print("Connection status: ${connectionState.status}");
    print("V2Ray status: ${v2rayState.status}");

    // Sync connection states if needed
    if (connectionState.status == ConnectionStatus.connected &&
        v2rayState.status != V2RayConnectionStatus.connected) {
      // Re-establish V2Ray connection
      await connectOrDisconnect();
    }
  }

  Future<void> checkAndShowPrivacyNotice(Function showDialog) async {
    final prefs = await SharedPreferences.getInstance();
    final bool privacyNoticeShown =
        prefs.getBool('privacy_notice_shown') ?? false;
    if (!privacyNoticeShown) {
      showDialog();
    }
  }

  Future<void> markPrivacyNoticeShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_notice_shown', true);
  }

  Future<Map<String, dynamic>> checkForUpdate() async {
    final storage = ref.read(secureStorageProvider);

    final packageInfo = await PackageInfo.fromPlatform();
    final apiVersionParameters =
        await storage.readMap('api_version_parameters');

    final forceUpdate = apiVersionParameters['forceUpdate'] ?? false;

    final removeBuildNumber =
        apiVersionParameters['api_app_version']?.split('+').first ?? '0.0.0';

    final appVersion = Version.parse(packageInfo.version);
    final apiAppVersion = Version.parse(removeBuildNumber);

    final response = {
      'update': apiAppVersion > appVersion,
      'forceUpdate': forceUpdate,
      'changeLog': apiVersionParameters['changeLog'],
    };
    return response;
  }
}

// Provider برای استفاده در UI - باید از widget-specific ref استفاده کرد
// مثال استفاده:
// final logic = MainScreenLogic(ref); // داخل ConsumerWidget
