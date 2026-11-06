// lib/services/npc_talent_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc_talent.dart';
import '../models/player_npc_talent.dart' hide NpcTalent;

class NpcTalentService {
  final SupabaseClient _client;

  NpcTalentService(this._client);

  /// Alle verfügbaren NPC-Talente
  Future<List<NpcTalent>> fetchAllTalents() async {
    final response = await _client
        .from('npc_talents')
        .select()
        .eq('is_active', true);

    return (response as List)
        .map((e) => NpcTalent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gewählte Talente eines NPCs
  Future<List<PlayerNpcTalent>> fetchNpcTalents(String playerNpcId) async {
    final response = await _client
        .from('player_npc_talents')
        .select('*, npc_talents(*)')
        .eq('player_npc_id', playerNpcId);

    return (response as List)
        .map((e) => PlayerNpcTalent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Talent wählen (RPC)
  Future<Map<String, dynamic>> chooseTalent({
    required String playerNpcId,
    required String talentId,
  }) async {
    final response = await _client.rpc('choose_talent', params: {
      'p_player_npc_id': playerNpcId,
      'p_talent_id': talentId,
    });
    return response as Map<String, dynamic>;
  }

  /// 3 zufällige Talente zur Auswahl bei Level-Up
  Future<List<NpcTalent>> fetchTalentChoices(String playerNpcId) async {
    final response = await _client.rpc('get_talent_choices', params: {
      'p_player_npc_id': playerNpcId,
    });
    return (response as List)
        .map((e) => NpcTalent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}