// lib/services/gear_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc_gear.dart';
import '../models/player_npc_gear.dart';

class GearService {
  final SupabaseClient _client;

  GearService(this._client);

  /// Alle verfügbaren Ausrüstungs-Items
  Future<List<NpcGear>> fetchAllGear() async {
    final response = await _client
        .from('npc_gear')
        .select()
        .eq('is_active', true)
        .order('slot', ascending: true)
        .order('price_cash', ascending: true);

    return (response as List)
        .map((e) => NpcGear.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ausrüstung eines NPCs
  Future<List<PlayerNpcGear>> fetchNpcGear(String playerNpcId) async {
    final response = await _client
        .from('player_npc_gear')
        .select('*, npc_gear(*)')
        .eq('player_npc_id', playerNpcId);

    return (response as List)
        .map((e) => PlayerNpcGear.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ausrüstung kaufen (RPC)
  Future<Map<String, dynamic>> buyGear({
    required String playerNpcId,
    required String gearId,
  }) async {
    final response = await _client.rpc('buy_gear', params: {
      'p_player_npc_id': playerNpcId,
      'p_gear_id': gearId,
    });
    return response as Map<String, dynamic>;
  }

  /// Ausrüstung anlegen (RPC)
  Future<Map<String, dynamic>> equipGear({
    required String playerNpcId,
    required String playerGearId,
  }) async {
    final response = await _client.rpc('equip_gear', params: {
      'p_player_npc_id': playerNpcId,
      'p_player_gear_id': playerGearId,
    });
    return response as Map<String, dynamic>;
  }

  /// Ausrüstung ablegen (RPC)
  Future<Map<String, dynamic>> unequipGear({
    required String playerNpcId,
    required String playerGearId,
  }) async {
    final response = await _client.rpc('unequip_gear', params: {
      'p_player_npc_id': playerNpcId,
      'p_player_gear_id': playerGearId,
    });
    return response as Map<String, dynamic>;
  }
}