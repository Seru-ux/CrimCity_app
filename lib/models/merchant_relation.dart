class MerchantRelation {
  final String merchantName;
  final int totalSold;
  final int totalEarned;
  final DateTime lastSoldAt;

  MerchantRelation({
    required this.merchantName,
    required this.totalSold,
    required this.totalEarned,
    required this.lastSoldAt,
  });

  factory MerchantRelation.fromJson(Map<String, dynamic> j) => MerchantRelation(
    merchantName: j['merchant_name'],
    totalSold: j['total_sold'],
    totalEarned: j['total_earned'],
    lastSoldAt: DateTime.parse(j['last_sold_at']),
  );
}
