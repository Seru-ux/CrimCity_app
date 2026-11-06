class ShopItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String iconName;
  final String shopType;
  final String rarity;
  final int damage;
  final int armor;
  final int vehicleSpeed;
  final int vehicleCapacity;

  ShopItem({
    required this.id, required this.name, required this.description,
    required this.price, required this.category, required this.iconName,
    required this.shopType, this.rarity = 'common',
    this.damage = 0, this.armor = 0,
    this.vehicleSpeed = 0, this.vehicleCapacity = 0,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    price: json['price'],
    category: json['category'] ?? 'misc',
    iconName: json['icon_name'] ?? 'default',
    shopType: json['shop_type'] ?? 'black',
    rarity: json['rarity'] ?? 'common',
    damage: json['damage'] ?? 0,
    armor: json['armor'] ?? 0,
    vehicleSpeed: json['vehicle_speed'] ?? 0,
    vehicleCapacity: json['vehicle_capacity'] ?? 0,
  );
}