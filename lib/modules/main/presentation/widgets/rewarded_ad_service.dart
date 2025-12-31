import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  // Singleton pattern
  static final RewardedAdService _instance = RewardedAdService._internal();
  factory RewardedAdService() => _instance;
  RewardedAdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;

  static String get adUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ANDROID_AD_REWARD_AD_UNIT_ID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['IOS_AD_REWARD_AD_UNIT_ID'] ?? '';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Preload rewarded ad
  Future<void> loadAd() async {
    debugPrint('🎬 Loading Rewarded Ad...');

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded Ad loaded successfully');
          _rewardedAd = ad;
          _isAdLoaded = true;

          // Set callbacks
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('👁️ Rewarded Ad showed full screen');
              _isAdShowing = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('❌ Rewarded Ad dismissed');
              _isAdShowing = false;
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Rewarded Ad failed to show: $error');
              _isAdShowing = false;
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded Ad failed to load: $error');
          _isAdLoaded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  // Show rewarded ad with callback
  Future<bool> showAd() async {
    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('⚠️ Rewarded Ad not loaded yet, loading now...');
      await loadAd(); // Try to load if not loaded

      // If still not loaded, allow disconnect
      if (!_isAdLoaded || _rewardedAd == null) {
        debugPrint('⚠️ Could not load ad, continuing with disconnect');
        return true;
      }
    }

    if (_isAdShowing) {
      debugPrint('⚠️ Rewarded Ad already showing');
      return false;
    }

    debugPrint('🎬 Showing Rewarded Ad...');

    final completer = Completer<bool>();

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
      },
    );

    // Listen for ad dismissal
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('👁️ Rewarded Ad showed full screen');
        _isAdShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
            '✅ Rewarded Ad dismissed - User watched (complete or incomplete)');
        _isAdShowing = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;

        // Preload next ad for future use
        debugPrint('🔄 Preloading next Rewarded Ad...');
        loadAd();

        if (!completer.isCompleted) {
          completer.complete(true); // Allow disconnect
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Rewarded Ad failed to show: $error');
        _isAdShowing = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;

        // Try to preload again
        debugPrint('🔄 Preloading next Rewarded Ad after error...');
        loadAd();

        if (!completer.isCompleted) {
          completer.complete(true); // Allow disconnect anyway
        }
      },
    );

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    _isAdShowing = false;
  }

  bool get isAdLoaded => _isAdLoaded;
  bool get isAdShowing => _isAdShowing;
}
