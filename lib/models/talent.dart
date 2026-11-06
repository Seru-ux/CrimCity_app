// lib/models/talent.dart

class Talent {
  final String id;
  final String name;
  final String description;
  final int tier;
  final int maxLevel;
  final String effectType;
  final double effectPerLevel;
  final bool isCross;
  final bool isHybrid;
  final int reqStrength;
  final int reqDexterity;
  final int reqEndurance;
  final int reqCharisma;
  final String? requiresTalent1;
  final int requiresLevel1;
  final String? requiresTalent2;
  final int requiresLevel2;
  final int sortOrder;
  final int playerLevel;
  final bool isUnlocked;

  const Talent({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.maxLevel,
    required this.effectType,
    required this.effectPerLevel,
    required this.isCross,
    required this.isHybrid,
    required this.reqStrength,
    required this.reqDexterity,
    required this.reqEndurance,
    required this.reqCharisma,
    required this.requiresTalent1,
    required this.requiresLevel1,
    required this.requiresTalent2,
    required this.requiresLevel2,
    required this.sortOrder,
    required this.playerLevel,
    required this.isUnlocked,
  });

  factory Talent.fromJson(Map<String, dynamic> json) {
    return Talent(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      maxLevel: (json['max_level'] as num?)?.toInt() ?? 1,
      effectType: json['effect_type'] as String? ?? '',
      effectPerLevel: (json['effect_per_level'] as num?)?.toDouble() ?? 0,
      isCross: json['is_cross'] as bool? ?? false,
      isHybrid: json['is_hybrid'] as bool? ?? false,
      reqStrength: (json['req_strength'] as num?)?.toInt() ?? 0,
      reqDexterity: (json['req_dexterity'] as num?)?.toInt() ?? 0,
      reqEndurance: (json['req_endurance'] as num?)?.toInt() ?? 0,
      reqCharisma: (json['req_charisma'] as num?)?.toInt() ?? 0,
      requiresTalent1: json['requires_talent_1'] as String?,
      requiresLevel1: (json['requires_level_1'] as num?)?.toInt() ?? 0,
      requiresTalent2: json['requires_talent_2'] as String?,
      requiresLevel2: (json['requires_level_2'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      playerLevel: (json['player_level'] as num?)?.toInt() ?? 0,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
    );
  }

  bool get isMaxed => playerLevel >= maxLevel;
  bool get isStarted => playerLevel > 0;

  double get currentBonus => effectPerLevel * playerLevel;
  double get nextBonus => effectPerLevel * (playerLevel + 1);

  String get effectLabel {
    switch (effectType) {
      case 'sell_price_mult': return 'Verkaufspreis';
      case 'buy_price_mult': return 'Einkaufspreis';
      case 'heist_loot_mult': return 'Raub-Beute';
      case 'heist_success_bonus': return 'Raub-Erfolg';
      case 'heist_speed_bonus': return 'Flucht-Speed';
      case 'energy_regen_mult': return 'Energie-Regeneration';
      case 'max_health_bonus': return 'Max-HP';
      case 'inventory_bonus': return 'Inventar-Slots';
      case 'jail_time_reduction': return 'Haftzeit-Reduktion';
      case 'heat_mult': return 'Hitze';
      case 'crit_chance_bonus': return 'Krit-Chance';
      case 'docs_sell_bonus': return 'Docs-Verkauf';
      case 'auction_fee_reduction': return 'Auktionsgebühr';
      default: return effectType;
    }
  }
}