import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:kyrsach/models/product.dart';
import 'package:kyrsach/models/stock_item.dart';

class CentralWarehouseController {
  Future<List<StockItem>> loadStockItems() async {
    final String response = await rootBundle.loadString('assets/central_warehouse.json');
    final List<dynamic> data = json.decode(response);
    return data.map((storeJson) => StockItem.fromJson(storeJson)).toList();
  }

  Future<void> saveProductToInventory(Product product) async {
    try {
      final filePath = 'assets/warehouse_inventory.json';
      final file = File(filePath);
      List<dynamic> products = [];
      
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        if (fileContent.isNotEmpty) {
          products = jsonDecode(fileContent);
        }
      }
      
      bool productExists = false;
      for (int i = 0; i < products.length; i++) {
        if (products[i]['name'] == product.name && products[i]['unit'] == product.unit) {
          products[i]['quantity'] += product.quantity;
          productExists = true;
          break;
        }
      }
      
      if (!productExists) {
        products.add(product.toJson());
      }
      
      await file.writeAsString(jsonEncode(products));
    } catch (e) {
      throw Exception('Ошибка при сохранении продукта: $e');
    }
  }

  Future<void> saveStockItem(StockItem item) async {
    try {
      final filePath = 'assets/central_warehouse.json';
      final file = File(filePath);
      List<dynamic> stockItems = [];
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        if (fileContent.isNotEmpty) {
          stockItems = jsonDecode(fileContent);
        }
      }
      stockItems.add(item.toJson());
      await file.writeAsString(jsonEncode(stockItems));
      
      await saveProductToInventory(Product(
        name: item.name,
        unit: item.unit,
        quantity: item.quantity,
      ));
    } catch (e) {
      throw Exception('Ошибка при сохранении элемента: $e');
    }
  }
}