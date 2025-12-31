import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class IpLocationService {
  static const String _ipApiUrl = 'http://ip-api.com/json/';
  static const String _ipifyUrl = 'https://api.ipify.org?format=json';

  // List of supported country flags
  static const List<String> _allowedCountries = [
    'at',
    'au',
    'az',
    'be',
    'ca',
    'ch',
    'cz',
    'de',
    'dk',
    'ee',
    'es',
    'fi',
    'fr',
    'gb',
    'hr',
    'hu',
    'in',
    'ir',
    'it',
    'jp',
    'lv',
    'nl',
    'no',
    'pl',
    'pt',
    'ro',
    'rs',
    'se',
    'sg',
    'sk',
    'tr'
  ];

  /// Get current public IP address
  static Future<String?> getCurrentIp() async {
    try {
      final response = await http
          .get(
            Uri.parse(_ipifyUrl),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] as String?;
      }
    } catch (e) {
      log('Error getting current IP: $e');
    }
    return null;
  }

  /// Get country code from IP address
  static Future<String> getCountryFromIp(String? ip) async {
    if (ip == null || ip.isEmpty) {
      log('No IP provided, using default flag');
      return 'xx';
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_ipApiUrl$ip'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final countryCode = (data['countryCode'] as String?)?.toLowerCase();
          log('Detected country: $countryCode for IP: $ip');

          if (countryCode != null && _allowedCountries.contains(countryCode)) {
            return countryCode;
          }
        } else {
          log('IP API returned error: ${data['message']}');
        }
      }
    } catch (e) {
      log('Error getting country from IP: $e');
    }

    return 'xx'; // Default flag
  }

  /// Get country code directly (without needing IP first)
  static Future<String> getCountryCode(String ip) async {
    try {
      // Use ip-api.com without specifying IP to get current connection's country
      print(_ipApiUrl + ip);
      final response = await http.get(
        Uri.parse('$_ipApiUrl$ip'),
      );
      ;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final countryCode = (data['countryCode'] as String?)?.toLowerCase();
          final ip = data['query'] as String?;
          log('Detected country: $countryCode, IP: $ip');

          if (countryCode != null && _allowedCountries.contains(countryCode)) {
            return countryCode;
          }
        }
      }
    } catch (e) {
      log('Error getting country code: $e');
    }

    return 'xx';
  }

  /// Check if country code is supported
  static bool isCountrySupported(String countryCode) {
    return _allowedCountries.contains(countryCode.toLowerCase());
  }
}
