import 'package:flutter/material.dart';
import 'package:kyrsach/components/app.dart';
import 'package:kyrsach/models/product.dart';
import 'package:kyrsach/models/order_item.dart';

class ApplicationPage extends StatefulWidget {
  final String level;
  final String store;

  ApplicationPage({required this.level, required this.store});

  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  late Future<List<OrderItem>> items;
  late ApplicationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ApplicationController(level: widget.level, store: widget.store);
    items = _controller.loadApplications();
  }

  void _createApplication(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final orderDateController = TextEditingController(); 
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedUnit = 'шт';
    
    // Получаем текущий максимальный ID
    final currentItems = await items;
    int newId = currentItems.isEmpty ? 1 : 
        (currentItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1);
    
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
                    id: newId, // Используем вычисленный ID
                    status: 'Без ответа',
                    storeName: widget.store,
                    orderDate: orderDateController.text,
                    product: Product(
                      name: nameController.text, 
                      unit: selectedUnit, 
                      quantity: int.parse(quantityController.text),
                    ),
                  );

                  Navigator.pop(context);
                  await _controller.saveOrderItem(newItem);
                  setState(() => items = _controller.loadApplications());
                  
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

  void _showApplicationDetails(BuildContext context, OrderItem item) {
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
                onPressed: () async {
                  try {
                    await _controller.acceptApplication(context, item);
                    setState(() {
                      items = _controller.loadApplications();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Заявка принята! Товар перемещен в магазин.')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text('Принять'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.pop(context);
                    await _controller.updateApplicationStatus(item, 'Отклонено');
                    setState(() {
                      items = _controller.loadApplications();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заявка отклонена!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  }
                },
                child: Text('Отклонить'),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заявки')),
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
                    onTap: () => _showApplicationDetails(context, item),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.level == 'seller'
          ? FloatingActionButton(
              onPressed: () => _createApplication(context),
              child: const Icon(Icons.add),
              tooltip: 'Создать заявку',
            )
          : null, 
    );
  }
}