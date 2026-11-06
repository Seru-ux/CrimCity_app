// lib/models/player_npc_gear.dart

import 'npc_gear.dart';

class PlayerNpcGear {
  final String id;
  final String playerNpcId;
  final String gearId;
  final bool equipped;
  final DateTime acquiredAt;
  final NpcGear? gear; // joint

  const PlayerNpcGear({
    required this.id,
    required this.playerNpcId,
    required this.gearId,
    required this.equipped,
    required this.acquiredAt,
    this.gear,
  });

  factory PlayerNpcGear.fromJson(Map<String, dynamic> json) {
    return PlayerNpcGear(
      id: json['id'] as String,
      playerNpcId: json['player_npc_id'] as String,
      gearId: json['gear_id'] as String,
      equipped: json['equipped'] as bool? ?? false,
      acquiredAt: DateTime.parse(json['acquired_at'] as String),
      gear: json['npc_gear'] != null
          ? NpcGear.fromJson(json['npc_gear'] as Map<String, dynamic>)
          : null,
    );
  }
}