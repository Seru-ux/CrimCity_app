// lib/models/talent_branch.dart

import 'talent.dart';

class TalentBranch {
  final String id;
  final String name;
  final String description;
  final int sortOrder;
  final List<Talent> talents;

  const TalentBranch({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
    required this.talents,
  });

  factory TalentBranch.fromJson(Map<String, dynamic> json) {
    return TalentBranch(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      talents: (json['talents'] as List<dynamic>? ?? [])
          .map((e) => Talent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}