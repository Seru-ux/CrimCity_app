// lib/controllers/assignment_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc_assignment.dart';
import '../services/assignment_service.dart';

// ============================================================
// PROVIDER
// ============================================================

final assignmentServiceProvider = Provider<AssignmentService>((ref) {
  return AssignmentService(Supabase.instance.client);
});

final assignmentControllerProvider =
StateNotifierProvider<AssignmentController, AssignmentState>((ref) {
  return AssignmentController(ref.read(assignmentServiceProvider));
});

// ============================================================
// STATE
// ============================================================

class AssignmentState {
  final bool isLoading;
  final String? error;
  final List<NpcAssignment> running;
  final List<NpcAssignment> resolved;
  final DateTime lastTick;

  const AssignmentState({
    this.isLoading = false,
    this.error,
    this.running = const [],
    this.resolved = const [],
    required this.lastTick,
  });

  factory AssignmentState.initial() => AssignmentState(lastTick: DateTime.now());

  AssignmentState copyWith({
    bool? isLoading,
    String? error,
    List<NpcAssignment>? running,
    List<NpcAssignment>? resolved,
    DateTime? lastTick,
    bool clearError = false,
  }) {
    return AssignmentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      running: running ?? this.running,
      resolved: resolved ?? this.resolved,
      lastTick: lastTick ?? this.lastTick,
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class AssignmentController extends StateNotifier<AssignmentState> {
  final AssignmentService _service;
  Timer? _ticker;

  AssignmentController(this._service) : super(AssignmentState.initial()) {
    // jede Minute prüfen, ob was fällig ist
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.fetchRunningAssignments(),
        _service.fetchResolvedAssignments(),
      ]);
      state = state.copyWith(
        isLoading: false,
        running: results[0] as List<NpcAssignment>,
        resolved: results[1] as List<NpcAssignment>,
        lastTick: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Löst fällige Aufträge auf dem Server + lädt neu
  Future<void> tick() async {
    try {
      await _service.resolveDueAssignments();
      await load();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Schickt eine ganze Gruppe von NPCs auf einen Heist
  Future<bool> assignGroup({
    required String heistId,
    required List<String> playerNpcIds,
    required int riskLevel,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.assignHeistGroup(
        heistId: heistId,
        playerNpcIds: playerNpcIds,
        riskLevel: riskLevel,
      );
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