import 'player_profile.dart';

class GameState {
  final PlayerProfile? profile;
  final bool isLoading;
  final String? activeCrime;
  final int displayEnergy;

  const GameState({
    this.profile,
    this.isLoading = true,
    this.activeCrime,
    this.displayEnergy = 0,
  });

  /// Praktischer Helfer für das UI (z.B. HUD)
  bool get hasProfile => profile != null;

  GameState copyWith({
    PlayerProfile? profile,
    bool? isLoading,
    String? activeCrime,
    bool clearActiveCrime = false,
    int? displayEnergy,
  }) => GameState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    activeCrime: clearActiveCrime ? null : (activeCrime ?? this.activeCrime),
    displayEnergy: displayEnergy ?? this.displayEnergy,
  );
}
