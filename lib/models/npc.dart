// lib/models/npc.dart

class Npc {
  final String id;
  final String name;
  final String role;
  final String? description;
  final int baseSkill;
  final int baseHp;
  final int hireCost;
  final String hireCurrency;
  final String rarity;
  final String icon;
  final bool isActive;

  const Npc({
    required this.id,
    required this.name,
    required this.role,
    this.description,
    required this.baseSkill,
    required this.baseHp,
    required this.hireCost,
    required this.hireCurrency,
    required this.rarity,
    required this.icon,
    required this.isActive,
  });

  factory Npc.fromJson(Map<String, dynamic> json) {
    return Npc(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      description: json['description'] as String?,
      baseSkill: (json['base_skill'] as num).toInt(),
      baseHp: (json['base_hp'] as num).toInt(),
      hireCost: (json['hire_cost'] as num).toInt(),
      hireCurrency: json['hire_currency'] as String,
      rarity: json['rarity'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'description': description,
    'base_skill': baseSkill,
    'base_hp': baseHp,
    'hire_cost': hireCost,
    'hire_currency': hireCurrency,
    'rarity': rarity,
    'icon': icon,
    'is_active': isActive,
  };

  /// Rolle auf Deutsch
  String get roleLabel {
    switch (role) {
      case 'driver':
        return 'Fahrer';
      case 'muscle':
        return 'Schläger';
      case 'hacker':
        return 'Hacker';
      case 'lookout':
        return 'Späher';
      default:
        return role;
    }
  }

  /// Rarity auf Deutsch
  String get rarityLabel {
    switch (rarity) {
      case 'common':
        return 'Gewöhnlich';
      case 'rare':
        return 'Selten';
      case 'epic':
        return 'Episch';
      case 'legendary':
        return 'Legendär';
      default:
        return rarity;
    }
  }

  /// Hire-Cost formatiert
  String get formattedHireCost {
    if (hireCurrency == 'crimcoins') {
      return '$hireCost CrimCoins';
    }
    return '${_formatNumber(hireCost)} \$';
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