import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attribute_type.dart';
import '../models/character_class.dart';
import '../models/player_profile.dart';
import '../services/player_service.dart';

final playerServiceProvider = Provider<PlayerService>((ref) {
  return PlayerService(Supabase.instance.client);
});

class CharacterState {
  final PlayerProfile? profile;
  final bool isLoading;
  final String? error;

  const CharacterState({this.profile, this.isLoading = false, this.error});

  CharacterState copyWith({
    PlayerProfile? profile,
    bool? isLoading,
    String? error,
  }) => CharacterState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class CharacterController extends StateNotifier<CharacterState> {
  final PlayerService _service;

  CharacterController(this._service) : super(const CharacterState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final p = await _service.getMyCharacter();
      state = CharacterState(profile: p);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> chooseClass(CharacterClass c) async {
    try {
      final p = await _service.chooseClass(c);
      state = CharacterState(profile: p);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> spendPoint(AttributeType attr) async {
    final current = state.profile;
    if (current == null || current.availablePoints <= 0) return false;
    try {
      final p = await _service.spendSkillPoint(attr);
      state = CharacterState(profile: p);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final characterControllerProvider =
    StateNotifierProvider<CharacterController, CharacterState>((ref) {
      return CharacterController(ref.watch(playerServiceProvider));
    });
