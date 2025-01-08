import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';
import 'package:path_provider/path_provider.dart';


class ApplicationPage extends StatefulWidget {
  final String level;
  final String store;

  ApplicationPage({required this.level, required this.store});

  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  // Profile? _currentProfile;
  late Future<List<OrderItem>> items;

  @override
  void initState() {
    super.initState();
    items = _loadApplications();
  }

  Future<List<OrderItem>> _loadApplications() async {
    final String response = await rootBundle.loadString('assets/application.json');
    final List<dynamic> data = json.decode(response);
    return data.map((storeJson) => OrderItem.fromJson(storeJson)).toList();
  }

  void _createApplication(BuildContext context) {
    // final TextEditingController storeNameController = TextEditingController();
    final TextEditingController orderDateController = TextEditingController(); 
    final TextEditingController nameController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Регистрация товара'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextField(
                //   controller: storeNameController,
                //   decoration: const InputDecoration(labelText: 'Название магазина'),
                // ),
                Text('Магазин: ${widget.store}'),
                TextField(
                  controller: orderDateController,
                  decoration: const InputDecoration(labelText: 'Дата заявки (ДД.ММ.ГГГГ)'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название товара'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Количество'),
                ),
                TextField(
                  controller: unitController, 
                  decoration: const InputDecoration(labelText: 'Единицы измерения'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
               
                if (orderDateController.text.isEmpty || nameController.text.isEmpty || quantityController.text.isEmpty || nameController.text.isEmpty || quantityController.text.isEmpty || unitController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пожалуйста, заполните все поля!')),
                  );
                  return;
                }

                
                final newItem = OrderItem(
                  status: 'Без ответа',
                  storeName: widget.store,
                  orderDate: orderDateController.text,
                  product: Product(name: nameController.text, unit: unitController.text, quantity: int.tryParse(quantityController.text) ?? 0,),
                );

                await _saveOrderItem(newItem);
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }


   void _acceptApplication(BuildContext context, OrderItem item) async {
    // Логика для принятия заявки
    // Здесь мы проверяем, есть ли достаточно запасов на складе
    // Если да, обновляем статус заявки на "Принято"
    // Если нет, показываем сообщение об ошибке

    // Пример проверки наличия запасов
    bool hasStock = await _checkStock(item); // Предполагаем, что у вас есть метод для проверки запасов

    if (hasStock) {
      item.status = 'Принято';
      await _saveUpdatedOrderItems(item); // Сохраняем изменения в файле

      // Уведомляем пользователя
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка принята!')),
      );
    } else {
      // Если запасов недостаточно, показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно запасов для принятия заявки!')),
      );
    }
  }

  void _rejectApplication(BuildContext context, OrderItem item) async {
    // Здесь мы можем изменить статус заявки на "Отклонено"
    item.status = 'Отклонено';

    // Сохраняем изменения в файле
    await _saveUpdatedOrderItems(item);

    // Уведомляем пользователя
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заявка отклонена!')),
    );
  }

 Future<void> _saveUpdatedOrderItems(OrderItem updatedItem) async {
    try {
      // Получаем директорию документов
      final documentsDir = await getApplicationDocumentsDirectory();
      final file = File('${documentsDir.path}/application.json');

      // Проверяем, существует ли файл, и если нет, создаем его с пустым списком
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode([]));
        print('Файл создан!');
      }
       // Читаем существующие заявки из файла в директории документов
       String fileContent = await file.readAsString();
       List<dynamic> orderItems = [];
       if (fileContent.isNotEmpty) {
         orderItems = jsonDecode(fileContent);
       }

      // Обновляем список заявок
      List<Map<String, dynamic>> updatedItems = orderItems.map((dynamic json) {
        OrderItem item = OrderItem.fromJson(json);
        if (item.storeName == updatedItem.storeName && item.orderDate == updatedItem.orderDate && item.product == updatedItem.product) {
          return updatedItem.toJson();
        } else {
          return item.toJson();
        }
      }).toList();

      // Сохраняем обновленный список заявок обратно в файл
      await file.writeAsString(jsonEncode(updatedItems));
      print('Заявки успешно обновлены!');

      // Проверка содержимого файла после сохранения:
      String savedContent = await file.readAsString();
      print('Содержимое файла после сохранения:\n$savedContent');
    } catch (e) {
      print('Ошибка при обновлении заявок: $e');
    }
  }

  Future<bool> _checkStock(OrderItem item) async {
    // Замените этот код на вашу логику проверки запасов
    // Например, можно получить информацию о запасах из API
    // или из локальной базы данных
  
    await Future.delayed(Duration(seconds: 1));
    return item.product.quantity > 0; // Возвращаем true, если есть запасы
    
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

          final orderItems = snapshot.data!;
          
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
                                Text('Единицы измерения: ${item.product.unit}'),
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