// lib/services/heat_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/heat_action.dart';

class HeatService {
  final SupabaseClient _client;

  HeatService(this._client);

  /// Aktuelle globale Heat des Spielers
  Future<int> fetchMyHeat() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Nicht eingeloggt');

    final response = await _client
        .from('profiles')
        .select('heat')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return 0;
    return (response['heat'] as num?)?.toInt() ?? 0;
  }

  /// Alle verfügbaren Heat-Aktionen
  Future<List<HeatAction>> fetchHeatActions() async {
    final response = await _client
        .from('heat_actions')
        .select()
        .eq('is_active', true)
        .order('heat_reduce', ascending: false);

    return (response as List)
        .map((e) => HeatAction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Heat senken (RPC)
  Future<Map<String, dynamic>> reduceHeat(String actionKey) async {
    final response = await _client.rpc(
      'reduce_heat',
      params: {'p_action_key': actionKey},
    );
    return response as Map<String, dynamic>;
  }

  /// Heat-Modifier (loot_mult, jail_mult, label)
  Future<Map<String, dynamic>> fetchHeatModifiers() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Nicht eingeloggt');

    final response = await _client.rpc(
      'get_heat_modifiers',
      params: {'p_player_id': userId},
    );
    return response as Map<String, dynamic>;
  }
}