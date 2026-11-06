class MerchantOffer {
  final String merchantName;
  final String merchantType;
  final String? merchantAvatar;
  final List<int> boughtItemIds;
  final Map<int, double> priceFactors;
  final String offerDate;
  final DateTime expiresAt;

  MerchantOffer({
    required this.merchantName,
    required this.merchantType,
    required this.merchantAvatar,
    required this.boughtItemIds,
    required this.priceFactors,
    required this.offerDate,
    required this.expiresAt,
  });

  factory MerchantOffer.fromJson(Map<String, dynamic> json) {
    final raw = (json['price_factors'] as Map<String, dynamic>?) ?? {};
    return MerchantOffer(
      merchantName: json['merchant_name'] ?? '',
      merchantType: json['merchant_type'] ?? 'balanced',
      merchantAvatar: json['merchant_avatar'],
      boughtItemIds: (json['bought_item_ids'] as List?)?.cast<int>() ?? [],
      priceFactors: raw.map(
        (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
      ),
      offerDate: json['offer_date'] ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }
}
