// lib/models/player_npc.dart

import 'npc.dart';
import 'player_npc_gear.dart';
import 'player_npc_talent.dart';

class PlayerNpc {
  final String id;
  final String playerId;
  final String npcId;
  final int level;
  final int xp;
  final int skill;
  final int hp;
  final int maxHp;
  final int heat;
  final String status;
  final DateTime? busyUntil;
  final DateTime? jailedUntil;
  final String? jailReason;
  final int buyoutCost;
  final String buyoutCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Core-Fundament
  final String quality;
  final int qualityShards;
  final int morale;
  final int stamina;
  final int maxStamina;
  final DateTime? lastStaminaRegen;
  final DateTime? injuredUntil;
  final DateTime? traumatizedUntil;
  final int gearSlots;
  final int talentSlots;

  // Joint-Daten
  final Npc? definition;
  final List<PlayerNpcGear> gear;
  final List<PlayerNpcTalent> talents;

  const PlayerNpc({
    required this.id,
    required this.playerId,
    required this.npcId,
    required this.level,
    required this.xp,
    required this.skill,
    required this.hp,
    required this.maxHp,
    required this.heat,
    required this.status,
    this.busyUntil,
    this.jailedUntil,
    this.jailReason,
    required this.buyoutCost,
    required this.buyoutCurrency,
    required this.createdAt,
    required this.updatedAt,
    required this.quality,
    required this.qualityShards,
    required this.morale,
    required this.stamina,
    required this.maxStamina,
    this.lastStaminaRegen,
    this.injuredUntil,
    this.traumatizedUntil,
    required this.gearSlots,
    required this.talentSlots,
    this.definition,
    this.gear = const [],
    this.talents = const [],
  });

