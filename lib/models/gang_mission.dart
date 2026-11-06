// lib/models/gang_mission.dart
class GangMission {
  final String id;
  final String gangId;
  final String missionCode;
  final String name;
  final String description;
  final int requiredContributions;
  final int currentContributions;
  final int expReward;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const GangMission({
    required this.id,
    required this.gangId,
    required this.missionCode,
    required this.name,
    required this.description,
    required this.requiredContributions,
    required this.currentContributions,
    required this.expReward,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  double get progress => requiredContributions == 0
      ? 0
      : currentContributions / requiredContributions;

  factory GangMission.fromJson(Map<String, dynamic> json) => GangMission(
    id: json['id'] as String,
    gangId: json['gang_id'] as String,
    missionCode: json['mission_code'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    requiredContributions: json['required_contributions'] as int,
    currentContributions: json['current_contributions'] as int,
    expReward: json['exp_reward'] as int,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    expiresAt: DateTime.parse(json['expires_at'] as String),
  );
}
