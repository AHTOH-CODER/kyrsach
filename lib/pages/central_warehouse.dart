import 'package:flutter/material.dart';
import 'package:kyrsach/pages/warehouse_inventory.dart';
import 'package:kyrsach/components/cen.dart';
import 'package:kyrsach/models/supplier.dart';
import 'package:kyrsach/models/stock_item.dart';


class CentralWarehouseScreen extends StatefulWidget {
  final String level;

  CentralWarehouseScreen({required this.level});

  @override
  State<CentralWarehouseScreen> createState() => _CentralWarehouseScreenState();
}

class _CentralWarehouseScreenState extends State<CentralWarehouseScreen> {
  late Future<List<StockItem>> items;
  final CentralWarehouseController _controller = CentralWarehouseController();
  
  @override
  void initState() {
    super.initState();
    items = _controller.loadStockItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Центральный склад'),
      ),
      body: FutureBuilder<List<StockItem>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }

          final stockItems = snapshot.data!.reversed.toList();

          return ListView.builder(
            itemCount: stockItems.length,
            itemBuilder: (context, index) {
              final item = stockItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  color: const Color.fromARGB(255, 228, 232, 240),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} ${item.unit} - ${item.price} ₽'),
                    onTap: () => _showSupplierInfo(context, item.supplier),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.level == 'admin')
            FloatingActionButton(
              onPressed: () => _showRegisterProductDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Зарегистрировать товар',
            ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WarehouseInventory()),
              );
            },
            child: const Icon(Icons.inventory),
            tooltip: 'Содержимое склада',
          ),
        ],
      ),
    );
  }

  void _showSupplierInfo(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Поставщик:'),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final supplierNameController = TextEditingController();
    final addressController = TextEditingController();
    final directorNameController = TextEditingController();
    final phoneController = TextEditingController();
    final bankController = TextEditingController();
    final accountNumberController = TextEditingController();
    final innController = TextEditingController();
    final deliveryDateController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    
    String selectedUnit = 'шт';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый товар'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Информация о поставщике', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: supplierNameController,
                  decoration: const InputDecoration(labelText: 'Название*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Адрес*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: directorNameController,
                  decoration: const InputDecoration(labelText: 'Руководитель*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: bankController,
                  decoration: const InputDecoration(labelText: 'Банк*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(labelText: 'Счет*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: innController,
                  decoration: const InputDecoration(labelText: 'ИНН*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                  keyboardType: TextInputType.number,
                ),
                const Divider(),
                const Text('Информация о товаре', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название товара*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Количество*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  items: ['шт', 'л', 'кг'].map((unit) => 
                    DropdownMenuItem(value: unit, child: Text(unit))
                  ).toList(),
                  onChanged: (v) => selectedUnit = v!,
                  decoration: const InputDecoration(labelText: 'Единица измерения'),
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Цена*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: deliveryDateController,
                  decoration: const InputDecoration(labelText: 'Дата поставки (ДД.ММ.ГГГГ)*'),
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательное поле' : null,
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
                try {
                  final newItem = StockItem(
                    name: nameController.text,
                    unit: selectedUnit,
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

                  Navigator.pop(context);
                  await _controller.saveStockItem(newItem);
                  setState(() => items = _controller.loadStockItems());
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${newItem.name} успешно добавлен')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}