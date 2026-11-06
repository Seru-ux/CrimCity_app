// lib/models/gang_invite.dart
class GangInvite {
  final String id;
  final String gangId;
  final String gangName;
  final String gangTag;
  final String inviterId;
  final String inviteeId;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const GangInvite({
    required this.id,
    required this.gangId,
    required this.gangName,
    required this.gangTag,
    required this.inviterId,
    required this.inviteeId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory GangInvite.fromJson(Map<String, dynamic> json) => GangInvite(
    id: json['id'] as String,
    gangId: json['gang_id'] as String,
    gangName: (json['gangs']?['name'] as String?) ?? '',
    gangTag: (json['gangs']?['tag'] as String?) ?? '',
    inviterId: json['inviter_id'] as String,
    inviteeId: json['invitee_id'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    expiresAt: DateTime.parse(json['expires_at'] as String),
  );
}
