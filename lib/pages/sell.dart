// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:kyrsach/models.dart';
// import 'package:kyrsach/pages/profile.dart';

// class SellPage extends StatefulWidget {
//   final Profile? profile;

//   SellPage({required this.profile});

//   @override
//   State<SellPage> createState() => _SellPage();
// }

// class _SellPage extends State<SellPage> {
//   late Future<List<SellItem>> items;
//   late Future<List<SellItem>> shops;
//   @override
//   void initState() {
//     super.initState();
//     items = _loadStores();
//     shops = _loadShops();
//   }

//   Future<List<SellItem>> _loadStores() async {
//     final String response = await rootBundle.loadString('assets/sell.json');
//     final List<dynamic> data = json.decode(response);
//     return data.map((storeJson) => SellItem.fromJson(storeJson)).toList();
//   }

//    Future<List<SellItem>> _loadShops() async {
//     final String response = await rootBundle.loadString('assets/stores.json');
//     final List<dynamic> data = json.decode(response);
//     return data.map((storeJson) => SellItem.fromJson(storeJson)).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Продажи'),
//       ),
//       body: FutureBuilder<List<SellItem>>(
//         future: items,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return const Center(child: Text('Ошибка загрузки данных'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('Нет данных'));
//           }

//           final SellItems = snapshot.data!;

//           return ListView.builder(
//             itemCount: SellItems.length,
//             itemBuilder: (context, index) {
//               final item = SellItems[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 3.0),
//                 child: Container(
//                   color: const Color.fromARGB(255, 228, 232, 240),
//                   child: ListTile(
//                     title: Text(item.product.name),
//                     subtitle: Text('${item.product.quantity} ${item.product.unit} - ${item.price} ₽'),
//                     onTap: () {
//                       _showSellInfo(context, item.profile, item.sellDate);
//                     },
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: widget.profile!.level == 'seller'
//           ? FloatingActionButton(
//               onPressed: () {
//                 _showSellProductDialog(context, widget.profile!);
//               },
//               child: const Icon(Icons.add),
//               tooltip: 'Продать товар',
//             )
//           : null, 
//       );
//   }

//   void _showSellInfo(BuildContext context, Profile? profile, String sellDate) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Информация о продаже:'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Продавец:', style: TextStyle(fontSize: 18)),
//               SizedBox(height: 5),
//               Text('ФИО: ${widget.profile!.fullName}'),
//               Text('Логин: ${widget.profile!.login}'),
//               Text('Роль: ${widget.profile!.level}'),
//               Text('Магазин: ${widget.profile!.store}'),
//               Text('Отдел: ${widget.profile!.department}'),
//               Text('Пол: ${widget.profile!.gender}'),
//               Text('Возраст: ${widget.profile!.age}'),
//               Text('Адрес: ${widget.profile!.address}'),
//               Text('Опыт работы: ${widget.profile!.workExperience}'),
//               Text('Квалификация: ${widget.profile!.qualification}'),
//               SizedBox(height: 40),
//               Text('Дата продажи: ${sellDate}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Закрыть'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showSellProductDialog(BuildContext context, Profile profile) {
//     final TextEditingController nameController = TextEditingController();
//     final TextEditingController sellDateController = TextEditingController();
//     final TextEditingController unitController = TextEditingController(); 
//     final TextEditingController priceController = TextEditingController();
//     final TextEditingController quantityController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Регистрация товара'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Продавец:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 5),
//                 Text('ФИО: ${widget.profile!.fullName}'),
//                 Text('Логин: ${widget.profile!.login}'),
//                 Text('Роль: ${widget.profile!.level}'),
//                 Text('Магазин: ${widget.profile!.store}'),
//                 Text('Отдел: ${widget.profile!.department}'),
//                 Text('Пол: ${widget.profile!.gender}'),
//                 Text('Возраст: ${widget.profile!.age}'),
//                 Text('Адрес: ${widget.profile!.address}'),
//                 Text('Опыт работы: ${widget.profile!.workExperience} лет'),
//                 Text('Квалификация: ${widget.profile!.qualification}'),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: sellDateController,
//                   decoration: const InputDecoration(labelText: 'Дата продажи (ДД.ММ.ГГГГ)'),
//                 ),
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(labelText: 'Название товара'),
//                 ),
//                 TextField(
//                   controller: quantityController,
//                   decoration: const InputDecoration(labelText: 'Количество'),
//                 ),
//                 TextField(
//                   controller: unitController, 
//                   decoration: const InputDecoration(labelText: 'Единицы измерения'),
//                 ),
//                 TextField(
//                   controller: priceController,
//                   decoration: const InputDecoration(labelText: 'Цена'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
               
//                 if (sellDateController.text.isEmpty || nameController.text.isEmpty || quantityController.text.isEmpty || unitController.text.isEmpty || priceController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Пожалуйста, заполните все поля!')),
//                   );
//                   return;
//                 }

                
//                 final newItem = SellItem(
//                   price: double.tryParse(priceController.text) ?? 0.0,
//                   product: Product(
//                     name: nameController.text,
//                     unit: unitController.text,
//                     quantity: int.tryParse(quantityController.text) ?? 0,
//                   ),
//                   profile: profile,
//                   sellDate: sellDateController.text,
//                 );

//                 await _saveSellItem(newItem);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Сохранить'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Отмена'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _saveSellItem(SellItem item) async {
//     try {
//       // String jsonString = jsonEncode(item.toJson());
//       final filePath = 'assets/sell.json';
//       final file = File(filePath);
//       List<dynamic> SellItems = [];
//       if (await file.exists()) {
//         String fileContent = await file.readAsString();
//         if (fileContent.isNotEmpty) {
//           SellItems = jsonDecode(fileContent);
//         }
//       }
//       SellItems.add(item.toJson());
//       await file.writeAsString(jsonEncode(SellItems));
//       print('Элемент успешно сохранен!');
//     } catch (e) {
//       print('Ошибка при сохранении элемента: $e');
//     }
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';
import 'package:kyrsach/pages/profile.dart';

