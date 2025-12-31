import 'dart:convert';
import 'dart:io';
import 'package:defyx_vpn/modules/main/data/models/vpn_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service برای دریافت کانفیگ‌های VPN از API یا cache
class ConfigService {
  static const String API_URL =
      'https://mimi.arianadevs.com/api/v1/vpn_config_api_simple.php';
  static const String CACHE_KEY = 'vpn_configs';
  static const String LAST_UPDATE_KEY = 'configs_last_update';
  static const Duration CACHE_DURATION = Duration(hours: 6);
  static const int REQUEST_TIMEOUT = 15; // seconds

  static ConfigService? _instance;
  static ConfigService get instance {
    _instance ??= ConfigService._();
    return _instance!;
  }

  ConfigService._();

  /// دریافت کانفیگ‌های VPN (از API یا Cache)
  Future<List<VpnConfig>> getConfigs() async {
    try {
      // بررسی cache
      final cachedConfigs = await _getCachedConfigs();
      final isCacheExpired = await _isCacheExpired();

      // if (cachedConfigs.isNotEmpty && !isCacheExpired) {
      //   print('✅ Using cached configs');
      //   return cachedConfigs;
      // }

      // درخواست از API
      print('🌐 Fetching configs from API...');
      final apiConfigs = await _fetchConfigsFromAPI();

      if (apiConfigs.isNotEmpty) {
        await _cacheConfigs(apiConfigs);
        print('✅ API configs cached successfully');
        return apiConfigs;
      }

      // اگر API فیل کرد، از cache قدیمی استفاده کن
      // if (cachedConfigs.isNotEmpty) {
      //   print('⚠️ API failed, using old cache');
      //   return cachedConfigs;
      // }

      // در نهایت از کانفیگ‌های دیفالت استفاده کن
      print('🔄 Using default configs');
      return _getDefaultConfigs();
    } catch (e) {
      print('❌ ConfigService Error: $e');
      return _getDefaultConfigs();
    }
  }

  /// درخواست مستقیم از API
  Future<List<VpnConfig>> _fetchConfigsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse(API_URL),
        headers: {
          'User-Agent': 'MimiVPN/1.0',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      ).timeout(Duration(seconds: REQUEST_TIMEOUT));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success' && data['configs'] is List) {
          final List<dynamic> configsJson = data['configs'];

          final configs = configsJson.map((config) {
            return VpnConfig.fromMap({
              'name': config['name'] ?? 'Server',
              'config': config['config'] ?? '',
              'country': config['country'] ?? 'Unknown',
              'flag': _getFlagForCountry(config['country'] ?? ''),
              'premium': config['premium'] ?? false,
            });
          }).toList();

          print('✅ Received ${configs.length} configs from API');
          print('📍 Source: ${data['source']}, Country: ${data['country']}');

          return configs;
        }
      }

      print('❌ API Error: ${response.statusCode}');
      return [];
    } on SocketException {
      print('❌ Network Error: No internet connection');
      return [];
    } on HttpException {
      print('❌ HTTP Error: Server unreachable');
      return [];
    } catch (e) {
      print('❌ API Error: $e');
      return [];
    }
  }

  /// دریافت کانفیگ‌های cached
  Future<List<VpnConfig>> _getCachedConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(CACHE_KEY);

      if (cachedData != null) {
        final List<dynamic> configsJson = json.decode(cachedData);
        return configsJson.map((config) => VpnConfig.fromMap(config)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Cache Error: $e');
      return [];
    }
  }

  /// ذخیره کانفیگ‌ها در cache
  Future<void> _cacheConfigs(List<VpnConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String configsJson =
          json.encode(configs.map((config) => config.toMap()).toList());

      await prefs.setString(CACHE_KEY, configsJson);
      await prefs.setInt(
          LAST_UPDATE_KEY, DateTime.now().millisecondsSinceEpoch);

      print('💾 Configs cached: ${configs.length} items');
    } catch (e) {
      print('❌ Cache Save Error: $e');
    }
  }

  /// بررسی expire بودن cache
  Future<bool> _isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(LAST_UPDATE_KEY);

      if (timestamp == null) return true;

      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateTime);

      return difference > CACHE_DURATION;
    } catch (e) {
      return true; // اگر خطا بود، cache رو expired فرض کن
    }
  }

  /// کانفیگ‌های پیش‌فرض - REMOVED! Must use API
  List<VpnConfig> _getDefaultConfigs() {
    // Returning empty list to force API usage
    // If API fails completely, user will see error message
    return [
      VpnConfig(
        name: 'No Servers Available',
        config: '', // Empty config
        country: 'XX',
        flag: '❌',
        premium: false,
      ),
    ];
  }

  /// دریافت flag برای کشور
  String _getFlagForCountry(String countryCode) {
    final flags = {
      'IR': '🇮🇷',
      'US': '🇺🇸',
      'DE': '🇩🇪',
      'NL': '🇳🇱',
      'SG': '🇸🇬',
      'JP': '🇯🇵',
      'UK': '🇬🇧',
      'FR': '🇫🇷',
      'CA': '🇨🇦',
      'AU': '🇦🇺',
    };

    return flags[countryCode.toUpperCase()] ?? '🌐';
  }

  /// پاک کردن cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CACHE_KEY);
      await prefs.remove(LAST_UPDATE_KEY);
      print('🗑️ Cache cleared');
    } catch (e) {
      print('❌ Cache Clear Error: $e');
    }
  }

  /// Force refresh (پاک کردن cache و درخواست مجدد)
  Future<List<VpnConfig>> refreshConfigs() async {
    await clearCache();
    return await getConfigs();
  }

  /// بررسی وضعیت API
  Future<bool> checkAPIHealth() async {
    try {
      final response =
          await http.head(Uri.parse(API_URL)).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// دریافت آمار cache
  Future<Map<String, dynamic>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(LAST_UPDATE_KEY);
    final hasCache = prefs.containsKey(CACHE_KEY);
    final isExpired = await _isCacheExpired();

    return {
      'has_cache': hasCache,
      'last_update': lastUpdate != null
          ? DateTime.fromMillisecondsSinceEpoch(lastUpdate).toIso8601String()
          : null,
      'is_expired': isExpired,
      'cache_duration_hours': CACHE_DURATION.inHours,
    };
  }
}
