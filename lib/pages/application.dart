import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';

class ApplicationPage extends StatefulWidget {
  final String level;
  final String store;

  ApplicationPage({required this.level, required this.store});

  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  late Future<List<OrderItem>> items;

  @override
  void initState() {
    super.initState();
    items = _loadApplications();
  }

Future<List<OrderItem>> _loadApplications() async {
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

  void _createApplication(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final orderDateController = TextEditingController(); 
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedUnit = 'шт';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Регистрация товара'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Магазин: ${widget.store}'),
                  TextFormField(
                    controller: orderDateController,
                    decoration: const InputDecoration(labelText: 'Дата заявки (ДД.ММ.ГГГГ)'),
                    validator: (value) => value?.isEmpty ?? true ? 'Обязательное поле' : null,
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Название товара'),
                    validator: (value) => value?.isEmpty ?? true ? 'Обязательное поле' : null,
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Количество'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Обязательное поле';
                      if (int.tryParse(value!) == null) return 'Введите число';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    items: ['шт', 'л', 'кг'].map((unit) => 
                      DropdownMenuItem(value: unit, child: Text(unit))
                    ).toList(),
                    onChanged: (v) => selectedUnit = v!,
                    decoration: const InputDecoration(labelText: 'Единица измерения'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final newItem = OrderItem(
                    status: 'Без ответа',
                    storeName: widget.store,
                    orderDate: orderDateController.text,
                    product: Product(
                      name: nameController.text, 
                      unit: selectedUnit, 
                      quantity: int.parse(quantityController.text),
                    ),
                  );

                  await _saveOrderItem(newItem);
                  setState(() => items = _loadApplications());
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заявка успешно создана!')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }


  void _acceptApplication(BuildContext context, OrderItem item) async {
    try {
      // 1. Загружаем данные центрального склада
      final String warehouseResponse = await rootBundle.loadString('assets/warehouse_inventory.json');
      List<dynamic> warehouseData = json.decode(warehouseResponse);
      
      // 2. Ищем нужный товар на складе
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Товар ${item.product.name} не найден на центральном складе!')),
        );
        return;
      }
      
      if (!enoughQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Недостаточно товара ${item.product.name} на центральном складе!')),
        );
        return;
      }
      
      // 3. Загружаем данные магазинов
      final String storesResponse = await rootBundle.loadString('assets/stores.json');
      List<dynamic> storesData = json.decode(storesResponse);
      
      // 4. Находим нужный магазин и обновляем его инвентарь
      bool storeFound = false;
      int storeIndex = -1;
      int productIndex = -1;
      
      for (int i = 0; i < storesData.length; i++) {
        if (storesData[i]['name'] == item.storeName) {
          storeFound = true;
          storeIndex = i;
          
          // Проверяем, есть ли уже такой товар в магазине
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Магазин ${item.storeName} не найден!')),
        );
        return;
      }
      
      // 5. Обновляем данные
      
      // Уменьшаем количество на центральном складе
      warehouseData[warehouseIndex]['quantity'] -= item.product.quantity;
      
      // Обновляем или добавляем товар в магазин
      if (productIndex != -1) {
        // Товар уже есть в магазине - увеличиваем количество
        storesData[storeIndex]['products'][productIndex]['quantity'] += item.product.quantity;
      } else {
        // Товара нет в магазине - добавляем новый
        storesData[storeIndex]['products'].add({
          'name': item.product.name,
          'unit': item.product.unit,
          'quantity': item.product.quantity
        });
      }
      
      // 6. Сохраняем обновленные данные
      
      // Сохраняем обновленный центральный склад
      final warehouseFile = File('assets/warehouse_inventory.json');
      await warehouseFile.writeAsString(jsonEncode(warehouseData));
      
      // Сохраняем обновленные данные магазинов
      final storesFile = File('assets/stores.json');
      await storesFile.writeAsString(jsonEncode(storesData));
      
      // Обновляем статус заявки
      await _updateApplicationStatus(item, 'Принято');
      
      setState(() {
        items = _loadApplications();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заявка принята! Товар перемещен в магазин.')),
      );
      
      Navigator.of(context).pop();
      
    } catch (e) {
      print('Ошибка при принятии заявки: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла ошибка при обработке заявки: $e')),
      );
    }
  }

  void _rejectApplication(BuildContext context, OrderItem item) async {
    try {
      // Обновляем статус заявки
      await _updateApplicationStatus(item, 'Отклонено');
      
      // Обновляем UI
      setState(() {
        items = _loadApplications();
      });
      
      // Уведомляем пользователя
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка отклонена!')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      print('Ошибка при отклонении заявки: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла ошибка при отклонении заявки: $e')),
      );
    }
  }

Future<void> _updateApplicationStatus(OrderItem item, String newStatus) async {
  try {
    final file = File('assets/application.json');
    
    // Загружаем текущие заявки
    final content = await file.readAsString();
    List<dynamic> applications = json.decode(content);
    
    // Находим и обновляем нужную заявку
    bool found = false;
    for (int i = 0; i < applications.length; i++) {
      var app = applications[i];
      if (app['storeName'] == item.storeName &&
          app['orderDate'] == item.orderDate &&
          app['product']['name'] == item.product.name &&
          app['product']['quantity'] == item.product.quantity &&
          app['product']['unit'] == item.product.unit) {
        applications[i]['status'] = newStatus;
        found = true;
        break;
      }
    }
    
    if (!found) {
      throw Exception('Заявка не найдена для обновления');
    }
    
    // Сохраняем обновленные заявки
    await file.writeAsString(jsonEncode(applications));
  } catch (e) {
    print('Ошибка при обновлении статуса заявки: $e');
    throw e;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки'),
      ),
      body: FutureBuilder<List<OrderItem>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }

          final orderItems = snapshot.data!.reversed.toList();
          
          return ListView.builder(
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              final item = orderItems[index];
              Color containerColor;
              switch (item.status) {
                case 'Принято':
                  containerColor = Colors.green[200]!;
                  break;
                case 'Отклонено':
                  containerColor = Colors.red[200]!;
                  break;
                case 'Без ответа':
                default:
                  containerColor = const Color.fromARGB(255, 228, 232, 240);
                  break;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  color: containerColor,
                  child: ListTile(
                    title: Text(item.storeName),
                    subtitle: Text('Дата: ${item.orderDate}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Детали заявки'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Название: ${item.product.name}'),
                                Text('Количество: ${item.product.quantity} ${item.product.unit}'),
                              ],
                            ),
                            actions: [
                              if (widget.level == 'admin') ...[
                                TextButton(
                                  onPressed: () => _acceptApplication(context, item),
                                  child: Text('Принять'),
                                ),
                                TextButton(
                                  onPressed: () => _rejectApplication(context, item),
                                  child: Text('Отклонить'),
                                ),
                              ],
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Закрыть'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: widget.level == 'seller'
          ? FloatingActionButton(
              onPressed: () {
                _createApplication(context);
              },
              child: const Icon(Icons.add),
              tooltip: 'Создать заявку',
            )
          : null, 
    );
  }

  Future<void> _saveOrderItem(OrderItem item) async {
        try {
          // String jsonString = jsonEncode(item.toJson());
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
}