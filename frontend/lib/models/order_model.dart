import 'menu_item.dart';

class OrderItem {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final MenuItem menuItem;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.menuItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['menuItem']['id'],
      name: json['menuItem']['name'],
      price: json['price'],
      quantity: json['quantity'],
      menuItem: MenuItem(
        id: json['menuItem']['id'],
        name: json['menuItem']['name'],
        price: json['price'].toDouble(),
        stock: json['menuItem']['stock'] ?? 0,
        tags: List<String>.from(json['menuItem']['tags'] ?? []),
        imageUrl: json['menuItem']['imageUrl'] ?? 'https://via.placeholder.com/150',
      ),
    );
  }
}

class Order {
  final int id;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;
  final String createdAt;
  final String? userId;
  final String? rfidTag;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.userId,
    this.rfidTag,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      totalAmount: json['totalAmount'].toDouble(),
      items: (json['orderItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      userId: json['userId']?.toString(),
      rfidTag: json['rfidTag'],
    );
  }
} 