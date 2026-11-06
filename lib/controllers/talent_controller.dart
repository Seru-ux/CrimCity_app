// lib/controllers/talent_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/talent_tree.dart';
import '../services/talent_service.dart';

final talentServiceProvider = Provider<TalentService>((ref) {
  return TalentService(Supabase.instance.client);
});

final talentControllerProvider =
StateNotifierProvider<TalentController, TalentUIState>((ref) {
  return TalentController(ref.read(talentServiceProvider));
});

class TalentUIState {
  final TalentState? state;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? lastMessage;

  const TalentUIState({
    this.state,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.lastMessage,
  });

  TalentUIState copyWith({
    TalentState? state,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? lastMessage,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return TalentUIState(
      state: state ?? this.state,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      lastMessage: clearMessage ? null : (lastMessage ?? this.lastMessage),
    );
  }
}

class TalentController extends StateNotifier<TalentUIState> {
  final TalentService _service;

  TalentController(this._service) : super(const TalentUIState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _service.getTalentState();
      state = state.copyWith(state: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Talente konnten nicht geladen werden: $e',
      );
    }
  }

  Future<bool> unlockOrUpgrade(String talentId) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true, clearMessage: true);
    try {
      final result = await _service.unlockOrUpgrade(talentId);
      final success = result['success'] == true;
      if (success) {
        await load();
        state = state.copyWith(
          isSubmitting: false,
          lastMessage: result['message'] as String?,
        );
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: result['message'] as String? ?? 'Unbekannter Fehler',
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Fehler beim Talent-Kauf: $e',
      );
      return false;
    }
  }

  Future<bool> respec({String payment = 'coins'}) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true, clearMessage: true);
    try {
      final result = await _service.respec(payment: payment);
      final success = result['success'] == true;
      if (success) {
        await load();
        state = state.copyWith(
          isSubmitting: false,
          lastMessage: result['message'] as String?,
        );
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: result['message'] as String? ?? 'Unbekannter Fehler',
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Fehler beim Respec: $e',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearMessage: true);
  }
}