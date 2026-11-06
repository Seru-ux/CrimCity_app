// lib/models/heat_action.dart

class HeatAction {
  final String id;
  final String key;
  final String name;
  final String? description;
  final int costCash;
  final int costCoins;
  final int heatReduce;
  final int cooldownSeconds;
  final String icon;
  final bool isActive;

  const HeatAction({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    required this.costCash,
    required this.costCoins,
    required this.heatReduce,
    required this.cooldownSeconds,
    required this.icon,
    required this.isActive,
  });

  factory HeatAction.fromJson(Map<String, dynamic> json) {
    return HeatAction(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      costCash: (json['cost_cash'] as num).toInt(),
      costCoins: (json['cost_coins'] as num).toInt(),
      heatReduce: (json['heat_reduce'] as num).toInt(),
      cooldownSeconds: (json['cooldown_seconds'] as num).toInt(),
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'name': name,
    'description': description,
    'cost_cash': costCash,
    'cost_coins': costCoins,
    'heat_reduce': heatReduce,
    'cooldown_seconds': cooldownSeconds,
    'icon': icon,
    'is_active': isActive,
  };

  String get costLabel {
    if (costCash > 0) return '${_formatNumber(costCash)} \$';
    if (costCoins > 0) return '$costCoins CrimCoins';
    return 'Kostenlos';
  }

  String get cooldownLabel {
    if (cooldownSeconds <= 0) return 'Kein Cooldown';
    final h = cooldownSeconds ~/ 3600;
    final m = (cooldownSeconds % 3600) ~/ 60;
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}