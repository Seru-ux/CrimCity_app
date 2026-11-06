// lib/models/gang_application.dart
class GangApplication {
  final String id;
  final String gangId;
  final String applicantId;
  final String applicantName;
  final String message;
  final String status;
  final DateTime createdAt;

  const GangApplication({
    required this.id,
    required this.gangId,
    required this.applicantId,
    required this.applicantName,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory GangApplication.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return GangApplication(
      id: json['id'] as String,
      gangId: json['gang_id'] as String,
      applicantId: json['applicant_id'] as String,
      applicantName: (profile?['username'] as String?) ?? 'Unbekannt',
      message: (json['message'] as String?) ?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
