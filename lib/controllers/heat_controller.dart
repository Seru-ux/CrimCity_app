// lib/controllers/heat_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/heat_action.dart';
import '../services/heat_service.dart';

// ============================================================
// PROVIDER
// ============================================================

final heatServiceProvider = Provider<HeatService>((ref) {
  return HeatService(Supabase.instance.client);
});

final heatControllerProvider =
StateNotifierProvider<HeatController, HeatState>((ref) {
  return HeatController(ref.read(heatServiceProvider));
});

// ============================================================
// STATE
// ============================================================

class HeatState {
  final bool isLoading;
  final String? error;
  final int heat;
  final List<HeatAction> actions;
  final Map<String, dynamic>? modifiers;

  const HeatState({
    this.isLoading = false,
    this.error,
    this.heat = 0,
    this.actions = const [],
    this.modifiers,
  });

  HeatState copyWith({
    bool? isLoading,
    String? error,
    int? heat,
    List<HeatAction>? actions,
    Map<String, dynamic>? modifiers,
    bool clearError = false,
  }) {
    return HeatState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      heat: heat ?? this.heat,
      actions: actions ?? this.actions,
      modifiers: modifiers ?? this.modifiers,
    );
  }

  /// Label aus Modifier (unauffällig / auffällig / gejagt / cop-heat)
  String get heatLabel =>
      (modifiers?['label'] as String?) ?? 'unbekannt';

  /// 0.0 – 1.0 (für Fortschrittsbalken, Cap 100)
  double get heatProgress => (heat / 100.0).clamp(0.0, 1.0);
}

// ============================================================
// CONTROLLER
// ============================================================

class HeatController extends StateNotifier<HeatState> {
  final HeatService _service;

  HeatController(this._service) : super(const HeatState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.fetchMyHeat(),
        _service.fetchHeatActions(),
        _service.fetchHeatModifiers(),
      ]);
      state = state.copyWith(
        isLoading: false,
        heat: results[0] as int,
        actions: results[1] as List<HeatAction>,
        modifiers: results[2] as Map<String, dynamic>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> reduceHeat(String actionKey) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.reduceHeat(actionKey);
      await load();
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