class VpnConfig {
  final String name;
  final String config;
  final String country;
  final String flag;
  final bool premium;
  final int? ping;

  const VpnConfig({
    required this.name,
    required this.config,
    required this.country,
    required this.flag,
    this.premium = false,
    this.ping,
  });

  VpnConfig copyWith({
    String? name,
    String? config,
    String? country,
    String? flag,
    bool? premium,
    int? ping,
  }) {
    return VpnConfig(
      name: name ?? this.name,
      config: config ?? this.config,
      country: country ?? this.country,
      flag: flag ?? this.flag,
      premium: premium ?? this.premium,
      ping: ping ?? this.ping,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'config': config,
      'country': country,
      'flag': flag,
      'premium': premium,
      'ping': ping,
    };
  }

  factory VpnConfig.fromMap(Map<String, dynamic> map) {
    return VpnConfig(
      name: map['name'] ?? '',
      config: map['config'] ?? '',
      country: map['country'] ?? '',
      flag: map['flag'] ?? '',
      premium: map['premium'] ?? false,
      ping: map['ping']?.toInt(),
    );
  }

  @override
  String toString() {
    return 'VpnConfig(name: $name, country: $country, flag: $flag, premium: $premium, ping: $ping)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VpnConfig &&
        other.name == name &&
        other.config == config &&
        other.country == country &&
        other.flag == flag &&
        other.premium == premium &&
        other.ping == ping;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        config.hashCode ^
        country.hashCode ^
        flag.hashCode ^
        premium.hashCode ^
        ping.hashCode;
  }
}
