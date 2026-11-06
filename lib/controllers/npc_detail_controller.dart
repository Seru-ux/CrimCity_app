// lib/controllers/npc_detail_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player_npc.dart';
import '../models/npc_gear.dart';
import '../models/npc_talent.dart';
import '../services/npc_service.dart';
import '../services/gear_service.dart';
import '../services/npc_talent_service.dart'; // WICHTIG: Der neue NPC-Talent-Service
import '../services/npc_progression_service.dart';
import 'npc_controller.dart';

// ============================================================
// PROVIDERS
// ============================================================

final gearServiceProvider = Provider<GearService>((ref) {
  return GearService(Supabase.instance.client);
});

final npcTalentServiceProvider = Provider<NpcTalentService>((ref) {
  return NpcTalentService(Supabase.instance.client);
});

final npcProgressionServiceProvider = Provider<NpcProgressionService>((ref) {
  return NpcProgressionService(Supabase.instance.client);
});

final npcDetailControllerProvider = StateNotifierProvider.family<
    NpcDetailController, NpcDetailState, String>((ref, playerNpcId) {
  return NpcDetailController(
    playerNpcId,
    ref.read(npcServiceProvider),
    ref.read(gearServiceProvider),
    ref.read(npcTalentServiceProvider),
    ref.read(npcProgressionServiceProvider),
  );
});

// ============================================================
// STATE
// ============================================================

class NpcDetailState {
  final bool isLoading;
  final String? error;
  final PlayerNpc? npc;
  final List<NpcGear> availableGear;
  final List<NpcTalent> availableTalents;

  const NpcDetailState({
    this.isLoading = false,
    this.error,
    this.npc,
    this.availableGear = const [],
    this.availableTalents = const [],
  });

  NpcDetailState copyWith({
    bool? isLoading,
    String? error,
    PlayerNpc? npc,
    List<NpcGear>? availableGear,
    List<NpcTalent>? availableTalents,
    bool clearError = false,
  }) {
    return NpcDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      npc: npc ?? this.npc,
      availableGear: availableGear ?? this.availableGear,
      availableTalents: availableTalents ?? this.availableTalents,
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class NpcDetailController extends StateNotifier<NpcDetailState> {
  final String playerNpcId;
  final NpcService _npcService;
  final GearService _gearService;
  final NpcTalentService _talentService;
  final NpcProgressionService _progressionService;

  NpcDetailController(
      this.playerNpcId,
      this._npcService,
      this._gearService,
      this._talentService,
      this._progressionService,
      ) : super(const NpcDetailState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _npcService.fetchPlayerNpc(playerNpcId),
        _gearService.fetchAllGear(),
        _talentService.fetchAllTalents(),
      ]);
      state = state.copyWith(
        isLoading: false,
        npc: results[0] as PlayerNpc?,
        availableGear: results[1] as List<NpcGear>,
        availableTalents: results[2] as List<NpcTalent>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> buyGear(String gearId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _gearService.buyGear(
        playerNpcId: playerNpcId,
        gearId: gearId,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> equipGear(String playerGearId) async {
    try {
      await _gearService.equipGear(
        playerNpcId: playerNpcId,
        playerGearId: playerGearId,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> unequipGear(String playerGearId) async {
    try {
      await _gearService.unequipGear(
        playerNpcId: playerNpcId,
        playerGearId: playerGearId,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> trainNpc() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _progressionService.trainNpc(playerNpcId);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> healNpc() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _progressionService.healNpc(playerNpcId);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> upgradeQuality() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _progressionService.upgradeQuality(playerNpcId);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> chooseTalent(String talentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _talentService.chooseTalent(
        playerNpcId: playerNpcId,
        talentId: talentId,
      );
      await load();
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