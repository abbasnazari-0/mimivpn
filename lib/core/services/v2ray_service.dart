import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defyx_vpn/core/services/ip_location_service.dart';
import 'package:defyx_vpn/common/services/config_service.dart';
import 'package:defyx_vpn/modules/main/data/models/vpn_config.dart';

// V2Ray Connection Status Enum
enum V2RayConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

// V2Ray Connection State Model
class V2RayConnectionState {
  final V2RayConnectionStatus status;
  final String? errorMessage;
  final int? ping;
  final String? uploadSpeed;
  final String? downloadSpeed;
  final String? duration;
  final String? serverCountry;

  const V2RayConnectionState({
    required this.status,
    this.errorMessage,
    this.ping,
    this.uploadSpeed,
    this.downloadSpeed,
    this.duration,
    this.serverCountry,
  });

  V2RayConnectionState copyWith({
    V2RayConnectionStatus? status,
    String? errorMessage,
    int? ping,
    String? uploadSpeed,
    String? downloadSpeed,
    String? duration,
    String? serverCountry,
  }) {
    return V2RayConnectionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      ping: ping ?? this.ping,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      duration: duration ?? this.duration,
      serverCountry: serverCountry ?? this.serverCountry,
    );
  }

  @override
  String toString() {
    return 'V2RayConnectionState{status: $status, errorMessage: $errorMessage, ping: $ping, uploadSpeed: $uploadSpeed, downloadSpeed: $downloadSpeed, duration: $duration, serverCountry: $serverCountry}';
  }
}

// V2Ray Service Class
class V2RayService extends StateNotifier<V2RayConnectionState> {
  static const String _kDefaultVlessConfig =
      ""; // Removed static config - will use dynamic loading

  static const String _kStorageKeyConfig = 'v2ray_config';
  static const String _kStorageKeyAutoConnect = 'v2ray_auto_connect';
  static const String _kStorageKeySelectedServer = 'selected_server_index';

  late V2ray _v2ray;
  Timer? _pingTimer;
  Timer? _durationTimer;
  DateTime? _connectionStartTime;
  SharedPreferences? _prefs;

  // Dynamic configs cache
  List<VpnConfig> _availableConfigs = [];
  int _selectedConfigIndex = 0;

  V2RayService()
      : super(const V2RayConnectionState(
            status: V2RayConnectionStatus.disconnected)) {
    _initializeService();
  }

  // Initialize the V2Ray service
  Future<void> _initializeService() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      _v2ray = V2ray(
        onStatusChanged: _onStatusChanged,
      );

      await _v2ray.initialize(
        notificationIconResourceType: "mipmap",
        notificationIconResourceName: "_clean_ic_launcher",
      );

      log('V2Ray service initialized successfully');

      // Load dynamic configs
      await _loadDynamicConfigs();