class SellPage extends StatefulWidget {
  final Profile? profile;

  SellPage({required this.profile});

  @override
  State<SellPage> createState() => _SellPage();
}

class _SellPage extends State<SellPage> {
  late Future<List<SellItem>> items;
  late Future<List<Store>> stores; // Изменено на Store
  late List<Product> availableProducts = []; // Список доступных продуктов

  @override
  void initState() {
    super.initState();
    items = _loadStores();
    stores = _loadShops();
  }

  Future<List<SellItem>> _loadStores() async {
    final String response = await rootBundle.loadString('assets/sell.json');
    final List<dynamic> data = json.decode(response);
    return data.map((storeJson) => SellItem.fromJson(storeJson)).toList();
  }

  Future<List<Store>> _loadShops() async {
    final String response = await rootBundle.loadString('assets/stores.json');
    final List<dynamic> data = json.decode(response);
    return data.map((storeJson) => Store.fromJson(storeJson)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажи'),
      ),
      body: FutureBuilder<List<SellItem>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }

          final sellItems = snapshot.data!;

          return ListView.builder(
            itemCount: sellItems.length,
            itemBuilder: (context, index) {
              final item = sellItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  color: const Color.fromARGB(255, 228, 232, 240),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('${item.product.quantity} ${item.product.unit} - ${item.price} ₽'),
                    onTap: () {
                      _showSellInfo(context, item.profile, item.sellDate);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.profile!.level == 'seller'
          ? FloatingActionButton(
              onPressed: () {
                _showSellProductDialog(context, widget.profile!);
              },
              child: const Icon(Icons.add),
              tooltip: 'Продать товар',
            )
          : null,
    );
  }

  void _showSellInfo(BuildContext context, Profile? profile, String sellDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Информация о продаже:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Продавец:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 5),
              Text('ФИО: ${widget.profile!.fullName}'),
              Text('Логин: ${widget.profile!.login}'),
              Text('Роль: ${widget.profile!.level}'),
              Text('Магазин: ${widget.profile!.store}'),
              Text('Отдел: ${widget.profile!.department}'),
              Text('Пол: ${widget.profile!.gender}'),
              Text('Возраст: ${widget.profile!.age}'),
              Text('Адрес: ${widget.profile!.address}'),
              Text('Опыт работы: ${widget.profile!.workExperience} лет'),
              Text('Квалификация: ${widget.profile!.qualification}'),
              SizedBox(height: 40),
              Text('Дата продажи: $sellDate'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _showSellProductDialog(BuildContext context, Profile profile) {
    final TextEditingController sellDateController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    String? selectedProduct; // Для хранения выбранного товара
    int selectedQuantity = 1; // Количество товара по умолчанию

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Регистрация товара'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Продавец:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('ФИО: ${widget.profile!.fullName}'),
                Text('Логин: ${widget.profile!.login}'),
                Text('Роль: ${widget.profile!.level}'),
                Text('Магазин: ${widget.profile!.store}'),
                Text('Отдел: ${widget.profile!.department}'),
                Text('Пол: ${widget.profile!.gender}'),
                Text('Возраст: ${widget.profile!.age}'),
                Text('Адрес: ${widget.profile!.address}'),
                Text('Опыт работы: ${widget.profile!.workExperience} лет'),
                Text('Квалификация: ${widget.profile!.qualification}'),
                SizedBox(height: 10),
                TextField(
                  controller: sellDateController,
                  decoration: const InputDecoration(labelText: 'Дата продажи (ДД.ММ.ГГГГ)'),
                ),
                DropdownButton<String>(
                  hint: const Text('Выберите товар'),
                  value: selectedProduct,
                  items: availableProducts.map((Product product) {
                    return DropdownMenuItem<String>(
                      value: product.name,
                      child: Text('${product.name} (${product.quantity} ${product.unit})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Количество'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    selectedQuantity = int.tryParse(value) ?? 1; // Устанавливаем значение по умолчанию
                  },
                ),
                TextField(
                  controller: priceController, // Используем контроллер для цены
                  decoration: const InputDecoration(labelText: 'Цена'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (sellDateController.text.isEmpty || selectedProduct == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пожалуйста, заполните все поля!')),
                  );
                  return;
                }

                // Находим выбранный продукт
                final product = availableProducts.firstWhere((p) => p.name == selectedProduct);
                final newItem = SellItem(
                  price: double.tryParse(priceController.text) ?? 0.0,
                  product: Product(
                    name: product.name,
                    unit: product.unit,
                    quantity: selectedQuantity,
                  ),
                  profile: profile,
                  sellDate: sellDateController.text,
                );

                await _saveSellItem(newItem);
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

  Future<void> _loadAvailableProducts() async {
    final storesList = await stores; // Получаем список магазинов
    final currentStore = storesList.firstWhere((store) => store.name == widget.profile!.store);
    availableProducts = currentStore.products; // Загружаем продукты из текущего магазина
  }

  Future<void> _saveSellItem(SellItem item) async {
    try {
      final filePath = 'assets/sell.json';
      final file = File(filePath);
      List<dynamic> sellItems = [];
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        if (fileContent.isNotEmpty) {
          sellItems = jsonDecode(fileContent);
        }
      }
      sellItems.add(item.toJson());
      await file.writeAsString(jsonEncode(sellItems));
      print('Элемент успешно сохранен!');
    } catch (e) {
      print('Ошибка при сохранении элемента: $e');
    }
  }
}

