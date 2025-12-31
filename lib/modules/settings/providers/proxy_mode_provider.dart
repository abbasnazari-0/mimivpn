import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProxyModeType {
  vpnMode,
  proxyOnly,
  split,
}

class ProxyModeNotifier extends StateNotifier<ProxyModeType> {
  static const String _storageKey = 'proxy_mode';
  final SharedPreferences? _prefs;

  ProxyModeNotifier(this._prefs) : super(ProxyModeType.vpnMode) {
    _loadProxyMode();
  }

  Future<void> _loadProxyMode() async {
    if (_prefs == null) return;

    final stored = _prefs!.getString(_storageKey);
    if (stored != null) {
      switch (stored) {
        case 'vpnMode':
          state = ProxyModeType.vpnMode;
          break;
        case 'proxyOnly':
          state = ProxyModeType.proxyOnly;
          break;
        case 'split':
          state = ProxyModeType.split;
          break;
      }
    }
  }

  Future<void> _saveProxyMode() async {
    if (_prefs == null) return;

    String modeString;
    switch (state) {
      case ProxyModeType.vpnMode:
        modeString = 'vpnMode';
        break;
      case ProxyModeType.proxyOnly:
        modeString = 'proxyOnly';
        break;
      case ProxyModeType.split:
        modeString = 'split';
        break;
    }

    await _prefs!.setString(_storageKey, modeString);
  }

  void setProxyMode(ProxyModeType mode) {
    state = mode;
    _saveProxyMode();
  }

  String getProxyModeString() {
    switch (state) {
      case ProxyModeType.vpnMode:
        return 'VPN Mode';
      case ProxyModeType.proxyOnly:
        return 'Proxy Only';
      case ProxyModeType.split:
        return 'Split Tunneling';
    }
  }
}

final proxyModeProvider =
    StateNotifierProvider<ProxyModeNotifier, ProxyModeType>((ref) {
  return ProxyModeNotifier(null);
});

// Provider برای initialize کردن با SharedPreferences
final proxyModeProviderWithPrefs =
    FutureProvider<ProxyModeNotifier>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ProxyModeNotifier(prefs);
});
