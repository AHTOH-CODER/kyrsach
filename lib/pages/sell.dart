import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';
import 'package:kyrsach/pages/profile.dart';

class SellPage extends StatefulWidget {
  final Profile profile;

  SellPage({required this.profile});

  @override
  State<SellPage> createState() => _SellPage();
}

class _SellPage extends State<SellPage> {
  late Future<List<SellItem>> items;
  @override
  void initState() {
    super.initState();
    items = _loadStores();
  }

  Future<List<SellItem>> _loadStores() async {
    final String response = await rootBundle.loadString('assets/sell.json');
    final List<dynamic> data = json.decode(response);
    return data.map((storeJson) => SellItem.fromJson(storeJson)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Центральный склад'),
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

          final SellItems = snapshot.data!;

          return ListView.builder(
            itemCount: SellItems.length,
            itemBuilder: (context, index) {
              final item = SellItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  color: const Color.fromARGB(255, 228, 232, 240),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} ${item.unit} - ${item.price} ₽'),
                    onTap: () {
                      _showSupplierInfo(context, item.supplier);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.level == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                _showRegisterProductDialog(context);
              },
              child: const Icon(Icons.add),
              tooltip: 'Зарегистрировать товар',
            )
          : null, 
      );
  }

  Future<List<SellItem>> _loadSellItems() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(contents);
      return jsonData.map((item) => SellItem.fromJson(item)).toList();
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
      return [];
    }
  }

  Future<File> get _localFile async {
    return File('pages/central_warehouse.json');
  }

  void _showSupplierInfo(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Поставщик:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Название: ${supplier.name}'),
              Text('Адрес: ${supplier.address}'),
              Text('Руководитель: ${supplier.directorName}'),
              Text('Телефон: ${supplier.phone}'),
              Text('Банк: ${supplier.bank}'),
              Text('Расчетный счет: ${supplier.accountNumber}'),
              Text('ИНН: ${supplier.inn}'),
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

  void _showRegisterProductDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController supplierNameController = TextEditingController(); 
    final TextEditingController addressController = TextEditingController();
    final TextEditingController directorNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController bankController = TextEditingController();
    final TextEditingController accountNumberController = TextEditingController();
    final TextEditingController innController = TextEditingController();
    final TextEditingController deliveryDateController = TextEditingController();
    final TextEditingController unitController = TextEditingController(); 
    final TextEditingController priceController = TextEditingController();
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
                TextField(
                  controller: supplierNameController,
                  decoration: const InputDecoration(labelText: 'Название поставщика'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Адрес поставщика'),
                ),
                TextField(
                  controller: directorNameController,
                  decoration: const InputDecoration(labelText: 'ФИО руководителя'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                ),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(labelText: 'Банк поставщика'),
                ),
                TextField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(labelText: 'Расчетный счет'),
                ),
                TextField(
                  controller: innController,
                  decoration: const InputDecoration(labelText: 'ИНН'),
                ),
                TextField(
                  controller: deliveryDateController,
                  decoration: const InputDecoration(labelText: 'Дата поставки (ДД.ММ.ГГГГ)'),
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
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Цена'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
               
                if (supplierNameController.text.isEmpty || addressController.text.isEmpty || directorNameController.text.isEmpty || phoneController.text.isEmpty || bankController.text.isEmpty || accountNumberController.text.isEmpty || innController.text.isEmpty || deliveryDateController.text.isEmpty || nameController.text.isEmpty || quantityController.text.isEmpty || unitController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пожалуйста, заполните все поля!')),
                  );
                  return;
                }

                
                final newItem = SellItem(
                  name: nameController.text,
                  unit: unitController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  supplier: Supplier(
                    name: supplierNameController.text, 
                    address: addressController.text,
                    directorName: directorNameController.text,
                    phone: phoneController.text,
                    bank: bankController.text,
                    accountNumber: accountNumberController.text,
                    inn: innController.text,
                  ),
                  deliveryDate: deliveryDateController.text,
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

  Future<void> _saveSellItem(SellItem item) async {
    try {
      // String jsonString = jsonEncode(item.toJson());
      final filePath = 'assets/central_warehouse.json';
      final file = File(filePath);
      List<dynamic> SellItems = [];
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        if (fileContent.isNotEmpty) {
          SellItems = jsonDecode(fileContent);
        }
      }
      SellItems.add(item.toJson());
      await file.writeAsString(jsonEncode(SellItems));
      print('Элемент успешно сохранен!');
    } catch (e) {
      print('Ошибка при сохранении элемента: $e');
    }
  }
}