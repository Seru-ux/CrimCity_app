// lib/services/npc_progression_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class NpcProgressionService {
  final SupabaseClient _client;

  NpcProgressionService(this._client);

  /// Trainieren (kostet Cash, gibt XP)
  Future<Map<String, dynamic>> trainNpc(String playerNpcId) async {
    final response = await _client.rpc('train_npc', params: {
      'p_player_npc_id': playerNpcId,
    });
    return response as Map<String, dynamic>;
  }

  /// Heilen (kostet Cash, entfernt injured)
  Future<Map<String, dynamic>> healNpc(String playerNpcId) async {
    final response = await _client.rpc('heal_npc', params: {
      'p_player_npc_id': playerNpcId,
    });
    return response as Map<String, dynamic>;
  }

  /// Qualität verbessern (Splitter + Cash)
  Future<Map<String, dynamic>> upgradeQuality(String playerNpcId) async {
    final response = await _client.rpc('upgrade_quality', params: {
      'p_player_npc_id': playerNpcId,
    });
    return response as Map<String, dynamic>;
  }

  /// Splitter hinzufügen (nach Raub)
  Future<Map<String, dynamic>> addShards({
    required String playerNpcId,
    required int shards,
  }) async {
    final response = await _client.rpc('add_quality_shards', params: {
      'p_player_npc_id': playerNpcId,
      'p_shards': shards,
    });
    return response as Map<String, dynamic>;
  }
}