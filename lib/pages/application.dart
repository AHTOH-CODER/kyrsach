import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';
import 'package:kyrsach/pages/profile.dart';


class ApplicationPage extends StatefulWidget {
  final String level;
  final String store;

  ApplicationPage({required this.level, required this.store});

  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  List<Application> applications = [];
  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final String response = await rootBundle.loadString('assets/application.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      applications = data.map((appJson) => Application.fromJson(appJson)).toList();
    });
  }

  void _createApplication() {
  showDialog(
    context: context,
    builder: (context) {
      String storeName = '';
      String orderDate = DateTime.now().toIso8601String().split("T").first; // Текущая дата
      List<Map<String, dynamic>> orderedProducts = []; // Список для хранения продуктов

      return AlertDialog(
        title: Text('Создать заявку'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Название магазина'),
                onChanged: (value) {
                  storeName = value; // Сохраняем название магазина
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Дата заявки (YYYY-MM-DD)'),
                onChanged: (value) {
                  orderDate = value; // Сохраняем дату заявки
                },
              ),
              // Поля для ввода товаров
              ...orderedProducts.map((product) {
                int index = orderedProducts.indexOf(product); // Получаем индекс товара
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Название товара'),
                        onChanged: (value) {
                          orderedProducts[index]['name'] = value; // Сохраняем название товара
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Единица измерения'),
                        onChanged: (value) {
                          orderedProducts[index]['unit'] = value; // Сохраняем единицу измерения
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Количество'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          orderedProducts[index]['quantity'] = int.tryParse(value) ?? 0; // Сохраняем количество
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          orderedProducts.removeAt(index); // Удаляем товар по индексу
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              // Кнопка для добавления нового товара
              TextButton(
                onPressed: () {
                  setState(() {
                    orderedProducts.add({'name': '', 'unit': '', 'quantity': 0}); // Добавляем новый товар
                  });
                },
                child: Text('Добавить товар'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (storeName.isNotEmpty && orderDate.isNotEmpty && orderedProducts.isNotEmpty) {
                List<Product> productsList = orderedProducts.map((product) {
                  return Product(
                    name: product['name'],
                    unit: product['unit'],
                    quantity: product['quantity'],
                  );
                }).toList();

                Application newApplication = Application(
                  storeName: storeName,
                  orderDate: orderDate,
                  items: productsList,
                );

                setState(() {
                  applications.add(newApplication); // Добавляем новую заявку в список
                });
                Navigator.pop(context);
              }
            },
            child: Text('Создать'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Отмена'),
          ),
        ],
      );
    },
  );
}

  void _acceptApplication(Application application) {
    // Logic to accept application
    // Here you will check if the warehouse has enough stock
    // If so, move the items from central warehouse to the store
    // If not, show an error message
  }

  void _rejectApplication(Application application) {
    // Logic to reject application
    setState(() {
      applications.remove(application);
    });
    // Here you should also update the JSON file to remove the rejected application
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки'),
        actions: widget.level == 'seller'
            ? [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createApplication,
                  tooltip: 'Создать заявку',
                ),
              ]
            : null,
      ),
      body: ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return Card(
            child: ListTile(
              title: Text(application.storeName),
              subtitle: Text('Дата: ${application.orderDate}'),
              onTap: () {
                // Show details of the application
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Детали заявки'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: application.items.map((item) {
                          return Text('${item.name} - ${item.quantity} ${item.unit}');
                        }).toList(),
                      ),
                      actions: [
                        if (widget.level == 'admin') ...[
                          TextButton(
                            onPressed: () => _acceptApplication(application),
                            child: Text('Принять'),
                          ),
                          TextButton(
                            onPressed: () => _rejectApplication(application),
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
          );
        },
      ),
    );
  }
}

class Application {
  String storeName;
  String orderDate;
  List<Product> items;

  Application({required this.storeName, required this.orderDate, required this.items});

  factory Application.fromJson(Map<String, dynamic> json) {
    var itemList = json['items'] as List;
    List<Product> itemListParsed = itemList.map((i) => Product.fromJson(i)).toList();

    return Application(
      storeName: json['storeName'],
      orderDate: json['orderDate'],
      items: itemListParsed,
    );
  }
}
