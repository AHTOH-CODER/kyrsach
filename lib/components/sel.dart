import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:kyrsach/models/store.dart';
import 'package:kyrsach/models/sell_item.dart';

class SellController {
  Future<List<SellItem>> loadSellItems() async {
    try {
      final response = await rootBundle.loadString('assets/sell.json');
      final data = json.decode(response) as List;
      return data.map((json) => SellItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки продаж: $e');
    }
  }

  Future<List<Store>> loadStores() async {
    try {
      final response = await rootBundle.loadString('assets/stores.json');
      final data = json.decode(response) as List;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки магазинов: $e');
    }
  }

  Future<void> saveSellItem(SellItem item, String currentStoreName) async {
    try {
      final storesFile = File('assets/stores.json');
      final storesContent = await storesFile.readAsString();
      final storesList = json.decode(storesContent) as List;

      final storeIndex = storesList.indexWhere((s) => s['name'] == currentStoreName);
      if (storeIndex == -1) throw Exception('Магазин не найден');

      final productIndex = storesList[storeIndex]['products']
          .indexWhere((p) => p['name'] == item.product.name);
      
      if (productIndex == -1) throw Exception('Товар не найден в магазине');
      
      final availableQuantity = storesList[storeIndex]['products'][productIndex]['quantity'];
      if (availableQuantity < item.product.quantity) {
        throw Exception('Недостаточно товара на складе');
      }

      storesList[storeIndex]['products'][productIndex]['quantity'] -= item.product.quantity;
      await storesFile.writeAsString(json.encode(storesList));

      // Сохраняем продажу
      final sellFile = File('assets/sell.json');
      final sellItems = await sellFile.exists()
          ? json.decode(await sellFile.readAsString()) as List
          : [];
      
      sellItems.add(item.toJson());
      await sellFile.writeAsString(json.encode(sellItems));
    } catch (e) {
      throw Exception('Ошибка сохранения продажи: $e');
    }
  }
}