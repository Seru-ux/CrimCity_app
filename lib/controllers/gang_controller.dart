// lib/controllers/gang_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/district.dart'; // NEU
import '../models/gang.dart';
import '../models/gang_application.dart';
import '../models/gang_invite.dart';
import '../models/gang_member.dart';
import '../models/gang_mission.dart';
import '../services/gang_service.dart';

enum GangStatus { loading, noGang, inGang, error }

class GangState {
  final GangStatus status;
  final Gang? gang;
  final List<GangMember> members;
  final List<GangInvite> myInvites;
  final List<GangApplication> applications;
  final List<GangMission> missions;
  final List<District> districts; // NEU
  final String? error;
  final bool isSubmitting;

  const GangState({
    this.status = GangStatus.loading,
    this.gang,
    this.members = const [],
    this.myInvites = const [],
    this.applications = const [],
    this.missions = const [],
    this.districts = const [], // NEU
    this.error,
    this.isSubmitting = false,
  });

  GangState copyWith({
    GangStatus? status,
    Gang? gang,
    List<GangMember>? members,
    List<GangInvite>? myInvites,
    List<GangApplication>? applications,
    List<GangMission>? missions,
    List<District>? districts,
    String? error,
    bool? isSubmitting,
    bool clearError = false,
  }) => GangState(
    status: status ?? this.status,
    gang: gang ?? this.gang,
    members: members ?? this.members,
    myInvites: myInvites ?? this.myInvites,
    applications: applications ?? this.applications,
    missions: missions ?? this.missions,
    districts: districts ?? this.districts,
    error: clearError ? null : (error ?? this.error),
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  int get memberCount => members.length;

  bool get canAttackDistricts => memberCount >= 3;

  GangRole? get myRole {
    if (gang == null) return null;
    final myId = Supabase.instance.client.auth.currentUser?.id;
    if (myId == null) return null;
    try {
      return members.firstWhere((m) => m.playerId == myId).role;
    } catch (_) {
      return null;
    }
  }
}

class GangController extends StateNotifier<GangState> {
  final GangService _service;

  GangController(this._service) : super(const GangState());

  Future<void> load() async {
    state = state.copyWith(status: GangStatus.loading, clearError: true);
    try {
      final gang = await _service.fetchMyGang();
      if (gang == null) {
        final invites = await _service.fetchMyInvites();
        state = GangState(status: GangStatus.noGang, myInvites: invites);
        return;
      }
      final members = await _service.fetchMembers(gang.id);
      final invites = await _service.fetchMyInvites();
      final missions = await _service.fetchGangMissions(gang.id);
      final districts = await _service.fetchDistricts(); // NEU

      state = GangState(
        status: GangStatus.inGang,
        gang: gang,
        members: members,
        myInvites: invites,
        missions: missions,
        districts: districts, // NEU
      );
    } catch (e) {
      state = state.copyWith(status: GangStatus.error, error: e.toString());
    }
  }

  // (Bestehende Methoden wie createGang, leaveGang, kickMember, etc. bleiben hier unverändert)
  Future<bool> createGang({
    required String name,
    required String tag,
    String description = '',
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.createGang(name: name, tag: tag, description: description);
      await load();
      return true;
    } on GangException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<void> leaveGang() async {
    try {
      await _service.leaveGang();
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> kickMember(String playerId) async {
    try {
      await _service.kickMember(playerId);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> sendInvite(String inviteeId) async {
    if (state.gang == null) return;
    try {
      await _service.sendInvite(state.gang!.id, inviteeId);
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> respondToInvite(String inviteId, bool accept) async {
    try {
      await _service.respondToInvite(inviteId, accept);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> applyToGang(String gangId, {String message = ''}) async {
    try {
      await _service.applyToGang(gangId, message: message);
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> respondToApplication(String appId, bool accept) async {
    try {
      await _service.respondToApplication(appId, accept);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> loadApplications() async {
    if (state.gang == null) return;
    try {
      final apps = await _service.fetchGangApplications(state.gang!.id);
      state = state.copyWith(applications: apps);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> startMission({
    required String missionCode,
    required String name,
    required String description,
    required int requiredContributions,
    required int expReward,
  }) async {
    if (state.gang == null) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.startMission(
        missionCode: missionCode,
        name: name,
        description: description,
        requiredContributions: requiredContributions,
        expReward: expReward,
      );
      await load();
    } on GangException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  Future<void> contributeToMission(String missionId, int amount) async {
    if (state.gang == null) return;
    try {
      await _service.contributeToMission(missionId, amount);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> changeMemberRole(String playerId, GangRole newRole) async {
    try {
      await _service.changeMemberRole(playerId, newRole);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> updateGangSettings({
    String? description,
    bool? isRecruiting,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.updateGangSettings(
        description: description,
        isRecruiting: isRecruiting,
      );
      await load();
    } on GangException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
    }
  }

  // === NEU: Distrikte ===
  Future<void> claimDistrict(String districtId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.claimDistrict(districtId);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
    }
  }

  Future<void> collectIncome(String districtId) async {
    try {
      await _service.collectDistrictIncome(districtId);
      await load();
    } on GangException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }
}

// === Provider ===
final gangServiceProvider = Provider<GangService>(
  (ref) => GangService(Supabase.instance.client),
);

final gangControllerProvider = StateNotifierProvider<GangController, GangState>(
  (ref) => GangController(ref.watch(gangServiceProvider)),
);
