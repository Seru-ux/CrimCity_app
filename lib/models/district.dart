// lib/models/district.dart
class District {
  final String id;
  final String name;
  final String description;
  final String? gangId; // NULL = Neutral
  final int incomeMoney;
  final int incomeInfluence;
  final int requiredInfluence;
  final DateTime lastCollectedAt;

  const District({
    required this.id,
    required this.name,
    required this.description,
    this.gangId,
    required this.incomeMoney,
    required this.incomeInfluence,
    required this.requiredInfluence,
    required this.lastCollectedAt,
  });

  bool get isNeutral => gangId == null;

  factory District.fromJson(Map<String, dynamic> json) => District(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    gangId: json['gang_id'] as String?,
    incomeMoney: json['income_money'] as int,
    incomeInfluence: json['income_influence'] as int,
    requiredInfluence: json['required_influence'] as int,
    lastCollectedAt: DateTime.parse(json['last_collected_at'] as String),
  );
}
