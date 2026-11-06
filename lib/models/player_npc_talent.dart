// lib/models/player_npc_talent.dart

import 'npc_talent.dart';

class PlayerNpcTalent {
  final String id;
  final String playerNpcId;
  final String talentId;
  final DateTime chosenAt;
  final NpcTalent? talent;

  const PlayerNpcTalent({
    required this.id,
    required this.playerNpcId,
    required this.talentId,
    required this.chosenAt,
    this.talent,
  });

  factory PlayerNpcTalent.fromJson(Map<String, dynamic> json) {
    return PlayerNpcTalent(
      id: json['id'] as String,
      playerNpcId: json['player_npc_id'] as String,
      talentId: json['talent_id'] as String,
      chosenAt: DateTime.parse(json['chosen_at'] as String),
      talent: json['npc_talents'] != null
          ? NpcTalent.fromJson(json['npc_talents'] as Map<String, dynamic>)
          : null,
    );
  }
}