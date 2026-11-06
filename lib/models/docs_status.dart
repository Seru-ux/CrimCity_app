class DocsStatus {
  final bool isOpen;
  final DateTime? opensAt;
  final DateTime? closesAt;

  DocsStatus({required this.isOpen, this.opensAt, this.closesAt});

  factory DocsStatus.fromJson(Map<String, dynamic> j) => DocsStatus(
    isOpen: j['is_open'] == true,
    opensAt: j['opens_at'] != null ? DateTime.parse(j['opens_at']) : null,
    closesAt: j['closes_at'] != null ? DateTime.parse(j['closes_at']) : null,
  );
}
