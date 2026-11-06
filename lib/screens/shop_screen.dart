import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/auction.dart';
import '../models/docs_status.dart';
import '../models/inventory_entry.dart';
import '../models/merchant_offer.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';

class ShopScreen extends StatefulWidget {
  final int playerMoney;
  final VoidCallback onPurchaseSuccess;

  const ShopScreen({
    super.key,
    required this.playerMoney,
    required this.onPurchaseSuccess,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

enum _Tab { black, normal, merchant, docs, auction }

class _ShopScreenState extends State<ShopScreen> {
  // --- Design System ---
  static const bgDark = Color(0xFF0A0A0A);
  static const cardDark = Color(0xFF141414);
  static const cardElevated = Color(0xFF1A1A1A);
  static const borderGrey = Color(0xFF262626);
  static const bloodRed = Color(0xFFE11D48);
  static const gold = Color(0xFFF59E0B);
  static const neonGreen = Color(0xFF00FF88);
  static const textMuted = Color(0xFFA3A3A3);

  final _svc = ShopService();
  _Tab _tab = _Tab.black;

  List<ShopItem> _allItems = [];
  InventorySnapshot _inv = InventorySnapshot(items: [], used: 0, max: 50);
  MerchantOffer? _merchant;
  DocsStatus? _docs;
  List<Auction> _auctions = [];
  Map<String, double> _dailyPrices = {};

  bool _loading = true;
  int? _busyItemId;
  String _category = 'ALLE';
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        _svc.getItems(),
        _svc.getMyInventory(),
        _svc.getMerchantOffer().catchError((_) => null),
        _svc.getDocsStatus().catchError((_) => null),
        _svc.getActiveAuctions().catchError((_) => <Auction>[]),
        _svc.getDailyPrices().catchError((_) => <String, double>{}),
      ]);
      if (!mounted) return;
      setState(() {
        _allItems = res[0] as List<ShopItem>;
        _inv = res[1] as InventorySnapshot;
        _merchant = res[2] as MerchantOffer?;
        _docs = res[3] as DocsStatus?;
        _auctions = res[4] as List<Auction>;
        _dailyPrices = res[5] as Map<String, double>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack('Fehler: $e', ok: false);
    }
  }

  Future<void> _refreshInventoryAndProfile() async {
    try {
      final inv = await _svc.getMyInventory();
      if (!mounted) return;
      setState(() => _inv = inv);
      widget.onPurchaseSuccess();
    } catch (_) {}
  }

  List<ShopItem> _itemsFor(String type) =>
      _allItems.where((i) => i.shopType == type).toList();

  int _owned(String name) =>
      _inv.items.where((e) => e.name == name).fold(0, (a, b) => a + b.quantity);

  Map<int, int> get _invByItemId => {
    for (final e in _inv.items) e.itemId: e.quantity,
  };

  IconData _iconFor(String n) {
    switch (n) {
    // Waffen
      case 'knife': return Icons.cut; // Machete/Messer
      case 'pistol': return Icons.gps_fixed; // Schusswaffen
      case 'bat': return Icons.sports_baseball; // Schläger

    // Rüstung
      case 'vest': return Icons.shield;

    // Fahrzeuge
      case 'car': return Icons.directions_car;

    // Drogen
      case 'drug': return Icons.science;

    // Materialien & Boosts (Normaler Shop)
      case 'medkit': return Icons.medical_services; // Erste-Hilfe
      case 'bolt': return Icons.bolt; // Energie
      case 'tool': return Icons.build; // Dietrich / Schweißgerät
      case 'ring': return Icons.diamond; // Diamanten / Wertgegenstände

      default: return Icons.inventory_2;
    }
  }

  Color _rarityColor(String r) {
    switch (r) {
      case 'legendary':
        return const Color(0xFFFBBF24); // Gold
      case 'epic':
        return const Color(0xFFA855F7); // Lila
      case 'rare':
        return const Color(0xFF3B82F6); // Blau
      default:
        return const Color(0xFF4B5563); // Grau (common)
    }
  }

  void _snack(String msg, {required bool ok}) {
    if (!mounted) return;
    final accent = ok ? neonGreen : bloodRed;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardElevated,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: accent.withValues(alpha: 0.6)),
        ),
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle : Icons.error_outline,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.oswald(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Actions -------------------
  Future<void> _buy(ShopItem item, {int qty = 1}) async {
    final price = _effectivePrice(item) * qty;
    if (widget.playerMoney < price) {
      _snack('Nicht genug Bargeld!', ok: false);
      return;
    }

    if (price >= 5000 && qty > 0) {
      final ok = await _confirm(
        title: 'KAUF BESTÄTIGEN',
        body: '${qty}× ${item.name} für \$$price kaufen?',
      );
      if (!ok) return;
    }

    setState(() => _busyItemId = item.id);
    try {
      final res = await _svc.buyItem(item.id, qty: qty);
      _snack(res['message']?.toString() ?? '', ok: res['success'] == true);
      if (res['success'] == true) await _refreshInventoryAndProfile();
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  Future<void> _sellMerchant(ShopItem item, int qty) async {
    setState(() => _busyItemId = item.id);
    try {
      final res = await _svc.sellToMerchant(item.id, qty: qty);
      _snack(res['message']?.toString() ?? '', ok: res['success'] == true);
      if (res['success'] == true) await _refreshInventoryAndProfile();
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  Future<void> _sellAll() async {
    setState(() => _loading = true);
    try {
      final res = await _svc.sellAllToMerchant();
      _snack(res['message']?.toString() ?? '', ok: res['success'] == true);
      if (res['success'] == true) await _refreshInventoryAndProfile();
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sellDocs(ShopItem item, int qty) async {
    setState(() => _busyItemId = item.id);
    try {
      final res = await _svc.sellToDocs(item.id, qty: qty);
      _snack(res['message']?.toString() ?? '', ok: res['success'] == true);
      if (res['success'] == true) await _refreshInventoryAndProfile();
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderGrey),
        ),
        title: Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
        ),
        content: Text(
          body,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ABBRECHEN',
              style: GoogleFonts.oswald(color: textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: bloodRed),
            child: Text(
              'BESTÄTIGEN',
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  int _effectivePrice(ShopItem item) {
    if (item.shopType != 'black') return item.price;
    final f = _dailyPrices[item.id.toString()] ?? 1.0;
    return (item.price * f).floor();
  }

  // ------------------- Build -------------------
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        if (!_loading && _tab == _Tab.black && _dailyPrices.isNotEmpty)
          _dailyPriceBanner(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: bloodRed))
              : _body(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: borderGrey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.storefront, color: gold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARKT',
                      style: GoogleFonts.oswald(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Kaufen · Verkaufen · Handeln',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _hudStatBox(
                  Icons.payments,
                  'BARGELD',
                  '\$${widget.playerMoney}',
                  neonGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _hudStatBox(
                  Icons.inventory_2,
                  'SLOTS',
                  '${_inv.used}/${_inv.max}',
                  _inv.used >= _inv.max ? bloodRed : gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hudStatBox(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), cardDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 48, color: color.withValues(alpha: 0.05)),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.robotoMono(
                        fontSize: 8,
                        color: textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      (_Tab.black, 'SCHWARZ', Icons.gavel),
      (_Tab.normal, 'NORMAL', Icons.store),
      (_Tab.merchant, 'HÄNDLER', Icons.local_shipping),
      (_Tab.docs, 'DOCS', Icons.local_hospital),
      (_Tab.auction, 'AUKTION', Icons.gavel_outlined),
    ];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (tab, label, icon) = tabs[i];
          final sel = _tab == tab;
          final dot =
              (tab == _Tab.merchant) ||
              (tab == _Tab.docs && (_docs?.isOpen ?? false)) ||
              (tab == _Tab.auction && _auctions.isNotEmpty);

          return GestureDetector(
            onTap: () => setState(() {
              _tab = tab;
              _category = 'ALLE';
            }),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? gold.withValues(alpha: 0.15) : cardDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sel ? gold : borderGrey),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: gold.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: sel ? gold : textMuted),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: sel ? Colors.white : textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (dot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: bloodRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgDark, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dailyPriceBanner() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: gold.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: gold.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.trending_up, color: gold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Tagespreise aktiv — Preise schwanken täglich',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: gold),
          ),
        ),
      ],
    ),
  );

  Widget _body() {
    switch (_tab) {
      case _Tab.black:
        return _shopList(_itemsFor('black'), priceFactorMap: _dailyPrices);
      case _Tab.normal:
        return _shopList(_itemsFor('normal'));
      case _Tab.merchant:
        return _merchantView();
      case _Tab.docs:
        return _docsView();
      case _Tab.auction:
        return _auctionView();
    }
  }

  // ------------------- Shop-Liste -------------------
  Widget _shopList(
    List<ShopItem> items, {
    Map<String, double>? priceFactorMap,
  }) {
    if (items.isEmpty) return _empty('KEINE ARTIKEL');
    final cats = <String>{
      'ALLE',
      ...items.map((i) => i.category.toUpperCase()),
    }.toList();
    final filtered = _category == 'ALLE'
        ? items
        : items.where((i) => i.category.toUpperCase() == _category).toList();
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = cats[i];
              final sel = c == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? bloodRed.withValues(alpha: 0.15) : cardDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sel ? bloodRed : borderGrey),
                  ),
                  child: Center(
                    child: Text(
                      c,
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: sel ? Colors.white : textMuted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _empty('KEINE ARTIKEL IN DIESER KATEGORIE')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _itemCard(filtered[i], priceFactorMap: priceFactorMap),
                ),
        ),
      ],
    );
  }

