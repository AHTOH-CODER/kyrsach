import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models/product.dart';

class WarehouseInventoryController {
  final ValueNotifier<List<Product>> inventoryItems = ValueNotifier([]);
  bool isLoading = false;

  Future<void> loadInventory() async {
    try {
      isLoading = true;
      final String response = await rootBundle.loadString('assets/warehouse_inventory.json');
      final List<dynamic> data = json.decode(response);
      final items = data.map((productJson) => Product.fromJson(productJson)).toList();
      inventoryItems.value = items.reversed.toList();
    } catch (e) {
      print('Ошибка загрузки инвентаря: $e');
      inventoryItems.value = [];
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    inventoryItems.dispose();
  }
}