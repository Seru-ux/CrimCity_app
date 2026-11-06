// lib/services/heist_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/heist.dart';

class HeistService {
  final SupabaseClient _client;

  HeistService(this._client);

  /// Alle verfügbaren Heists für den aktuellen Spieler-Level
  Future<List<Heist>> fetchAvailableHeists({required int playerLevel}) async {
    final response = await _client
        .from('heists')
        .select()
        .eq('is_active', true)
        .lte('min_level', playerLevel)
        .order('min_level', ascending: true);

    return (response as List)
        .map((e) => Heist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Einzelnen Heist laden
  Future<Heist?> fetchHeist(String heistId) async {
    final response = await _client
        .from('heists')
        .select()
        .eq('id', heistId)
        .maybeSingle();

    if (response == null) return null;
    return Heist.fromJson(response as Map<String, dynamic>);
  }
}