import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models/order_item.dart';

class ApplicationController {
  final String level;
  final String store;

  ApplicationController({required this.level, required this.store});

  Future<List<OrderItem>> loadApplications() async {
    try {
      final file = File('assets/application.json');
      final content = await file.readAsString();
      final List<dynamic> data = json.decode(content);
      return data.map((storeJson) => OrderItem.fromJson(storeJson)).toList();
    } catch (e) {
      print('Ошибка загрузки заявок: $e');
      return [];
    }
  }

  Future<void> saveOrderItem(OrderItem item) async {
    try {
      final filePath = 'assets/application.json';
      final file = File(filePath);
      List<dynamic> orderItems = [];
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        if (fileContent.isNotEmpty) {
          orderItems = jsonDecode(fileContent);
        }
      }
      orderItems.add(item.toJson());
      await file.writeAsString(jsonEncode(orderItems));
      print('Элемент успешно сохранен!');
    } catch (e) {
      print('Ошибка при сохранении элемента: $e');
    }
  }

  Future<void> updateApplicationStatus(OrderItem item, String newStatus) async {
    try {
      final file = File('assets/application.json');
      final content = await file.readAsString();
      List<dynamic> applications = json.decode(content);
      
      // Находим заявку по ID
      bool found = false;
      for (int i = 0; i < applications.length; i++) {
        if (applications[i]['id'] == item.id) {
          applications[i]['status'] = newStatus;
          found = true;
          break;
        }
      }
      
      if (!found) {
        throw Exception('Заявка не найдена для обновления');
      }
      
      await file.writeAsString(jsonEncode(applications));
    } catch (e) {
      print('Ошибка при обновлении статуса заявки: $e');
      throw e;
    }
  }

  Future<void> acceptApplication(BuildContext context, OrderItem item) async {
    try {
      final String warehouseResponse = await rootBundle.loadString('assets/warehouse_inventory.json');
      List<dynamic> warehouseData = json.decode(warehouseResponse);
      
      bool productFound = false;
      bool enoughQuantity = false;
      int warehouseIndex = -1;
      
      for (int i = 0; i < warehouseData.length; i++) {
        if (warehouseData[i]['name'] == item.product.name && 
            warehouseData[i]['unit'] == item.product.unit) {
          productFound = true;
          warehouseIndex = i;
          if (warehouseData[i]['quantity'] >= item.product.quantity) {
            enoughQuantity = true;
          }
          break;
        }
      }
      
      if (!productFound) {
        throw Exception('Товар ${item.product.name} не найден на центральном складе!');
      }
      
      if (!enoughQuantity) {
        throw Exception('Недостаточно товара ${item.product.name} на центральном складе!');
      }
      
      final String storesResponse = await rootBundle.loadString('assets/stores.json');
      List<dynamic> storesData = json.decode(storesResponse);
      
      bool storeFound = false;
      int storeIndex = -1;
      int productIndex = -1;
      
      for (int i = 0; i < storesData.length; i++) {
        if (storesData[i]['name'] == item.storeName) {
          storeFound = true;
          storeIndex = i;
          
          for (int j = 0; j < storesData[i]['products'].length; j++) {
            if (storesData[i]['products'][j]['name'] == item.product.name && 
                storesData[i]['products'][j]['unit'] == item.product.unit) {
              productIndex = j;
              break;
            }
          }
          break;
        }
      }
      
      if (!storeFound) {
        throw Exception('Магазин ${item.storeName} не найден!');
      }
      
      warehouseData[warehouseIndex]['quantity'] -= item.product.quantity;
      
      if (productIndex != -1) {
        storesData[storeIndex]['products'][productIndex]['quantity'] += item.product.quantity;
      } else {
        storesData[storeIndex]['products'].add({
          'name': item.product.name,
          'unit': item.product.unit,
          'quantity': item.product.quantity
        });
      }
      
      final warehouseFile = File('assets/warehouse_inventory.json');
      await warehouseFile.writeAsString(jsonEncode(warehouseData));
      
      final storesFile = File('assets/stores.json');
      await storesFile.writeAsString(jsonEncode(storesData));
      
      await updateApplicationStatus(item, 'Принято');
    } catch (e) {
      print('Ошибка при принятии заявки: $e');
      throw e;
    }
  }
}