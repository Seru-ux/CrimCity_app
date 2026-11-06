// lib/controllers/heist_browser_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/heist.dart';
import '../services/heist_service.dart';

// ============================================================
// PROVIDER
// ============================================================

final heistServiceProvider = Provider<HeistService>((ref) {
  return HeistService(Supabase.instance.client);
});

final heistBrowserControllerProvider =
StateNotifierProvider<HeistBrowserController, HeistBrowserState>((ref) {
  return HeistBrowserController(ref.read(heistServiceProvider));
});

// ============================================================
// STATE
// ============================================================

class HeistBrowserState {
  final bool isLoading;
  final String? error;
  final List<Heist> heists;
  final int playerLevel;

  const HeistBrowserState({
    this.isLoading = false,
    this.error,
    this.heists = const [],
    this.playerLevel = 1,
  });

  HeistBrowserState copyWith({
    bool? isLoading,
    String? error,
    List<Heist>? heists,
    int? playerLevel,
    bool clearError = false,
  }) {
    return HeistBrowserState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      heists: heists ?? this.heists,
      playerLevel: playerLevel ?? this.playerLevel,
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class HeistBrowserController extends StateNotifier<HeistBrowserState> {
  final HeistService _service;

  HeistBrowserController(this._service) : super(const HeistBrowserState());

  Future<void> load({required int playerLevel}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final heists = await _service.fetchAvailableHeists(
        playerLevel: playerLevel,
      );
      state = state.copyWith(
        isLoading: false,
        heists: heists,
        playerLevel: playerLevel,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}