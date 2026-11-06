import 'dart:math' as math;

import 'attribute_type.dart';
import 'character_class.dart';

const int kMaxEnergy = 100;

class PlayerProfile {
  final String id;
  final String username;
  final int level;
  final int health;
  final int maxHealth;
  final int currentXp;
  final int money;
  final int energy;
  final List<dynamic> inventory;
  final String? gangId;
  final String? gangRole;

  final CharacterClass? characterClass;
  final int strength;
  final int dexterity;
  final int endurance;
  final int charisma;
  final int spentPoints;

  // NEU: Talent-System
  final int talentPoints;
  final int crimCoins;
  final bool hasUsedFreeRespec;

  // NEU: HUD-Daten
  final int respect;
  final String? gangName;
  final String? equippedWeapon;
  final String? equippedArmor;

  const PlayerProfile({
    required this.id,
    required this.username,
    required this.level,
    required this.currentXp,
    required this.money,
    required this.energy,
    required this.inventory,
    this.gangId,
    this.gangRole,
    this.characterClass,
    this.strength = 1,
    this.dexterity = 1,
    this.endurance = 1,
    this.charisma = 1,
    this.spentPoints = 0,
    this.health = 100,
    this.maxHealth = 100,
    this.talentPoints = 0,
    this.crimCoins = 0,
    this.hasUsedFreeRespec = false,
    this.respect = 0,
    this.gangName,
    this.equippedWeapon,
    this.equippedArmor,
  });

  int get totalPointsEarned => (level - 1).clamp(0, 1 << 30);
  int get availablePoints => totalPointsEarned - spentPoints;

  int get xpNext {
    final safeLevel = level <= 0 ? 1 : level;
    final v = 100 * safeLevel * math.sqrt(safeLevel);
    return v.round().clamp(1, 1 << 30);
  }

  int get xpProgress => currentXp.clamp(0, xpNext);
  double get xpPercent => xpNext == 0 ? 0.0 : (xpProgress / xpNext).clamp(0.0, 1.0);

  int get energyMax => kMaxEnergy;
  bool get isLowEnergy => energy <= (energyMax * 0.2).round();

  int attributeValue(AttributeType t) => switch (t) {
    AttributeType.strength => strength,
    AttributeType.dexterity => dexterity,
    AttributeType.endurance => endurance,
    AttributeType.charisma => charisma,
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> j) => PlayerProfile(
    id: j['id'] as String,
    username: (j['username'] ?? 'Unbekannt') as String,
    level: (j['level'] ?? 1) as int,
    currentXp: (j['current_xp'] ?? 0) as int,
    money: (j['money'] ?? 0) as int,
    energy: (j['energy'] ?? 0) as int,
    inventory: (j['inventory'] ?? []) as List<dynamic>,
    gangId: j['gang_id'] as String?,
    gangRole: j['gang_role'] as String?,
    characterClass: CharacterClass.fromDb(j['class'] as String?),
    strength: (j['strength'] ?? 1) as int,
    dexterity: (j['dexterity'] ?? 1) as int,
    endurance: (j['endurance'] ?? 1) as int,
    charisma: (j['charisma'] ?? 1) as int,
    spentPoints: (j['spent_points'] ?? 0) as int,
    health: (j['health'] ?? 100) as int,
    maxHealth: (j['max_health'] ?? 100) as int,

    // NEU: Talent-System (Fallbacks, falls Spalten noch nicht existieren)
    talentPoints: (j['talent_points'] ?? 0) as int,
    crimCoins: (j['crim_coins'] ?? 0) as int,
    hasUsedFreeRespec: (j['has_used_free_respec'] ?? false) as bool,

    respect: (j['respect'] ?? 0) as int,
    gangName: j['gang_name'] as String?,
    equippedWeapon: j['equipped_weapon'] as String?,
    equippedArmor: j['equipped_armor'] as String?,
  );

  PlayerProfile copyWith({
    CharacterClass? characterClass,
    int? strength,
    int? dexterity,
    int? endurance,
    int? charisma,
    int? spentPoints,
    int? health,
    int? maxHealth,
    int? talentPoints,
    int? crimCoins,
    bool? hasUsedFreeRespec,
    int? respect,
    String? gangName,
    String? equippedWeapon,
    String? equippedArmor,
  }) => PlayerProfile(
    id: id,
    username: username,
    level: level,
    currentXp: currentXp,
    money: money,
    energy: energy,
    inventory: inventory,
    gangId: gangId,
    gangRole: gangRole,
    characterClass: characterClass ?? this.characterClass,
    strength: strength ?? this.strength,
    dexterity: dexterity ?? this.dexterity,
    endurance: endurance ?? this.endurance,
    charisma: charisma ?? this.charisma,
    spentPoints: spentPoints ?? this.spentPoints,
    health: health ?? this.health,
    maxHealth: maxHealth ?? this.maxHealth,
    talentPoints: talentPoints ?? this.talentPoints,
    crimCoins: crimCoins ?? this.crimCoins,
    hasUsedFreeRespec: hasUsedFreeRespec ?? this.hasUsedFreeRespec,
    respect: respect ?? this.respect,
    gangName: gangName ?? this.gangName,
    equippedWeapon: equippedWeapon ?? this.equippedWeapon,
    equippedArmor: equippedArmor ?? this.equippedArmor,
  );
}