      // Auto-connect if enabled
      if (_prefs?.getBool(_kStorageKeyAutoConnect) ?? false) {
        await connectWithStoredConfig();
      }
    } catch (e) {
      log('Failed to initialize V2Ray service: $e');
      state = state.copyWith(
        status: V2RayConnectionStatus.error,
        errorMessage: 'Failed to initialize V2Ray: $e',
      );
    }
  }

  // Load dynamic configs from ConfigService
  Future<void> _loadDynamicConfigs() async {
    try {
      log('🌐 Loading dynamic VPN configs...');
      _availableConfigs = await ConfigService.instance.getConfigs();

      // Load saved server selection
      _selectedConfigIndex = _prefs?.getInt(_kStorageKeySelectedServer) ?? 0;

      // Ensure index is valid
      if (_selectedConfigIndex >= _availableConfigs.length) {
        _selectedConfigIndex = 0;
      }

      log('✅ Loaded ${_availableConfigs.length} configs, selected index: $_selectedConfigIndex');
    } catch (e) {
      log('❌ Failed to load dynamic configs: $e');
      // Use single empty config as fallback - forcing API usage
      _availableConfigs = [
        VpnConfig(
          name: 'Loading...',
          config: '', // Empty config to force API loading
          country: 'XX',
          flag: '🌐',
          premium: false,
        )
      ];
      _selectedConfigIndex = 0;
    }
  }

  bool isPingRefreshed = false;

  // Handle V2Ray status changes
  void _onStatusChanged(V2RayStatus status) {
    // log('V2Ray status changed: ${status.state}');

    switch (status.state) {
      case "CONNECTED":
        state = state.copyWith(
          status: V2RayConnectionStatus.connected,
          errorMessage: null,
          uploadSpeed: _formatSpeed(status.uploadSpeed),
          downloadSpeed: _formatSpeed(status.downloadSpeed),
        );
        _startTimers();

        // Immediately refresh ping after connection
        if (!isPingRefreshed) _refreshPingAfterConnection();

      // تشخیص کشور واقعی از IP
      // _detectCountry();
      // break;

      case "DISCONNECTED":
        isPingRefreshed = false;
        state = state.copyWith(
          status: V2RayConnectionStatus.disconnected,
          errorMessage: null,
          ping: null,
          uploadSpeed: null,
          downloadSpeed: null,
          duration: null,
        );
        _stopTimers();
        break;

      case "CONNECTING":
        state = state.copyWith(
          status: V2RayConnectionStatus.connecting,
          errorMessage: null,
        );
        break;

      default:
        log('Unknown V2Ray status: ${status.state}');
    }
  }

  // Connect with default config - Force API usage
  Future<bool> connectWithDefaultConfig() async {
    log('🔄 Forcing API config loading...');
    await _loadDynamicConfigs();
    // return await connectWithStoredConfig();
    return await testAndConnectToFirstWorkingConfig();
  }

  // Connect with stored config (from selected server)
  Future<bool> connectWithStoredConfig() async {
    if (_availableConfigs.isNotEmpty &&
        _selectedConfigIndex < _availableConfigs.length) {
      final selectedConfig = _availableConfigs[_selectedConfigIndex];

      // Check if config is empty - reload from API if needed
      if (selectedConfig.config.isEmpty) {
        log('🔄 Config empty, reloading from API...');
        await _loadDynamicConfigs();

        if (_availableConfigs.isNotEmpty &&
            _selectedConfigIndex < _availableConfigs.length) {
          final newConfig = _availableConfigs[_selectedConfigIndex];
          if (newConfig.config.isNotEmpty) {
            log('🚀 Connecting with fresh API config: ${newConfig.name}');
            return await connectWithConfig(newConfig.config);
          }
        }
      }

      log('🚀 Connecting with selected server: ${selectedConfig.name}');
      return await connectWithConfig(selectedConfig.config);
    } else {
      // Force reload from API - no fallback to legacy
      log('🔄 No configs available, forcing API reload...');
      await _loadDynamicConfigs();

      if (_availableConfigs.isNotEmpty &&
          _availableConfigs[0].config.isNotEmpty) {
        log('� Using first API config');
        return await connectWithConfig(_availableConfigs[0].config);
      } else {
        log('❌ No valid configs available from API');
        state = state.copyWith(
          status: V2RayConnectionStatus.error,
          errorMessage:
              'No valid server configurations available. Please check internet connection.',
        );
        return false;
      }
    }
  }

  // Connect with custom config
  Future<bool> connectWithConfig(String config) async {
    try {
      state = state.copyWith(status: V2RayConnectionStatus.connecting);

      // Parse the V2Ray URL
      final V2RayURL parser = V2ray.parseFromURL(config);

      // Store the config for future use
      await _prefs?.setString(_kStorageKeyConfig, config);

      // Extract server country from remark or URL
      final serverCountry = _extractServerCountry(parser.remark);
      state = state.copyWith(serverCountry: serverCountry);

      // Get server delay (ping)
      try {
        final ping =
            await _v2ray.getServerDelay(config: parser.getFullConfiguration());
        state = state.copyWith(ping: ping);
      } catch (e) {
        log('Failed to get server delay: $e');
      }

      // Request VPN permission if needed
      final hasPermission = await _v2ray.requestPermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: V2RayConnectionStatus.error,
          errorMessage: 'VPN permission denied',
        );
        return false;
      }

      // Get bypassed apps from SharedPreferences
      final bypassedAppsJson = _prefs?.getString('bypassed_apps');
      List<String> bypassedApps = [];

      if (bypassedAppsJson != null && bypassedAppsJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(bypassedAppsJson);
          bypassedApps = List<String>.from(decoded);
          log('Bypassed apps loaded: ${bypassedApps.length} apps');
        } catch (e) {
          log('Failed to decode bypassed apps: $e');
        }
      }

      bypassedApps.add("com.mimivpn.app");
      bypassedApps.add("com.google.android.gms.ads");
      log('Total bypassed apps to send: ${bypassedApps.length} apps');

      // Start V2Ray connection

      await _v2ray.startV2Ray(
        remark: parser.remark.isNotEmpty ? parser.remark : "MIMI VPN",
        config: parser.getFullConfiguration(),
        blockedApps: bypassedApps,
      );
      connectedServerIP = parser.address;

      _connectionStartTime = DateTime.now();

      log('V2Ray connection started successfully');
      return true;
    } catch (e) {
      log('Failed to connect V2Ray: $e');
      state = state.copyWith(
        status: V2RayConnectionStatus.error,
        errorMessage: 'Connection failed: $e',
      );
      return false;
    }
  }

  String connectedServerIP = "";

  // Disconnect V2Ray
  Future<bool> disconnect() async {
    try {
      state = state.copyWith(status: V2RayConnectionStatus.disconnecting);

      await _v2ray.stopV2Ray();

      log('V2Ray disconnected successfully');
      return true;
    } catch (e) {
      log('Failed to disconnect V2Ray: $e');
      state = state.copyWith(
        status: V2RayConnectionStatus.error,
        errorMessage: 'Disconnect failed: $e',
      );
      return false;
    }
  }

  // Toggle connection
  Future<bool> toggleConnection() async {
    switch (state.status) {
      case V2RayConnectionStatus.disconnected:
      case V2RayConnectionStatus.error:
        return await connectWithStoredConfig();

      case V2RayConnectionStatus.connected:
        return await disconnect();

      default:
        log('Cannot toggle connection in current state: ${state.status}');
        return false;
    }
  }

  // Update config and save
  Future<void> updateConfig(String config) async {
    await _prefs?.setString(_kStorageKeyConfig, config);
  }

  // Get stored config
  String getStoredConfig() {
    return _prefs?.getString(_kStorageKeyConfig) ?? _kDefaultVlessConfig;
  }

  // Set auto-connect
  Future<void> setAutoConnect(bool enabled) async {
    await _prefs?.setBool(_kStorageKeyAutoConnect, enabled);
  }

  // Get auto-connect status
  bool getAutoConnect() {
    return _prefs?.getBool(_kStorageKeyAutoConnect) ?? false;
  }

  // Get available configs
  List<VpnConfig> getAvailableConfigs() {
    return List.unmodifiable(_availableConfigs);
  }

  // Get selected config index
  int getSelectedConfigIndex() {
    return _selectedConfigIndex;
  }

  // Get currently selected config
  VpnConfig? getSelectedConfig() {
    if (_availableConfigs.isNotEmpty &&
        _selectedConfigIndex < _availableConfigs.length) {
      return _availableConfigs[_selectedConfigIndex];
    }
    return null;
  }

  // Select server by index
  Future<void> selectServer(int index) async {
    if (index >= 0 && index < _availableConfigs.length) {
      _selectedConfigIndex = index;
      await _prefs?.setInt(_kStorageKeySelectedServer, index);

      final config = _availableConfigs[index];
      await _prefs?.setString(_kStorageKeyConfig, config.config);

      log('✅ Server selected: ${config.name} (index: $index)');
    }
  }

  // Refresh configs from API
  Future<void> refreshConfigs() async {
    try {
      log('🔄 Refreshing configs from API...');
      _availableConfigs = await ConfigService.instance.refreshConfigs();

      // Ensure current selection is still valid
      if (_selectedConfigIndex >= _availableConfigs.length) {
        _selectedConfigIndex = 0;
        await _prefs?.setInt(_kStorageKeySelectedServer, 0);
      }

      log('✅ Configs refreshed: ${_availableConfigs.length} servers');
    } catch (e) {
      log('❌ Failed to refresh configs: $e');
    }
  }

  // Connect with specific server
  Future<bool> connectWithServer(int serverIndex) async {
    if (serverIndex >= 0 && serverIndex < _availableConfigs.length) {
      return await testAndConnectToFirstWorkingConfig();
      // await selectServer(serverIndex);

      // return await connectWithStoredConfig();
    }
    return false;
  }

  // تست کانفیگ‌ها و اتصال به اولین کانفیگی که پینگ داد
  Future<bool> testAndConnectToFirstWorkingConfig({
    Function(int current, int total, int? ping)? onProgress,
  }) async {
    try {
      // اگر کانفیگ نداریم، بارگذاری کن
      if (_availableConfigs.isEmpty) {
        log('🔄 بارگذاری کانفیگ‌ها...');
        await _loadDynamicConfigs();
      }

      if (_availableConfigs.isEmpty) {
        log('❌ هیچ کانفیگی وجود ندارد');
        return false;
      }

      log('🔍 شروع تست ${_availableConfigs.length} کانفیگ...');

      // تست هر کانفیگ
      for (int i = 0; i < _availableConfigs.length; i++) {
        final config = _availableConfigs[i];
        log('🧪 تست کانفیگ ${i + 1}/${_availableConfigs.length}: ${config.name}');

        try {
          final V2RayURL parser = V2ray.parseFromURL(config.config);

          // تست ping با timeout
          final pingFuture = _v2ray.getServerDelay(
            config: parser.getFullConfiguration(),
          );

          final ping = await pingFuture.timeout(
            const Duration(seconds: 10),
            onTimeout: () => 0,
          );

          // اطلاع دادن به UI
          onProgress?.call(
              i + 1, _availableConfigs.length, ping > 0 ? ping : null);

          if (ping > 0) {
            log('✅ کانفیگ کاری پیدا شد! ${config.name} - Ping: $ping ms');

            // انتخاب این کانفیگ
            _selectedConfigIndex = i;
            await _prefs?.setInt(_kStorageKeySelectedServer, i);

            // اتصال
            return await connectWithConfig(config.config);
          } else {
            log('❌ Ping ناموفق: ${config.name}');
          }
        } catch (e) {
          log('❌ خطا در تست ${config.name}: $e');
          onProgress?.call(i + 1, _availableConfigs.length, null);
        }
      }

      log('❌ هیچ کانفیگ کاری پیدا نشد');
      return false;
    } catch (e) {
      log('❌ خطا در testAndConnectToFirstWorkingConfig: $e');
      return false;
    }
  }

  // Get V2Ray logs (Android only)
  Future<List<String>> getLogs() async {
    try {
      // return await _v2ray!.getLogs();
      return [];
    } catch (e) {
      log('Failed to get logs: $e');
      return [];
    }
  }

  // Clear V2Ray logs (Android only)
  Future<bool> clearLogs() async {
    try {
      // return await _v2ray!.clearLogs();
      return true;
    } catch (e) {
      log('Failed to clear logs: $e');
      return false;
    }
  }

  // Manual ping refresh - can be called by UI
  Future<void> refreshPing() async {
    log('refreshPing called - current status: ${state.status}');

    if (state.status != V2RayConnectionStatus.connected) {
      log('Cannot refresh ping - not connected');
      return;
    }

    try {
      log('Getting server delay...');
      final config = getStoredConfig();
      final parser = V2ray.parseFromURL(config);
      final ping =
          await _v2ray.getServerDelay(config: parser.getFullConfiguration());
      state = state.copyWith(ping: ping);
      log('Ping refreshed successfully: $ping ms');
    } catch (e) {
      log('Failed to refresh ping: $e');
    }
  }

  // Private method to refresh ping immediately after connection
  Future<void> _refreshPingAfterConnection() async {
    log('_refreshPingAfterConnection called, waiting 500ms...');
    // Wait a bit for connection to stabilize

    await Future.delayed(const Duration(milliseconds: 500));

    await refreshPing();

    // Detect country from new IP
    await _detectCountry();

    isPingRefreshed = true;
  }

  // Detect country from current IP address
  Future<void> _detectCountry() async {
    try {
      log('Detecting country from IP...');
      final countryCode =
          await IpLocationService.getCountryCode(connectedServerIP);
      log('Country detected: $countryCode');
      state = state.copyWith(serverCountry: countryCode);
    } catch (e) {
      log('Failed to detect country: $e');
      state = state.copyWith(serverCountry: 'xx');
    }
  }

  // Start timers for ping and duration updates
  void _startTimers() {
    _stopTimers(); // Stop any existing timers

    // Duration timer - update every second
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == V2RayConnectionStatus.connected &&
          _connectionStartTime != null) {
        final duration = DateTime.now().difference(_connectionStartTime!);
        state = state.copyWith(duration: _formatDuration(duration));
      }
    });
  }

  // Stop timers
  void _stopTimers() {
    _pingTimer?.cancel();
    _durationTimer?.cancel();
    _pingTimer = null;
    _durationTimer = null;
    _connectionStartTime = null;
  }

  // Format speed from bytes/sec to human readable
  String _formatSpeed(int? bytesPerSecond) {
    if (bytesPerSecond == null || bytesPerSecond == 0) return "0 B/s";

    const suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var size = bytesPerSecond.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  // Format duration to human readable
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Extract server country from remark
  String _extractServerCountry(String remark) {
    // Simple extraction - you can make this more sophisticated
    final lowerRemark = remark.toLowerCase();

    if (lowerRemark.contains('us') || lowerRemark.contains('america'))
      return 'US';
    if (lowerRemark.contains('uk') || lowerRemark.contains('britain'))
      return 'UK';
    if (lowerRemark.contains('de') || lowerRemark.contains('germany'))
      return 'DE';
    if (lowerRemark.contains('fr') || lowerRemark.contains('france'))
      return 'FR';
    if (lowerRemark.contains('jp') || lowerRemark.contains('japan'))
      return 'JP';
    if (lowerRemark.contains('sg') || lowerRemark.contains('singapore'))
      return 'SG';
    if (lowerRemark.contains('nl') || lowerRemark.contains('netherlands'))
      return 'NL';
    if (lowerRemark.contains('ca') || lowerRemark.contains('canada'))
      return 'CA';

    return 'XX'; // Default flag
  }

  // Select a specific config by index or name and test it before connecting
  Future<bool> selectConfig(dynamic configIdentifier) async {
    try {
      int newIndex = -1;

      if (configIdentifier is int) {
        newIndex = configIdentifier;
      } else if (configIdentifier is VpnConfig) {
        newIndex = _availableConfigs
            .indexWhere((c) => c.config == configIdentifier.config);
      } else if (configIdentifier is String) {
        // Search by name or config string
        newIndex = _availableConfigs.indexWhere(
          (c) => c.name == configIdentifier || c.config == configIdentifier,
        );
      }

      if (newIndex >= 0 && newIndex < _availableConfigs.length) {
        final config = _availableConfigs[newIndex];

        log('🧪 تست ping قبل از انتخاب: ${config.name}');

        // Test ping before selecting
        try {
          final V2RayURL parser = V2ray.parseFromURL(config.config);
          final ping = await _v2ray.getServerDelay(
              config: parser.getFullConfiguration());

          if (ping > 0) {
            log('✅ Ping OK: ${config.name} - $ping ms');

            // اگر ping خوب بود، انتخاب کن
            _selectedConfigIndex = newIndex;
            await _prefs?.setInt(_kStorageKeySelectedServer, newIndex);
            await _prefs?.setString(_kStorageKeyConfig, config.config);

            log('✅ Config selected: ${config.name}');
            return true;
          } else {
            log('❌ Ping failed: ${config.name}');
            return false;
          }
        } catch (e) {
          log('❌ Ping error: $e');
          return false;
        }
      } else {
        log('❌ Config not found');
        return false;
      }
    } catch (e) {
      log('❌ Error selecting config: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}

// Riverpod Provider
final v2rayServiceProvider =
    StateNotifierProvider<V2RayService, V2RayConnectionState>((ref) {
  return V2RayService();
});

// Helper providers for specific states
final v2rayStatusProvider = Provider<V2RayConnectionStatus>((ref) {
  return ref.watch(v2rayServiceProvider).status;
});

final v2rayPingProvider = Provider<int?>((ref) {
  return ref.watch(v2rayServiceProvider).ping;
});

final v2raySpeedProvider =
    Provider<({String? upload, String? download})>((ref) {
  final state = ref.watch(v2rayServiceProvider);
  return (upload: state.uploadSpeed, download: state.downloadSpeed);
});

final v2rayDurationProvider = Provider<String?>((ref) {
  return ref.watch(v2rayServiceProvider).duration;
});

final v2rayErrorProvider = Provider<String?>((ref) {
  return ref.watch(v2rayServiceProvider).errorMessage;
});

// New providers for server management
final availableServersProvider = Provider<List<VpnConfig>>((ref) {
  final service = ref.watch(v2rayServiceProvider.notifier);
  return service.getAvailableConfigs();
});

final selectedServerIndexProvider = Provider<int>((ref) {
  final service = ref.watch(v2rayServiceProvider.notifier);
  return service.getSelectedConfigIndex();
});

final selectedServerProvider = Provider<VpnConfig?>((ref) {
  final service = ref.watch(v2rayServiceProvider.notifier);
  return service.getSelectedConfig();
});
