// lib/controllers/npc_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc.dart';
import '../models/player_npc.dart';
import '../services/npc_service.dart';

// ============================================================
// PROVIDER
// ============================================================

final npcServiceProvider = Provider<NpcService>((ref) {
  return NpcService(Supabase.instance.client);
});

final npcControllerProvider =
StateNotifierProvider<NpcController, NpcState>((ref) {
  return NpcController(ref.read(npcServiceProvider));
});

// ============================================================
// STATE
// ============================================================

class NpcState {
  final bool isLoading;
  final String? error;
  final List<Npc> availableNpcs;
  final List<PlayerNpc> myCrew;
  final int crewSlots;

  const NpcState({
    this.isLoading = false,
    this.error,
    this.availableNpcs = const [],
    this.myCrew = const [],
    this.crewSlots = 3,
  });

  NpcState copyWith({
    bool? isLoading,
    String? error,
    List<Npc>? availableNpcs,
    List<PlayerNpc>? myCrew,
    int? crewSlots,
    bool clearError = false,
  }) {
    return NpcState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      availableNpcs: availableNpcs ?? this.availableNpcs,
      myCrew: myCrew ?? this.myCrew,
      crewSlots: crewSlots ?? this.crewSlots,
    );
  }

  int get crewCount => myCrew.length;
  bool get isCrewFull => crewCount >= crewSlots;
  int get freeSlots => (crewSlots - crewCount).clamp(0, 999);

  /// Alle erschöpften NPCs
  List<PlayerNpc> get exhausted =>
      myCrew.where((n) => n.isExhausted).toList();

  /// NPC per ID
  PlayerNpc? byId(String id) {
    for (final n in myCrew) {
      if (n.id == id) return n;
    }
    return null;
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class NpcController extends StateNotifier<NpcState> {
  final NpcService _service;

  NpcController(this._service) : super(const NpcState());

  /// Lädt Markt + Crew + Slots parallel
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.fetchAvailableNpcs(),
        _service.fetchMyCrew(),
        _service.fetchCrewSlots(),
      ]);
      state = state.copyWith(
        isLoading: false,
        availableNpcs: results[0] as List<Npc>,
        myCrew: results[1] as List<PlayerNpc>,
        crewSlots: results[2] as int,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadCrew() async {
    try {
      final crew = await _service.fetchMyCrew();
      final slots = await _service.fetchCrewSlots();
      state = state.copyWith(myCrew: crew, crewSlots: slots);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Stamina-Regeneration: Server-Trigger + lokales Update der Crew.
  /// Wird vom 5s-Ticker im CrewDashboard aufgerufen.
  Future<void> tickStamina() async {
    try {
      final snapshots = await _service.regenStamina();
      if (snapshots.isEmpty) return;

      final updated = <PlayerNpc>[];
      for (final npc in state.myCrew) {
        final snap = snapshots[npc.id];
        if (snap == null) {
          updated.add(npc);
          continue;
        }
        updated.add(npc.copyWithStamina(
          stamina: snap.stamina,
          maxStamina: snap.maxStamina,
          lastStaminaRegen: snap.lastStaminaRegen,
        ));
      }
      state = state.copyWith(myCrew: updated);
    } catch (_) {
      // Regen ist best-effort – Fehler nicht in die UI propagieren
    }
  }

  /// NPC anheuern
  Future<bool> hire(String npcId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.hireNpc(npcId);
      await loadCrew();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// NPC freikaufen
  Future<bool> buyout(String playerNpcId, {String currency = 'cash'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.buyoutNpc(playerNpcId, currency: currency);
      await loadCrew();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}