  factory PlayerNpc.fromJson(Map<String, dynamic> json) {
    final gearRaw = json['player_npc_gear'] as List? ?? [];
    final talentsRaw = json['player_npc_talents'] as List? ?? [];

    return PlayerNpc(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      npcId: json['npc_id'] as String,
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      skill: (json['skill'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
      maxHp: (json['max_hp'] as num).toInt(),
      heat: (json['heat'] as num).toInt(),
      status: json['status'] as String,
      busyUntil: json['busy_until'] != null
          ? DateTime.parse(json['busy_until'] as String)
          : null,
      jailedUntil: json['jailed_until'] != null
          ? DateTime.parse(json['jailed_until'] as String)
          : null,
      jailReason: json['jail_reason'] as String?,
      buyoutCost: (json['buyout_cost'] as num).toInt(),
      buyoutCurrency: json['buyout_currency'] as String? ?? 'cash',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      quality: json['quality'] as String? ?? 'common',
      qualityShards: (json['quality_shards'] as num?)?.toInt() ?? 0,
      morale: (json['morale'] as num?)?.toInt() ?? 100,
      stamina: (json['stamina'] as num?)?.toInt() ?? 100,
      maxStamina: (json['max_stamina'] as num?)?.toInt() ?? 100,
      lastStaminaRegen: json['last_stamina_regen'] != null
          ? DateTime.parse(json['last_stamina_regen'] as String)
          : null,
      injuredUntil: json['injured_until'] != null
          ? DateTime.parse(json['injured_until'] as String)
          : null,
      traumatizedUntil: json['traumatized_until'] != null
          ? DateTime.parse(json['traumatized_until'] as String)
          : null,
      gearSlots: (json['gear_slots'] as num?)?.toInt() ?? 1,
      talentSlots: (json['talent_slots'] as num?)?.toInt() ?? 1,
      definition: json['npcs'] != null
          ? Npc.fromJson(json['npcs'] as Map<String, dynamic>)
          : null,
      gear: gearRaw
          .map((e) => PlayerNpcGear.fromJson(e as Map<String, dynamic>))
          .toList(),
      talents: talentsRaw
          .map((e) => PlayerNpcTalent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ============================================================
  // GETTER
  // ============================================================

  bool get isIdle => status == 'idle';
  bool get isBusy => status == 'busy';
  bool get isJailed => status == 'jailed';
  bool get isInjured =>
      injuredUntil != null && injuredUntil!.isAfter(DateTime.now());
  bool get isTraumatized =>
      traumatizedUntil != null && traumatizedUntil!.isAfter(DateTime.now());

  /// Erschöpft = Stamina reicht nicht für einen Raub (Kosten: 20)
  bool get isExhausted => currentStamina < 20;

  /// Voll ausgeruht
  bool get isFullyRested => currentStamina >= maxStamina;

  /// Clientseitig berechnete aktuelle Stamina (Server bleibt Source of Truth).
  /// +2 pro voller Minute seit letztem Regen, gedeckelt bei maxStamina.
  /// Wird nur für flüssige UI genutzt – echte Werte kommen vom RPC.
  int get currentStamina {
    if (lastStaminaRegen == null) return stamina;
    if (stamina >= maxStamina) return maxStamina;

    final elapsed = DateTime.now().difference(lastStaminaRegen!).inMinutes;
    if (elapsed <= 0) return stamina;

    final regenerated = stamina + (elapsed * 2);
    return regenerated.clamp(0, maxStamina);
  }

  /// Verbleibende Minuten bis voller Regeneration (clientseitige Schätzung)
  int get minutesUntilFull {
    final current = currentStamina;
    if (current >= maxStamina) return 0;
    final missing = maxStamina - current;
    return (missing / 2).ceil();
  }

  /// Für Progress-Bar: 0.0 bis 1.0
  double get staminaRatio {
    if (maxStamina <= 0) return 0.0;
    return (currentStamina / maxStamina).clamp(0.0, 1.0);
  }

  String get qualityLabel {
    switch (quality) {
      case 'common': return 'Gewöhnlich';
      case 'rare': return 'Selten';
      case 'epic': return 'Episch';
      case 'legendary': return 'Legendär';
      case 'mythic': return 'Mythisch';
      default: return quality;
    }
  }

  double get qualityMultiplier {
    switch (quality) {
      case 'common': return 1.0;
      case 'rare': return 1.2;
      case 'epic': return 1.4;
      case 'legendary': return 1.6;
      case 'mythic': return 2.0;
      default: return 1.0;
    }
  }

  // Gesamt-Ausrüstungs-Bonus
  double get totalGearLootBonus => gear
      .where((g) => g.equipped && g.gear != null)
      .fold(0.0, (sum, g) => sum + g.gear!.lootBonus);
  double get totalGearSuccessBonus => gear
      .where((g) => g.equipped && g.gear != null)
      .fold(0.0, (sum, g) => sum + g.gear!.successBonus);
  double get totalGearStealthBonus => gear
      .where((g) => g.equipped && g.gear != null)
      .fold(0.0, (sum, g) => sum + g.gear!.stealthBonus);
  int get totalGearSpeedBonus => gear
      .where((g) => g.equipped && g.gear != null)
      .fold(0, (sum, g) => sum + g.gear!.speedBonus);

  // Effektive Werte
  int get effectiveSkill => (skill * qualityMultiplier).round();
  int get effectiveMaxHp => (maxHp * qualityMultiplier).round();

  /// Kopie mit neuen Server-Werten (für Regen-Refresh)
  PlayerNpc copyWithStamina({
    required int stamina,
    required int maxStamina,
    DateTime? lastStaminaRegen,
  }) {
    return PlayerNpc(
      id: id,
      playerId: playerId,
      npcId: npcId,
      level: level,
      xp: xp,
      skill: skill,
      hp: hp,
      maxHp: maxHp,
      heat: heat,
      status: status,
      busyUntil: busyUntil,
      jailedUntil: jailedUntil,
      jailReason: jailReason,
      buyoutCost: buyoutCost,
      buyoutCurrency: buyoutCurrency,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      quality: quality,
      qualityShards: qualityShards,
      morale: morale,
      stamina: stamina,
      maxStamina: maxStamina,
      lastStaminaRegen: lastStaminaRegen ?? this.lastStaminaRegen,
      injuredUntil: injuredUntil,
      traumatizedUntil: traumatizedUntil,
      gearSlots: gearSlots,
      talentSlots: talentSlots,
      definition: definition,
      gear: gear,
      talents: talents,
    );
  }
}