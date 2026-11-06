// lib/models/npc_assignment.dart

class NpcAssignment {
  final String id;
  final String playerId;
  final String playerNpcId;
  final String heistId;
  final int riskLevel;
  final String status; // 'running' | 'success' | 'failed' | 'jailed' | 'cancelled'
  final DateTime finishAt;
  final Map<String, dynamic>? resultJson;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const NpcAssignment({
    required this.id,
    required this.playerId,
    required this.playerNpcId,
    required this.heistId,
    required this.riskLevel,
    required this.status,
    required this.finishAt,
    this.resultJson,
    required this.createdAt,
    this.resolvedAt,
  });

  factory NpcAssignment.fromJson(Map<String, dynamic> json) {
    return NpcAssignment(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      playerNpcId: json['player_npc_id'] as String,
      heistId: json['heist_id'] as String,
      riskLevel: (json['risk_level'] as num).toInt(),
      status: json['status'] as String,
      finishAt: DateTime.parse(json['finish_at'] as String),
      resultJson: json['result_json'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'player_id': playerId,
    'player_npc_id': playerNpcId,
    'heist_id': heistId,
    'risk_level': riskLevel,
    'status': status,
    'finish_at': finishAt.toIso8601String(),
    'result_json': resultJson,
    'created_at': createdAt.toIso8601String(),
    'resolved_at': resolvedAt?.toIso8601String(),
  };

  bool get isRunning => status == 'running';
  bool get isResolved =>
      status == 'success' || status == 'failed' || status == 'jailed';

  Duration? get remainingTime {
    if (!isRunning) return null;
    final diff = finishAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get statusLabel {
    switch (status) {
      case 'running':
        return 'Läuft';
      case 'success':
        return 'Erfolg';
      case 'failed':
        return 'Fehlgeschlagen';
      case 'jailed':
        return 'Im Knast';
      case 'cancelled':
        return 'Abgebrochen';
      default:
        return status;
    }
  }

  /// Ergebnis: Erfolg?
  bool get wasSuccess => resultJson?['success'] == true;

  /// Ergebnis: Cash
  int get cashGained => (resultJson?['cash'] as num?)?.toInt() ?? 0;

  /// Ergebnis: Loot (Item-Name → Menge)
  Map<String, int> get lootGained {
    final loot = resultJson?['loot'];
    if (loot is! Map) return {};
    return loot.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }

  /// Ergebnis: Crit?
  bool get wasCrit => resultJson?['crit'] == true;

  /// Ergebnis: Jail?
  bool get wasJailed => resultJson?['jailed'] == true;

  /// Ergebnis: Jail-Sekunden
  int get jailSeconds => (resultJson?['jail_seconds'] as num?)?.toInt() ?? 0;
}