class InventoryEntry {
  final int itemId;
  final String name;
  final String iconName;
  final String rarity;
  final String category;
  final int quantity;

  InventoryEntry({
    required this.itemId,
    required this.name,
    required this.iconName,
    required this.rarity,
    required this.category,
    required this.quantity,
  });

  factory InventoryEntry.fromJson(Map<String, dynamic> j) => InventoryEntry(
    itemId: j['item_id'],
    name: j['name'] ?? '',
    iconName: j['icon_name'] ?? 'default',
    rarity: j['rarity'] ?? 'common',
    category: j['category'] ?? '',
    quantity: j['quantity'] ?? 0,
  );
}

class InventorySnapshot {
  final List<InventoryEntry> items;
  final int used;
  final int max;

  InventorySnapshot({
    required this.items,
    required this.used,
    required this.max,
  });

  factory InventorySnapshot.fromJson(Map<String, dynamic> j) =>
      InventorySnapshot(
        items: ((j['items'] as List?) ?? [])
            .map((e) => InventoryEntry.fromJson(e))
            .toList(),
        used: j['used'] ?? 0,
        max: j['max'] ?? 50,
      );
}
