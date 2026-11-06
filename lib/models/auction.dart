class Auction {
  final String id;
  final String sellerId;
  final int itemId;
  final int quantity;
  final int startPrice;
  final int? buyoutPrice;
  final int currentBid;
  final String? currentBidder;
  final String status;
  final DateTime expiresAt;

  Auction({
    required this.id,
    required this.sellerId,
    required this.itemId,
    required this.quantity,
    required this.startPrice,
    required this.buyoutPrice,
    required this.currentBid,
    required this.currentBidder,
    required this.status,
    required this.expiresAt,
  });

  factory Auction.fromJson(Map<String, dynamic> j) => Auction(
    id: j['id'],
    sellerId: j['seller_id'],
    itemId: j['item_id'],
    quantity: j['quantity'],
    startPrice: j['start_price'],
    buyoutPrice: j['buyout_price'],
    currentBid: j['current_bid'] ?? 0,
    currentBidder: j['current_bidder'],
    status: j['status'] ?? 'active',
    expiresAt: DateTime.parse(j['expires_at']),
  );
}
