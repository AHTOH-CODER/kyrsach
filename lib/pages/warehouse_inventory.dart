import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:kyrsach/models.dart';

class WarehouseInventory extends StatefulWidget {
  @override
  _WarehouseInventory createState() => _WarehouseInventory();
}

class _WarehouseInventory extends State<WarehouseInventory> {
  late Future<List<Product>> inventoryItems;

  @override
  void initState() {
    super.initState();
    inventoryItems = _loadInventory();
  }

  Future<List<Product>> _loadInventory() async {
    try {
      final String response = await rootBundle.loadString('assets/warehouse_inventory.json');
      final List<dynamic> data = json.decode(response);
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } catch (e) {
      print('Ошибка загрузки инвентаря: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Содержимое склада'),
      ),
      body: FutureBuilder<List<Product>>(
        future: inventoryItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Склад пуст'));
          }

          final inventoryData = snapshot.data!.reversed.toList();
           return ListView.builder(
            itemCount: inventoryData.length,
            itemBuilder: (context, index) {
              final item = inventoryData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  color: const Color.fromARGB(255, 228, 232, 240),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} ${item.unit}'),
                  ),
                ),
              );
            }
          );
        }
      ),
    );
  }
}