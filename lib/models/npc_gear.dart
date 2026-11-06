// lib/models/npc_gear.dart

class NpcGear {
  final String id;
  final String name;
  final String? description;
  final String slot;         // 'weapon' | 'armor' | 'gadget' | 'vehicle_upgrade'
  final String rarity;       // 'common' | 'rare' | 'epic' | 'legendary' | 'mythic'
  final double lootBonus;
  final double successBonus;
  final double stealthBonus;
  final int speedBonus;
  final double jailRiskMod;
  final double heatMod;
  final double successMalus;
  final int priceCash;
  final int priceCoins;
  final String icon;

  const NpcGear({
    required this.id,
    required this.name,
    this.description,
    required this.slot,
    required this.rarity,
    required this.lootBonus,
    required this.successBonus,
    required this.stealthBonus,
    required this.speedBonus,
    required this.jailRiskMod,
    required this.heatMod,
    required this.successMalus,
    required this.priceCash,
    required this.priceCoins,
    required this.icon,
  });

  factory NpcGear.fromJson(Map<String, dynamic> json) {
    return NpcGear(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      slot: json['slot'] as String,
      rarity: json['rarity'] as String,
      lootBonus: (json['loot_bonus'] as num?)?.toDouble() ?? 0,
      successBonus: (json['success_bonus'] as num?)?.toDouble() ?? 0,
      stealthBonus: (json['stealth_bonus'] as num?)?.toDouble() ?? 0,
      speedBonus: (json['speed_bonus'] as num?)?.toInt() ?? 0,
      jailRiskMod: (json['jail_risk_mod'] as num?)?.toDouble() ?? 0,
      heatMod: (json['heat_mod'] as num?)?.toDouble() ?? 0,
      successMalus: (json['success_malus'] as num?)?.toDouble() ?? 0,
      priceCash: (json['price_cash'] as num?)?.toInt() ?? 0,
      priceCoins: (json['price_coins'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String? ?? 'build',
    );
  }

  String get slotLabel {
    switch (slot) {
      case 'weapon':
        return 'Waffe';
      case 'armor':
        return 'Rüstung';
      case 'gadget':
        return 'Gadget';
      case 'vehicle_upgrade':
        return 'Fahrzeug';
      default:
        return slot;
    }
  }
}