// lib/models/gang.dart
// Datenmodell für eine Gang.

enum GangRole { leader, officer, member }

GangRole gangRoleFromString(String s) => switch (s) {
  'leader' => GangRole.leader,
  'officer' => GangRole.officer,
  _ => GangRole.member,
};

String gangRoleToString(GangRole r) => switch (r) {
  GangRole.leader => 'leader',
  GangRole.officer => 'officer',
  GangRole.member => 'member',
};

class Gang {
  final String id;
  final String name;
  final String tag;
  final String description;
  final String leaderId;
  final int level;
  final int xp;
  final int memberSlots;
  final bool isRecruiting;
  final DateTime createdAt;
  final int memberCount;
  final int influence;

  const Gang({
    required this.id,
    required this.name,
    required this.tag,
    required this.description,
    required this.leaderId,
    required this.level,
    required this.xp,
    required this.memberSlots,
    required this.isRecruiting,
    required this.createdAt,
    this.memberCount = 0,
    this.influence = 0,
  });

  bool get isFull => memberCount >= memberSlots;

  factory Gang.fromJson(Map<String, dynamic> json) {
    // Supabase liefert gang_members: [{count: N}] wenn mit .select('*, gang_members(count)')
    int count = 0;
    final gm = json['gang_members'];
    if (gm is List && gm.isNotEmpty) {
      count = (gm.first['count'] as num?)?.toInt() ?? 0;
    }

    return Gang(
      id: json['id'] as String,
      name: json['name'] as String,
      tag: json['tag'] as String,
      description: (json['description'] as String?) ?? '',
      leaderId: json['leader_id'] as String,
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      memberSlots: (json['member_slots'] as num).toInt(),
      isRecruiting: json['is_recruiting'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberCount: count,
      influence:
          (json['influence'] as num?)?.toInt() ??
          0, // NEU: Wird jetzt ausgelesen
    );
  }
}
