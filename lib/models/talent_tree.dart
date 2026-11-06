// lib/models/talent_tree.dart

import 'talent_branch.dart';

class TalentTree {
  final String id;
  final String? classId;
  final String name;
  final String description;
  final int sortOrder;
  final List<TalentBranch> branches;

  const TalentTree({
    required this.id,
    required this.classId,
    required this.name,
    required this.description,
    required this.sortOrder,
    required this.branches,
  });

  factory TalentTree.fromJson(Map<String, dynamic> json) {
    return TalentTree(
      id: json['id'] as String,
      classId: json['class'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      branches: (json['branches'] as List<dynamic>? ?? [])
          .map((e) => TalentBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TalentState {
  final int talentPoints;
  final bool hasUsedFreeRespec;
  final int crimCoins;
  final String? classId;
  final List<TalentTree> trees;

  const TalentState({
    required this.talentPoints,
    required this.hasUsedFreeRespec,
    required this.crimCoins,
    required this.classId,
    required this.trees,
  });

  factory TalentState.fromJson(Map<String, dynamic> json) {
    return TalentState(
      talentPoints: (json['talent_points'] as num?)?.toInt() ?? 0,
      hasUsedFreeRespec: json['has_used_free_respec'] as bool? ?? false,
      crimCoins: (json['crim_coins'] as num?)?.toInt() ?? 0,
      classId: json['class'] as String?,
      trees: (json['trees'] as List<dynamic>? ?? [])
          .map((e) => TalentTree.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory TalentState.empty() => const TalentState(
    talentPoints: 0,
    hasUsedFreeRespec: false,
    crimCoins: 0,
    classId: null,
    trees: [],
  );

  TalentState copyWith({
    int? talentPoints,
    bool? hasUsedFreeRespec,
    int? crimCoins,
    String? classId,
    List<TalentTree>? trees,
  }) {
    return TalentState(
      talentPoints: talentPoints ?? this.talentPoints,
      hasUsedFreeRespec: hasUsedFreeRespec ?? this.hasUsedFreeRespec,
      crimCoins: crimCoins ?? this.crimCoins,
      classId: classId ?? this.classId,
      trees: trees ?? this.trees,
    );
  }
}