import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/v2ray_service.dart';

// V2Ray Controller for UI interactions
class V2RayController {
  final Ref ref;

  V2RayController(this.ref);

  // Get current connection state
  V2RayConnectionState get state => ref.read(v2rayServiceProvider);

  // Get service notifier
  V2RayService get _service => ref.read(v2rayServiceProvider.notifier);

  // Connect to VPN with default config
  Future<bool> connect() async {
    return await _service.connectWithDefaultConfig();
  }

  // Connect with stored config
  Future<bool> connectWithStoredConfig() async {
    return await _service.connectWithStoredConfig();
  }

  // تست کانفیگ‌ها و اتصال به اولین کانفیگی که پینگ داد
  Future<bool> testAndConnectToFirstWorkingConfig({
    Function(int current, int total, int? ping)? onProgress,
  }) async {
    return await _service.testAndConnectToFirstWorkingConfig(
      onProgress: onProgress,
    );
  }

  // Select a config
  Future<bool> selectConfig(dynamic configIdentifier) async {
    return await _service.selectConfig(configIdentifier);
  }

  // Connect with custom config
  Future<bool> connectWithConfig(String config) async {
    return await _service.connectWithConfig(config);
  }

  // Disconnect from VPN
  Future<bool> disconnect() async {
    return await _service.disconnect();
  }

  // Toggle connection
  Future<bool> toggle() async {
    return await _service.toggleConnection();
  }

  // Update config
  Future<void> updateConfig(String config) async {
    await _service.updateConfig(config);
  }

  // Get stored config
  String getStoredConfig() {
    return _service.getStoredConfig();
  }

  // Set auto-connect
  Future<void> setAutoConnect(bool enabled) async {
    await _service.setAutoConnect(enabled);
  }

  // Get auto-connect status
  bool getAutoConnect() {
    return _service.getAutoConnect();
  }

  // Get logs
  Future<List<String>> getLogs() async {
    return await _service.getLogs();
  }

  // Clear logs
  Future<bool> clearLogs() async {
    return await _service.clearLogs();
  }

  // Check if connected
  bool get isConnected => state.status == V2RayConnectionStatus.connected;

  // Check if connecting
  bool get isConnecting => state.status == V2RayConnectionStatus.connecting;

  // Check if disconnecting
  bool get isDisconnecting =>
      state.status == V2RayConnectionStatus.disconnecting;

  // Check if has error
  bool get hasError => state.status == V2RayConnectionStatus.error;

  // Get status text
  String get statusText {
    switch (state.status) {
      case V2RayConnectionStatus.connected:
        return 'Connected';
      case V2RayConnectionStatus.connecting:
        return 'Connecting...';
      case V2RayConnectionStatus.disconnected:
        return 'Disconnected';
      case V2RayConnectionStatus.disconnecting:
        return 'Disconnecting...';
      case V2RayConnectionStatus.error:
        return 'Error';
    }
  }

  // Get connection color
  String get connectionColor {
    switch (state.status) {
      case V2RayConnectionStatus.connected:
        return '#4CAF50'; // Green
      case V2RayConnectionStatus.connecting:
      case V2RayConnectionStatus.disconnecting:
        return '#FF9800'; // Orange
      case V2RayConnectionStatus.disconnected:
        return '#9E9E9E'; // Gray
      case V2RayConnectionStatus.error:
        return '#F44336'; // Red
    }
  }
}

// Provider for V2Ray Controller
final v2rayControllerProvider = Provider<V2RayController>((ref) {
  return V2RayController(ref);
});
