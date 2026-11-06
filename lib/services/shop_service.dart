import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auction.dart';
import '../models/docs_status.dart';
import '../models/inventory_entry.dart';
import '../models/merchant_offer.dart';
import '../models/merchant_relation.dart';
import '../models/shop_item.dart';

class ShopService {
  final _client = Supabase.instance.client;

  Future<List<ShopItem>> getItems({String? shopType}) async {
    var q = _client.from('shop_items').select();
    if (shopType != null) q = q.eq('shop_type', shopType);
    return ((await q) as List).map((e) => ShopItem.fromJson(e)).toList();
  }

  Future<Map<String, double>> getDailyPrices() async {
    final res = await _client.rpc('get_or_create_daily_prices');
    final map = (res as Map?) ?? {};
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<Map<String, dynamic>> buyItem(int itemId, {int qty = 1}) async {
    final r = await _client.rpc(
      'buy_shop_item',
      params: {'p_item_id': itemId, 'p_quantity': qty},
    );
    return Map<String, dynamic>.from(r as Map);
  }

  Future<MerchantOffer?> getMerchantOffer() async {
    final r = await _client.rpc('get_or_create_merchant_offer');
    if (r == null) return null;
    return MerchantOffer.fromJson(Map<String, dynamic>.from(r as Map));
  }

  Future<Map<String, dynamic>> sellToMerchant(int itemId, {int qty = 1}) async {
    final r = await _client.rpc(
      'sell_to_merchant',
      params: {'p_item_id': itemId, 'p_quantity': qty},
    );
    return Map<String, dynamic>.from(r as Map);
  }

  Future<Map<String, dynamic>> sellAllToMerchant() async {
    final r = await _client.rpc('sell_all_to_merchant');
    return Map<String, dynamic>.from(r as Map);
  }

  Future<DocsStatus> getDocsStatus() async {
    final r = await _client.rpc('get_docs_status');
    return DocsStatus.fromJson(Map<String, dynamic>.from(r as Map));
  }

  Future<Map<String, dynamic>> sellToDocs(int itemId, {int qty = 1}) async {
    final r = await _client.rpc(
      'sell_to_docs',
      params: {'p_item_id': itemId, 'p_quantity': qty},
    );
    return Map<String, dynamic>.from(r as Map);
  }

  Future<InventorySnapshot> getMyInventory() async {
    final r = await _client.rpc('get_my_inventory');
    return InventorySnapshot.fromJson(Map<String, dynamic>.from(r as Map));
  }

  // Auktionen
  Future<List<Auction>> getActiveAuctions() async {
    final rows = await _client
        .from('auctions')
        .select()
        .eq('status', 'active')
        .order('expires_at');
    return (rows as List).map((e) => Auction.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> createAuction(
    int itemId,
    int qty,
    int start, {
    int? buyout,
  }) async {
    final r = await _client.rpc(
      'create_auction',
      params: {
        'p_item_id': itemId,
        'p_quantity': qty,
        'p_start_price': start,
        'p_buyout': buyout,
      },
    );
    return Map<String, dynamic>.from(r as Map);
  }

  Future<Map<String, dynamic>> bidOnAuction(String id, int amount) async {
    final r = await _client.rpc(
      'bid_on_auction',
      params: {'p_auction_id': id, 'p_amount': amount},
    );
    return Map<String, dynamic>.from(r as Map);
  }

  Future<Map<String, dynamic>> buyoutAuction(String id) async {
    final r = await _client.rpc('buyout_auction', params: {'p_auction_id': id});
    return Map<String, dynamic>.from(r as Map);
  }

  Future<List<MerchantRelation>> getMerchantRelations() async {
    final r = await _client.rpc('get_merchant_relations');
    final list = (r as List?) ?? [];
    return list
        .map((e) => MerchantRelation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Auction>> getMyAuctions() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('auctions')
        .select()
        .eq('seller_id', uid)
        .order('created_at', ascending: false);
    return (rows as List).map((e) => Auction.fromJson(e)).toList();
  }
  // In shop_service.dart hinzufügen:

  Future<Map<String, dynamic>> equipItem(int itemId) async {
    final r = await _client.rpc('equip_item', params: {'p_item_id': itemId});
    return Map<String, dynamic>.from(r as Map);
  }

  Future<Map<String, dynamic>> expandInventory(String currency) async {
    final r = await _client.rpc('expand_inventory', params: {'p_currency': currency});
    return Map<String, dynamic>.from(r as Map);
  }
}
