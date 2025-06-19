import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);

  late TabController _tabController;
  final List<String> _tabs = ['All', 'Vegetarian', 'Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<List<dynamic>> _fetchMenuItems({Set<String>? tags}) async {
    final token = await _getToken();
    final uri = Uri.parse(ApiService.menuUrl).replace(
      queryParameters: tags != null && tags.isNotEmpty
          ? {'tags': tags.toList()}
          : null,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items. Status Code: ${response.statusCode}');
    }
  }

  Future<void> _addMenuItem(String name, double price, int stock, Set<String> tags) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(ApiService.menuUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'price': price,
        'stock': stock,
        'tags': tags.toList(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {}); // Refreshes the current tab
    } else {
      throw Exception('Failed to add menu item');
    }
  }

  Future<void> _updateStock(int id, int quantityChange) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse(ApiService.menuItemStockUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'quantityChange': quantityChange}),
    );

    if (response.statusCode == 200) {
      setState(() {}); // Refreshes the current tab
    } else {
      throw Exception('Failed to update stock');
    }
  }

  void _showAddMenuItemDialog() {
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    final _stockController = TextEditingController();
    final _tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
                TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                TextField(controller: _stockController, decoration: InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
                TextField(controller: _tagsController, decoration: InputDecoration(labelText: 'Tags (e.g., vegetarian, lunch)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final price = double.tryParse(_priceController.text) ?? 0.0;
                final stock = int.tryParse(_stockController.text) ?? 0;
                final tags = _tagsController.text.split(',').map((e) => e.trim().toLowerCase()).toSet();
                _addMenuItem(name, price, stock, tags);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStockDialog(int id, String name, int currentStock) {
    final _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Stock for $name'),
          content: TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: 'Quantity Change (+/-)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final quantityChange = int.tryParse(_quantityController.text) ?? 0;
                _updateStock(id, quantityChange);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Inventory Management'),
        backgroundColor: teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin-dashboard'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((String tab) {
          final Set<String> tagsToFetch;
          if (tab == 'All') {
            tagsToFetch = {};
          } else {
            tagsToFetch = {tab.toLowerCase()};
          }

          return FutureBuilder<List<dynamic>>(
            future: _fetchMenuItems(tags: tagsToFetch),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No menu items found for this category.'));
              }

              final menuItems = snapshot.data!;
              return ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final tags = (item['tags'] as List).map((t) => t['name']).join(', ');
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text('Price: ₹${item['price']} - Stock: ${item['stock']}\nTags: $tags'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdateStockDialog(item['id'], item['name'], item['stock']),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenuItemDialog,
        backgroundColor: teal,
        child: Icon(Icons.add),
      ),
    );
  }
} 