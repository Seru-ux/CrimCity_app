// lib/models/gang_member.dart
import 'gang.dart';
import 'player_profile.dart';

class GangMember {
  final String id;
  final String gangId;
  final String playerId;
  final GangRole role;
  final DateTime joinedAt;
  final PlayerProfile player;

  const GangMember({
    required this.id,
    required this.gangId,
    required this.playerId,
    required this.role,
    required this.joinedAt,
    required this.player,
  });

  factory GangMember.fromJson(Map<String, dynamic> json) => GangMember(
    id: json['id'] as String,
    gangId: json['gang_id'] as String,
    playerId: json['player_id'] as String,
    role: gangRoleFromString(json['role'] as String),
    joinedAt: DateTime.parse(json['joined_at'] as String),
    player: PlayerProfile.fromJson(json['profiles'] as Map<String, dynamic>),
  );
}
