// lib/models/npc_talent.dart

class NpcTalent {
  final String id;
  final String name;
  final String description;
  final String effectType;
  final double effectValue;
  final String rarity;

  const NpcTalent({
    required this.id,
    required this.name,
    required this.description,
    required this.effectType,
    required this.effectValue,
    required this.rarity,
  });

  factory NpcTalent.fromJson(Map<String, dynamic> json) {
    return NpcTalent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      effectType: json['effect_type'] as String,
      effectValue: (json['effect_value'] as num).toDouble(),
      rarity: json['rarity'] as String,
    );
  }
}