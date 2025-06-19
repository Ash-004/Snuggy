import 'package:flutter/material.dart';

class MenuItem {
  final int id;
  final String name;
  final double price;
  final int stock;
  final List<String> tags;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.tags,
    this.imageUrl = '',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      tags: List<String>.from(json['tags'] ?? []),
      // Use a placeholder image if none is provided
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150?text=${json['name']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': id,
      'price': price,
    };
  }
} 