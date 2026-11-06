// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/docs_status.dart';
import '../models/inventory_entry.dart';
import '../models/merchant_offer.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // --- Design System ---
  static const bgDark = Color(0xFF0A0A0A);
  static const cardDark = Color(0xFF141414);
  static const cardElevated = Color(0xFF1A1A1A);
  static const borderGrey = Color(0xFF262626);
  static const bloodRed = Color(0xFFE11D48);
  static const gold = Color(0xFFF59E0B);
  static const neonGreen = Color(0xFF00FF88);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFFA855F7);
  static const textMuted = Color(0xFFA3A3A3);

  final _svc = ShopService();

  InventorySnapshot _inv = InventorySnapshot(items: [], used: 0, max: 50);
  Map<int, ShopItem> _itemDefs = {};
  MerchantOffer? _merchant;
  DocsStatus? _docs;

  bool _loading = true;
  String _category = 'ALLE';
  int? _busyItemId;

  // Ausrüstung
  InventoryEntry? _equippedWeapon;
  InventoryEntry? _equippedArmor;
  InventoryEntry? _equippedVehicle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        _svc.getMyInventory(),
        _svc.getItems(),
        _svc.getMerchantOffer().catchError((_) => null),
        _svc.getDocsStatus().catchError((_) => null),
      ]);
      if (!mounted) return;

      final inv = res[0] as InventorySnapshot;
      final itemDefs = {for (final i in res[1] as List<ShopItem>) i.id: i};

      _equippedWeapon = inv.items.firstWhere(
            (e) => itemDefs[e.itemId]?.category.toLowerCase() == 'weapons',
        orElse: () => InventoryEntry(itemId: -1, name: '', iconName: '', rarity: '', category: '', quantity: 0),
      );
      _equippedArmor = inv.items.firstWhere(
            (e) => itemDefs[e.itemId]?.category.toLowerCase() == 'armor',
        orElse: () => InventoryEntry(itemId: -2, name: '', iconName: '', rarity: '', category: '', quantity: 0),
      );

      setState(() {
        _inv = inv;
        _itemDefs = itemDefs;
        _merchant = res[2] as MerchantOffer?;
        _docs = res[3] as DocsStatus?;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack('Fehler: $e', ok: false);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  // WICHTIG: Anzahl der belegten Slots = Anzahl der unterschiedlichen Items
  int get _usedSlots => _inv.items.length;

  List<InventoryEntry> get _filtered {
    var list = _inv.items;
    if (_category != 'ALLE') {
      list = list.where((e) => _itemDefs[e.itemId]?.category.toUpperCase() == _category).toList();
    }
    final sorted = [...list];
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  Color _rarityColor(String r) {
    switch (r) {
      case 'legendary': return gold;
      case 'epic': return purple;
      case 'rare': return blue;
      default: return textMuted;
    }
  }

  IconData _iconForName(String iconName) {
    switch (iconName) {
      case 'knife': return Icons.cut;
      case 'pistol': return Icons.gps_fixed;
      case 'bat': return Icons.sports_baseball;
      case 'vest': return Icons.shield;
      case 'car': return Icons.directions_car;
      case 'drug': return Icons.science;
      case 'medkit': return Icons.medical_services;
      case 'bolt': return Icons.bolt;
      case 'tool': return Icons.build;
      case 'ring': return Icons.diamond;
      default: return Icons.inventory_2;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat.toLowerCase()) {
      case 'drugs': return 'DROGEN';
      case 'weapons': return 'WAFFEN';
      case 'armor': return 'RÜSTUNG';
      case 'vehicles': return 'FAHRZEUGE';
      case 'misc': return 'SONSTIGES';
      default: return cat.toUpperCase();
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
        content: Text(
          msg,
          style: GoogleFonts.oswald(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'INVENTAR',
          style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: bloodRed),
            tooltip: 'Müll (Gewöhnlich) verkaufen',
            onPressed: _sellJunk,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: textMuted),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: bloodRed))
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // LINKS: INVENTAR
          // ==========================================
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _inventoryHeader(),
                _categoryFilters(),
                Expanded(child: _inventoryGrid()),
              ],
            ),
          ),
          Container(width: 1, color: borderGrey),
          // ==========================================
          // RECHTS: CHARAKTER
          // ==========================================
          Expanded(
            flex: 4,
            child: _characterPanel(),
          ),
        ],
      ),
    );
  }

  // --- LINKS: Header & Filter ---
  Widget _inventoryHeader() {
    final used = _usedSlots; // Anzahl der belegten Slots (Stacks zählen als 1)
    final max = _inv.max;
    final ratio = max == 0 ? 0.0 : (used / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SLOTS: $used/$max',
                style: GoogleFonts.robotoMono(fontSize: 10, color: gold, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: _showExpandDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: gold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 12, color: gold),
                      const SizedBox(width: 4),
                      Text('ERWEITERN', style: GoogleFonts.oswald(fontSize: 9, color: gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: cardDark,
              color: ratio >= 0.9 ? bloodRed : neonGreen,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilters() {
    final cats = ['ALLE', 'WAFFEN', 'RÜSTUNG', 'DROGEN', 'FAHRZEUGE', 'SONSTIGES'];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final c = cats[i];
          final sel = c == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: sel ? gold.withValues(alpha: 0.15) : cardDark,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: sel ? gold : borderGrey),
              ),
              child: Center(
                child: Text(
                  c,
                  style: GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.bold, color: sel ? Colors.white : textMuted),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- LINKS: Raster ---
  Widget _inventoryGrid() {
    final items = _filtered;
    final maxSlots = _inv.max;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: maxSlots,
      itemBuilder: (_, index) {
        if (index < items.length) {
          return _itemSlot(items[index]);
        }
        return _emptySlot();
      },
    );
  }

  Widget _emptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: cardDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderGrey.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _itemSlot(InventoryEntry entry) {
    final def = _itemDefs[entry.itemId];
    final rarityColor = _rarityColor(entry.rarity);
    final isWeapon = def?.category.toLowerCase() == 'weapons';
    final isArmor = def?.category.toLowerCase() == 'armor';
    final isEquipable = isWeapon || isArmor;

    final isEquipped = (_equippedWeapon?.itemId == entry.itemId) ||
        (_equippedArmor?.itemId == entry.itemId);

    Widget content = Container(
      decoration: BoxDecoration(
        color: isEquipped ? rarityColor.withValues(alpha: 0.15) : cardElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isEquipped ? rarityColor : rarityColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(_iconForName(entry.iconName), color: rarityColor, size: 18),
          ),
          if (entry.quantity > 1)
            Positioned(
              bottom: 0,
              right: 1,
              child: Text(
                '${entry.quantity}',
                style: GoogleFonts.robotoMono(fontSize: 8, color: neonGreen, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );

    if (isEquipable) {
      content = Draggable<InventoryEntry>(
        data: entry,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: cardElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: rarityColor, width: 2),
              boxShadow: [BoxShadow(color: rarityColor.withValues(alpha: 0.5), blurRadius: 8)],
            ),
            child: Center(child: Icon(_iconForName(entry.iconName), color: rarityColor, size: 24)),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: content),
        child: content,
      );
    }

    return Tooltip(
      message: '${entry.name}\n${_categoryLabel(entry.category)} · ${entry.rarity.toUpperCase()}',
      child: GestureDetector(
        onDoubleTap: isEquipable ? () => _quickEquip(entry, def) : null,
        child: InkWell(
          onTap: () => _showItemSheet(entry, def),
          borderRadius: BorderRadius.circular(4),
          child: content,
        ),
      ),
    );
  }

  void _quickEquip(InventoryEntry entry, ShopItem? def) {
    final isWeapon = def?.category.toLowerCase() == 'weapons';
    final isArmor = def?.category.toLowerCase() == 'armor';
    if (!isWeapon && !isArmor) return;

    setState(() {
      if (isWeapon) _equippedWeapon = entry;
      if (isArmor) _equippedArmor = entry;
    });
    _snack('${entry.name} schnell ausgerüstet!', ok: true);
  }

  // --- RECHTS: Charakter (Mit Stats) ---
  Widget _characterPanel() {
    int totalDmg = 0, totalArm = 0;
    if (_equippedWeapon != null && _equippedWeapon!.itemId > 0) {
      totalDmg = _itemDefs[_equippedWeapon!.itemId]?.damage ?? 0;
    }
    if (_equippedArmor != null && _equippedArmor!.itemId > 0) {
      totalArm = _itemDefs[_equippedArmor!.itemId]?.armor ?? 0;
    }

    int powerLevel = (totalDmg * 2) + totalArm + 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: borderGrey)),
            ),
            child: Text(
              'CHARAKTER',
              style: GoogleFonts.oswald(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: gold),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bloodRed.withValues(alpha: 0.3)),
              gradient: RadialGradient(
                colors: [bloodRed.withValues(alpha: 0.15), cardDark],
                radius: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 64, color: textMuted),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bloodRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bloodRed.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'POWER: $powerLevel',
                    style: GoogleFonts.rajdhani(fontSize: 12, color: bloodRed, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _bigStatBadge(Icons.gavel, '$totalDmg', 'DMG', bloodRed)),
              const SizedBox(width: 8),
              Expanded(child: _bigStatBadge(Icons.shield, '$totalArm', 'ARM', blue)),
            ],
          ),

          const SizedBox(height: 16),

          _dragTargetSlot('WAFFE', Icons.gps_fixed, 'weapons', _equippedWeapon),
          const SizedBox(height: 8),
          _dragTargetSlot('RÜSTUNG', Icons.shield, 'armor', _equippedArmor),
          const SizedBox(height: 8),
          _dragTargetSlot('FAHRZEUG', Icons.directions_car, 'vehicles', _equippedVehicle),
        ],
      ),
    );
  }

  Widget _bigStatBadge(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.rajdhani(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.robotoMono(fontSize: 8, color: textMuted)),
        ],
      ),
    );
  }

  Widget _dragTargetSlot(String label, IconData icon, String requiredCategory, InventoryEntry? equipped) {
    final hasItem = equipped != null && equipped.itemId > 0;
    final rarityColor = hasItem ? _rarityColor(equipped.rarity) : borderGrey;

    return DragTarget<InventoryEntry>(
      onAcceptWithDetails: (details) {
        final entry = details.data;
        final def = _itemDefs[entry.itemId];
        if (def?.category.toLowerCase() == requiredCategory) {
          setState(() {
            if (requiredCategory == 'weapons') _equippedWeapon = entry;
            if (requiredCategory == 'armor') _equippedArmor = entry;
            if (requiredCategory == 'vehicles') _equippedVehicle = entry;
          });
          _snack('${entry.name} ausgerüstet!', ok: true);
        } else {
          _snack('Falscher Slot für dieses Item!', ok: false);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final borderColor = isHovering ? neonGreen : (hasItem ? rarityColor.withValues(alpha: 0.5) : borderGrey);

        return InkWell(
          onTap: hasItem ? () => _unequip(equipped) : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHovering ? neonGreen.withValues(alpha: 0.1) : (hasItem ? cardElevated : cardDark.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: isHovering ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasItem ? rarityColor.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: hasItem ? rarityColor.withValues(alpha: 0.3) : borderGrey),
                  ),
                  child: Icon(hasItem ? _iconForName(equipped.iconName) : icon, size: 20, color: hasItem ? rarityColor : borderGrey),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: GoogleFonts.robotoMono(fontSize: 8, color: textMuted, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(
                        hasItem ? equipped.name.toUpperCase() : 'LEER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.oswald(fontSize: 11, fontWeight: FontWeight.bold, color: hasItem ? Colors.white : textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _unequip(InventoryEntry entry) {
    setState(() {
      if (_equippedWeapon?.itemId == entry.itemId) _equippedWeapon = null;
      if (_equippedArmor?.itemId == entry.itemId) _equippedArmor = null;
      if (_equippedVehicle?.itemId == entry.itemId) _equippedVehicle = null;
    });
    _snack('${entry.name} abgelegt.', ok: true);
  }

  // ============================================================
  // BOTTOM SHEET & DIALOGE
  // ============================================================

  Future<void> _sellJunk() async {
    final junkItems = _inv.items.where((e) => e.rarity == 'common').toList();
    if (junkItems.isEmpty) {
      _snack('Kein Müll (Gewöhnliche Items) zum Verkaufen gefunden.', ok: false);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardElevated,
        title: Text('MÜLL VERKAUFEN', style: GoogleFonts.oswald(color: bloodRed)),
        content: Text('Willst du alle ${junkItems.length} gewöhnlichen Items verkaufen?', style: GoogleFonts.plusJakartaSans(color: textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('ABBRECHEN', style: GoogleFonts.oswald(color: textMuted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('VERKAUFEN', style: GoogleFonts.oswald(color: bloodRed))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      for (var item in junkItems) {
        await _svc.sellToMerchant(item.itemId, qty: item.quantity);
      }
      _snack('Müll erfolgreich verkauft!', ok: true);
      await _load();
    } catch (e) {
      _snack('Fehler beim Verkaufen: $e', ok: false);
      setState(() => _loading = false);
    }
  }

  void _showExpandDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardElevated,
        title: Text('SLOTS ERWEITERN', style: GoogleFonts.oswald(color: gold, fontWeight: FontWeight.bold)),
        content: Text('Erweitere dein Inventar um +10 Slots.', style: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); _expandInventory('cash'); },
            child: Text('10.000 \$ (CASH)', style: GoogleFonts.oswald(color: neonGreen)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _expandInventory('crimcoins'); },
            child: Text('50 COINS', style: GoogleFonts.oswald(color: purple)),
          ),
        ],
      ),
    );
  }

  Future<void> _expandInventory(String currency) async {
    try {
      final res = await _svc.expandInventory(currency);
      _snack(res['message']?.toString() ?? 'Slots erweitert!', ok: true);
      _load();
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    }
  }

  void _showItemSheet(InventoryEntry entry, ShopItem? def) {
    final rarityColor = _rarityColor(entry.rarity);
    final isDrug = (def?.category.toLowerCase() ?? '') == 'drugs';
    final isWeapon = (def?.category.toLowerCase() ?? '') == 'weapons';
    final isArmor = (def?.category.toLowerCase() ?? '') == 'armor';
    final isEquipable = isWeapon || isArmor;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(_iconForName(entry.iconName), color: rarityColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name.toUpperCase(), style: GoogleFonts.oswald(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${_categoryLabel(entry.category)} · ×${entry.quantity}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (def != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (def.damage > 0) _statChip(Icons.gavel, '${def.damage} DMG', bloodRed),
                  if (def.armor > 0) _statChip(Icons.shield, '${def.armor} ARM', blue),
                  if (def.vehicleSpeed > 0) _statChip(Icons.speed, '${def.vehicleSpeed} SPEED', blue),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isEquipable) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _svc.equipItem(entry.itemId);
                    setState(() {
                      if (isWeapon) _equippedWeapon = entry;
                      if (isArmor) _equippedArmor = entry;
                    });
                    _snack('Erfolgreich ausgerüstet!', ok: true);
                  } catch (e) {
                    _snack('Fehler beim Ausrüsten: $e', ok: false);
                  }
                },
                icon: const Icon(Icons.check_circle, color: Colors.black),
                label: Text('AUSRÜSTEN', style: GoogleFonts.oswald(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
              ),
              const SizedBox(height: 8),
            ],
            if (isDrug && _merchant != null)
              ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); _sellFlow(entry); },
                icon: const Icon(Icons.attach_money, color: Colors.black),
                label: Text('AN HÄNDLER VERKAUFEN', style: GoogleFonts.oswald(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: gold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.robotoMono(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _sellFlow(InventoryEntry entry) async {
    int q = 1;
    final max = entry.quantity;

    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          backgroundColor: cardElevated,
          title: Text('VERKAUFEN', style: GoogleFonts.oswald(color: gold, fontSize: 14)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle, color: bloodRed), onPressed: () => setSt(() => q = (q - 1).clamp(1, max))),
              Text('$q', style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(icon: const Icon(Icons.add_circle, color: neonGreen), onPressed: () => setSt(() => q = (q + 1).clamp(1, max))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, q), child: Text('VERKAUFEN', style: GoogleFonts.oswald(color: neonGreen))),
          ],
        ),
      ),
    );

    if (res == null || res <= 0) return;

    setState(() => _busyItemId = entry.itemId);
    try {
      final r = await _svc.sellToMerchant(entry.itemId, qty: res);
      _snack(r['message']?.toString() ?? 'Verkauft', ok: r['success'] == true);
      if (r['success'] == true) await _load();
    } catch (e) {
      _snack('Fehler: $e', ok: false);
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }
}