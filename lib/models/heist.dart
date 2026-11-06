// lib/models/heist.dart

class Heist {
  final String id;
  final String name;
  final String? description;
  final String? districtId;
  final int minLevel;
  final int energyCost;
  final double baseSuccess;
  final int baseHeat;
  final int jailSeconds;
  final Map<String, dynamic> lootTable;
  final String icon;
  final bool isActive;
  final String? requiredRole;
  final int durationSeconds;
  final double jailChanceFail;
  final int cashMin;
  final int cashMax;

  const Heist({
    required this.id,
    required this.name,
    this.description,
    this.districtId,
    required this.minLevel,
    required this.energyCost,
    required this.baseSuccess,
    required this.baseHeat,
    required this.jailSeconds,
    required this.lootTable,
    required this.icon,
    required this.isActive,
    this.requiredRole,
    required this.durationSeconds,
    required this.jailChanceFail,
    required this.cashMin,
    required this.cashMax,
  });

  factory Heist.fromJson(Map<String, dynamic> json) {
    return Heist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      districtId: json['district_id'] as String?,
      minLevel: (json['min_level'] as num).toInt(),
      energyCost: (json['energy_cost'] as num).toInt(),
      baseSuccess: (json['base_success'] as num).toDouble(),
      baseHeat: (json['base_heat'] as num).toInt(),
      jailSeconds: (json['jail_seconds'] as num).toInt(),
      lootTable: json['loot_table'] as Map<String, dynamic>? ?? {},
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
      requiredRole: json['required_role'] as String?,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      jailChanceFail: (json['jail_chance_fail'] as num).toDouble(),
      cashMin: (json['cash_min'] as num).toInt(),
      cashMax: (json['cash_max'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'district_id': districtId,
    'min_level': minLevel,
    'energy_cost': energyCost,
    'base_success': baseSuccess,
    'base_heat': baseHeat,
    'jail_seconds': jailSeconds,
    'loot_table': lootTable,
    'icon': icon,
    'is_active': isActive,
    'required_role': requiredRole,
    'duration_seconds': durationSeconds,
    'jail_chance_fail': jailChanceFail,
    'cash_min': cashMin,
    'cash_max': cashMax,
  };

  String get requiredRoleLabel {
    if (requiredRole == null) return 'Keine';
    switch (requiredRole!) {
      case 'driver':
        return 'Fahrer';
      case 'muscle':
        return 'Schläger';
      case 'hacker':
        return 'Hacker';
      case 'lookout':
        return 'Späher';
      default:
        return requiredRole!;
    }
  }

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}min';
    return '${m}min ${s}s';
  }

  String get cashRangeLabel {
    return '${_formatNumber(cashMin)} - ${_formatNumber(cashMax)} \$';
  }

  /// Drops aus loot_table
  List<HeistDrop> get drops {
    final raw = lootTable['drops'];
    if (raw is! List) return [];
    return raw
        .map((e) => HeistDrop.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class HeistDrop {
  final String itemName;
  final int min;
  final int max;
  final double chance;

  const HeistDrop({
    required this.itemName,
    required this.min,
    required this.max,
    required this.chance,
  });

  factory HeistDrop.fromJson(Map<String, dynamic> json) {
    return HeistDrop(
      itemName: json['item_name'] as String,
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
      chance: (json['chance'] as num).toDouble(),
    );
  }

  String get chanceLabel => '${(chance * 100).toStringAsFixed(0)}%';
}