  Widget _itemCard(ShopItem item, {Map<String, double>? priceFactorMap}) {
    final busy = _busyItemId == item.id;
    final factor = priceFactorMap?[item.id.toString()] ?? 1.0;
    final effPrice = (item.price * factor).floor();
    final canAfford = widget.playerMoney >= effPrice;
    final isDocs = item.shopType == 'docs';
    final locked = isDocs && !(_docs?.isOpen ?? false);
    final isDrug = item.category.toLowerCase() == 'drugs';
    final owned = _invByItemId[item.id] ?? 0;
    final rarityColor = _rarityColor(item.rarity);

    return Container(
      decoration: BoxDecoration(
        color: cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarityColor.withValues(alpha: 0.3)),
        // Rarity Glow links
        gradient: LinearGradient(
          colors: [rarityColor.withValues(alpha: 0.05), cardElevated],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Box
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rarityColor.withValues(alpha: 0.3)),
              ),
              child: Icon(
                _iconFor(item.iconName),
                color: rarityColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name.toUpperCase(),
                          style: GoogleFonts.oswald(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (owned > 0) _badge('×$owned', neonGreen),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Rarity Badge
                      _badge(item.rarity.toUpperCase(), rarityColor),

                      // Fahrzeuge
                      if (item.vehicleSpeed > 0)
                        _statBadge(Icons.speed, '${item.vehicleSpeed} SPEED', const Color(0xFF3B82F6)),
                      if (item.vehicleCapacity > 0)
                        _statBadge(Icons.inventory_2, '${item.vehicleCapacity} SLOTS', const Color(0xFFF59E0B)),

                      // Waffen
                      if (item.damage > 0)
                        _statBadge(Icons.gavel, '${item.damage} DMG', bloodRed),

                      // Rüstung
                      if (item.armor > 0)
                        _statBadge(Icons.shield, '${item.armor} ARM', const Color(0xFF3B82F6)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Price Row
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: canAfford && !locked ? neonGreen : bloodRed,
                      ),
                      Text(
                        '$effPrice',
                        style: GoogleFonts.robotoMono(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: canAfford && !locked ? neonGreen : bloodRed,
                        ),
                      ),
                      if (factor != 1.0) ...[
                        const SizedBox(width: 6),
                        _factorChip(factor),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Buy Button
            _buyControls(
              item,
              busy: busy,
              canAfford: canAfford,
              locked: locked,
              isDrug: isDrug,
              effPrice: effPrice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _factorChip(double f) {
    final up = f > 1.05, down = f < 0.95;
    final color = up
        ? bloodRed
        : down
        ? neonGreen
        : gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '${up ? "+" : ""}${((f - 1) * 100).toStringAsFixed(0)}%',
        style: GoogleFonts.robotoMono(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: c.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: c),
        const SizedBox(width: 3),
        Text(
          t,
          style: GoogleFonts.robotoMono(
            fontSize: 9,
            color: c,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: c.withValues(alpha: 0.4)),
    ),
    child: Text(
      t,
      style: GoogleFonts.robotoMono(
        fontSize: 9,
        color: c,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buyControls(
    ShopItem item, {
    required bool busy,
    required bool canAfford,
    required bool locked,
    required bool isDrug,
    required int effPrice,
  }) {
    if (busy)
      return const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: bloodRed),
          ),
        ),
      );

    final enabled = canAfford && !locked && !isDrug;
    final freeSlots = _inv.max - _inv.used;
    final slotsOk = freeSlots > 0;
    final reallyEnabled = enabled && slotsOk;

    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: reallyEnabled ? () => _buy(item) : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: reallyEnabled
                      ? bloodRed.withValues(alpha: 0.15)
                      : cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: reallyEnabled ? bloodRed : borderGrey,
                  ),
                  boxShadow: reallyEnabled
                      ? [
                          BoxShadow(
                            color: bloodRed.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  locked
                      ? Icons.lock
                      : !slotsOk
                      ? Icons.inventory
                      : Icons.shopping_cart_checkout,
                  size: 22,
                  color: reallyEnabled
                      ? bloodRed
                      : textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
        if (reallyEnabled) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _buyWithQty(item, effPrice),
            child: Text(
              '+MENGE',
              style: GoogleFonts.robotoMono(
                fontSize: 9,
                color: textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _buyWithQty(ShopItem item, int effPrice) async {
    final free = _inv.max - _inv.used;
    final maxAffordable = (widget.playerMoney / effPrice).floor();
    final maxQty = free < maxAffordable ? free : maxAffordable;
    if (maxQty < 2) {
      await _buy(item);
      return;
    }
    final qty = await _qtyPicker(
      title: 'MENGE WÄHLEN',
      max: maxQty,
      unitPrice: effPrice,
    );
    if (qty > 0) await _buy(item, qty: qty);
  }

  Future<int> _qtyPicker({
    required String title,
    required int max,
    required int unitPrice,
  }) async {
    int q = 1;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          backgroundColor: cardElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderGrey),
          ),
          title: Text(
            title,
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: bloodRed),
                    onPressed: () => setSt(() => q = (q - 1).clamp(1, max)),
                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Center(
                      child: Text(
                        '$q',
                        style: GoogleFonts.rajdhani(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: neonGreen),
                    onPressed: () => setSt(() => q = (q + 1).clamp(1, max)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Gesamt: \$${q * unitPrice}',
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  color: neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 0),
              child: Text(
                'ABBRECHEN',
                style: GoogleFonts.oswald(color: textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: bloodRed),
              onPressed: () => Navigator.pop(ctx, q),
              child: Text(
                'KAUFEN',
                style: GoogleFonts.oswald(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return res ?? 0;
  }

  // ------------------- Händler-View -------------------
  Widget _merchantView() {
    if (_merchant == null) return _empty('KEIN HÄNDLER HEUTE');
    final offer = _merchant!;

    final buyableItems =
        _allItems
            .where(
              (i) => offer.boughtItemIds.contains(i.id) && _owned(i.name) > 0,
            )
            .toList()
          ..sort((a, b) {
            final fa = offer.priceFactors[a.id] ?? 1.0;
            final fb = offer.priceFactors[b.id] ?? 1.0;
            return fb.compareTo(fa);
          });

    final remaining = offer.expiresAt.difference(DateTime.now());
    final timeLeft = remaining.isNegative
        ? 'ABGELAUFEN'
        : '${remaining.inHours}h ${remaining.inMinutes % 60}m';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: gold.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: gold.withValues(alpha: 0.1), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.local_shipping, color: gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.merchantName.toUpperCase(),
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_typeLabel(offer.merchantType)} · kauft Drogen',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bloodRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: bloodRed.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: bloodRed, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      timeLeft,
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: bloodRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (buyableItems.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sellAll,
              icon: const Icon(Icons.sell, size: 18),
              label: Text(
                'ALLES VERKAUFEN',
                style: GoogleFonts.oswald(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonGreen.withValues(alpha: 0.15),
                foregroundColor: neonGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: neonGreen),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (buyableItems.isEmpty)
          _infoBox('Du hast keine Drogen, die er kauft.')
        else
          ...buyableItems.map((item) {
            final factor = offer.priceFactors[item.id] ?? 1.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _sellCard(
                item: item,
                owned: _owned(item.name),
                unitPrice: (item.price * factor).floor(),
                factor: factor,
                isDocs: false,
                busy: _busyItemId == item.id,
                onSell: (q) => _sellMerchant(item, q),
              ),
            );
          }),
      ],
    );
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'weed_buyer':
        return 'Weed-Spezialist';
      case 'coke_buyer':
        return 'Koks-Spezialist';
      case 'cheap':
        return 'Schnäppchenjäger';
      case 'generous':
        return 'Großzügig';
      default:
        return 'Allrounder';
    }
  }

  // ------------------- Docs-View -------------------
  Widget _docsView() {
    if (!(_docs?.isOpen ?? false)) {
      final open = _docs?.opensAt;
      final cd = open != null
          ? _formatDuration(open.difference(DateTime.now()))
          : '—';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, color: textMuted, size: 56),
              const SizedBox(height: 16),
              Text(
                'DOCS GESCHLOSSEN',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Öffnet am Wochenende (Sa–So)',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Öffnet in $cd',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    final docs = _itemsFor('docs');
    final sellable = _allItems
        .where((i) => i.category.toLowerCase() == 'drugs' && _owned(i.name) > 0)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoBox(
          'Docs haben geöffnet! Seltene Ware & Drogen-Ankauf.',
          color: gold,
        ),
        const SizedBox(height: 12),
        if (docs.isNotEmpty) ...[
          Text(
            'SELTENE ARTIKEL',
            style: GoogleFonts.oswald(
              fontSize: 13,
              letterSpacing: 2,
              color: gold,
            ),
          ),
          const SizedBox(height: 8),
          ...docs.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _itemCard(i),
            ),
          ),
        ],
        if (sellable.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'DROGEN VERKAUFEN',
            style: GoogleFonts.oswald(
              fontSize: 13,
              letterSpacing: 2,
              color: neonGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...sellable.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _sellCard(
                item: item,
                owned: _owned(item.name),
                unitPrice: (item.price * 1.2).floor(),
                factor: 1.2,
                isDocs: true,
                busy: _busyItemId == item.id,
                onSell: (q) => _sellDocs(item, q),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ------------------- Auktions-View -------------------
  Widget _auctionView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoBox('Spieler-Handel: Biete oder kaufe direkt.', color: gold),
        const SizedBox(height: 12),
        if (_auctions.isEmpty)
          _empty('KEINE AKTIVEN AUKTIONEN')
        else
          ..._auctions.map((a) {
            final item = _allItems.firstWhere(
              (i) => i.id == a.itemId,
              orElse: () => ShopItem(
                id: -1,
                name: 'Unbekannt',
                description: '',
                price: 0,
                category: '',
                iconName: 'default',
                shopType: 'black',
              ),
            );
            final rem = a.expiresAt.difference(DateTime.now());
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: GoogleFonts.oswald(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _badge('×${a.quantity}', gold),
                      const Spacer(),
                      Text(
                        '${rem.inHours}h ${rem.inMinutes % 60}m',
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: bloodRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Aktuell: \$${a.currentBid}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: neonGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (a.buyoutPrice != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Sofort: \$${a.buyoutPrice}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: gold),
                            foregroundColor: gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _bidDialog(a),
                          child: Text(
                            'BIETEN',
                            style: GoogleFonts.oswald(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (a.buyoutPrice != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bloodRed,
                            ),
                            onPressed: () => _buyout(a),
                            child: Text(
                              'SOFORT',
                              style: GoogleFonts.oswald(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Future<void> _bidDialog(Auction a) async {
    final ctrl = TextEditingController(text: '${a.currentBid + 50}');
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderGrey),
        ),
        title: Text(
          'GEBOT',
          style: GoogleFonts.oswald(color: gold, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: GoogleFonts.robotoMono(color: neonGreen),
            filled: true,
            fillColor: cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: gold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 0),
            child: Text(
              'ABBRECHEN',
              style: GoogleFonts.oswald(color: textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: gold),
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text) ?? 0),
            child: Text(
              'BIETEN',
              style: GoogleFonts.oswald(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (res == null || res <= a.currentBid) return;
    try {
      final r = await _svc.bidOnAuction(a.id, res);
      _snack(r['message']?.toString() ?? '', ok: r['success'] == true);
      if (r['success'] == true) {
        widget.onPurchaseSuccess();
        _load();
      }
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    }
  }

  Future<void> _buyout(Auction a) async {
    final ok = await _confirm(
      title: 'SOFORTKAUF',
      body: '${a.quantity}× für \$${a.buyoutPrice} kaufen?',
    );
    if (!ok) return;
    try {
      final r = await _svc.buyoutAuction(a.id);
      _snack(r['message']?.toString() ?? '', ok: r['success'] == true);
      if (r['success'] == true) {
        widget.onPurchaseSuccess();
        await _refreshInventoryAndProfile();
        _load();
      }
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    }
  }

  // ------------------- Sell-Card mit Qty-Picker -------------------
  Widget _sellCard({
    required ShopItem item,
    required int owned,
    required int unitPrice,
    required double factor,
    required bool isDocs,
    required bool busy,
    required void Function(int qty) onSell,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: neonGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: neonGreen.withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.science, color: neonGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      style: GoogleFonts.oswald(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '×$owned im Inventar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$$unitPrice / Stk',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: neonGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!isDocs) _dealChip(factor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (owned > 0)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: neonGreen),
                      foregroundColor: neonGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: busy
                        ? null
                        : () => _showSellQty(
                            item,
                            owned,
                            unitPrice,
                            (q) => onSell(q),
                          ),
                    child: Text(
                      'VERKAUFEN',
                      style: GoogleFonts.oswald(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: gold),
                      foregroundColor: gold,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: busy ? null : () => onSell(owned),
                    child: Text(
                      'ALLE',
                      style: GoogleFonts.oswald(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _dealChip(double f) {
    String label;
    Color color;
    if (f >= 1.20) {
      label = 'HEISSER DEAL';
      color = neonGreen;
    } else if (f >= 1.05) {
      label = 'GUT';
      color = const Color(0xFF84CC16);
    } else if (f >= 0.95) {
      label = 'OK';
      color = gold;
    } else {
      label = 'SCHLECHT';
      color = bloodRed;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label (${((f - 1) * 100).toStringAsFixed(0)}%)',
        style: GoogleFonts.robotoMono(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showSellQty(
    ShopItem item,
    int max,
    int unitPrice,
    void Function(int) onSell,
  ) async {
    final q = await _qtyPicker(
      title: 'MENGE VERKAUFEN',
      max: max,
      unitPrice: unitPrice,
    );
    if (q > 0) onSell(q);
  }

  // ------------------- Helpers -------------------
  String _formatDuration(Duration d) {
    if (d.isNegative) return 'jetzt';
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }

  Widget _infoBox(String text, {Color color = textMuted}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cardDark,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: color),
    ),
  );

  Widget _empty(String msg) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: textMuted.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 12),
        Text(
          msg,
          style: GoogleFonts.oswald(
            fontSize: 14,
            letterSpacing: 1.5,
            color: textMuted,
          ),
        ),
      ],
    ),
  );
}
