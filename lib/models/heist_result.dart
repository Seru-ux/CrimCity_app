// lib/models/heist_result.dart

class HeistResult {
  final bool success;
  final int cash;
  final Map<String, int> loot;
  final bool crit;
  final bool jailed;
  final int jailSeconds;
  final double successChance;

  const HeistResult({
    required this.success,
    required this.cash,
    required this.loot,
    required this.crit,
    required this.jailed,
    required this.jailSeconds,
    required this.successChance,
  });

  factory HeistResult.fromJson(Map<String, dynamic> json) {
    final lootRaw = json['loot'] as Map<String, dynamic>? ?? {};
    return HeistResult(
      success: json['success'] as bool? ?? false,
      cash: (json['cash'] as num?)?.toInt() ?? 0,
      loot: lootRaw.map((k, v) => MapEntry(k, (v as num).toInt())),
      crit: json['crit'] as bool? ?? false,
      jailed: json['jailed'] as bool? ?? false,
      jailSeconds: (json['jail_seconds'] as num?)?.toInt() ?? 0,
      successChance: (json['success_chance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get successChanceLabel =>
      '${(successChance * 100).toStringAsFixed(0)}%';
}