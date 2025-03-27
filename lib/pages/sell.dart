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
  int selectedQuantity = 0; // Количество товара по умолчанию

  // Загружаем доступные продукты перед показом диалога
  _loadAvailableProducts().then((_) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Регистрация товара'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seller information
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: selectedProduct,
                  items: availableProducts.map((Product product) {
                    return DropdownMenuItem<String>(
                      value: product.name,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                      if (selectedProduct != null) {
                        final product = availableProducts.firstWhere(
                            (p) => p.name == selectedProduct);
                        selectedQuantity = product.quantity;
                      }
                    });
                  },
                  isExpanded: true,
                  hint: Text('Выберите продукт'),
                  validator: (value) => value == null ? 'Выберите продукт' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Количество'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    selectedQuantity = int.tryParse(value) ?? 0;
                  },
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Цена'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (sellDateController.text.isEmpty || selectedProduct == null || selectedQuantity == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пожалуйста, заполните все поля!')),
                  );
                  return;
                }

                // Находим выбранный продукт
                final product = availableProducts.firstWhere((p) => p.name == selectedProduct);

                // Проверяем, достаточно ли товара на складе
                if (selectedQuantity > product.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Недостаточно товара. Доступно: ${product.quantity}')),
                  );
                  return;
                }

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
      }
    );
  });
}



  Future<void> _loadAvailableProducts() async {
    final storesList = await stores; // Получаем список магазинов
    final currentStore = storesList.firstWhere((store) => store.name == widget.profile!.store);
    availableProducts = currentStore.products; // Загружаем продукты из текущего магазина
  }

  Future<void> _saveSellItem(SellItem item) async {
  try {
    // Load the current list of stores
    final filePath = 'assets/stores.json';
    final file = File(filePath);
    List<dynamic> storesList = [];

    if (await file.exists()) {
      String fileContent = await file.readAsString();
      if (fileContent.isNotEmpty) {
        storesList = jsonDecode(fileContent);
      }
    }

    final currentStore = storesList.firstWhere((store) => store['name'] == widget.profile!.store);

    final productIndex = currentStore['products'].indexWhere((product) => product['name'] == item.product.name);
    if (productIndex != -1) {
      int availableQuantity = currentStore['products'][productIndex]['quantity'];
      if (availableQuantity >= item.product.quantity) {
        currentStore['products'][productIndex]['quantity'] -= item.product.quantity;
      } else {
        throw Exception('Недостаточно товара на складе');
      }
    }

    final sellFilePath = 'assets/sell.json';
    final sellFile = File(sellFilePath);
    List<dynamic> sellItems = [];
    if (await sellFile.exists()) {
      String sellFileContent = await sellFile.readAsString();
      if (sellFileContent.isNotEmpty) {
        sellItems = jsonDecode(sellFileContent);
      }
    }
    sellItems.add(item.toJson());
    await sellFile.writeAsString(jsonEncode(sellItems));

    await file.writeAsString(jsonEncode(storesList));


    print('Элемент успешно сохранен и количество товара обновлено!');
  } catch (e) {
    print('Ошибка при сохранении элемента: $e');
  }
}}
