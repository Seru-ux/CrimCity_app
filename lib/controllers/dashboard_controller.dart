// lib/controllers/dashboard_controller.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../services/auth_service.dart';
import '../services/player_service.dart';

class DashboardController extends StateNotifier<GameState> {
  final PlayerService _playerService;
  final AuthService _authService;

  Timer? _energyTimer;

  DashboardController(this._playerService, this._authService)
      : super(GameState()) {
    _init();
  }

  Future<void> _init() async {
    await loadProfile();
    _startTimers();
  }

  void _startTimers() {
    _energyTimer?.cancel();
    _energyTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      loadProfile(showLoading: false);
    });
  }

  Future<void> loadProfile({bool showLoading = true}) async {
    try {
      final user = _authService.currentUser;

      if (user == null) {
        if (showLoading) state = state.copyWith(isLoading: false);
        return;
      }

      // --- NEU: Server-Sync vor dem Abruf ---
      // 1. Energie regenerieren (nutzt Pimp-Klasse + Zäh-Talent)
      await _playerService.syncEnergy(user.id);

      // 2. HP neu berechnen (nutzt Hitman/Burglar-Klasse + Eisern/Unverwüstlich-Talent)
      await _playerService.refreshStats(user.id);
      // --------------------------------------

      final profile = await _playerService.getProfile(user.id);

      state = state.copyWith(
        profile: profile,
        displayEnergy: profile.energy,
        isLoading: false,
      );
    } catch (e) {
      if (showLoading) state = state.copyWith(isLoading: false);
    }
  }

  Future<Map<String, dynamic>?> commitCrime(String crimeType) async {
    if (state.activeCrime != null) return null;

    state = state.copyWith(activeCrime: crimeType);

    try {
      final response = await _playerService.commitCrime(crimeType);
      await loadProfile(showLoading: false);
      return response;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(clearActiveCrime: true);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }
}

final dashboardControllerProvider =
StateNotifierProvider<DashboardController, GameState>((ref) {
  return DashboardController(PlayerService(), AuthService());
});