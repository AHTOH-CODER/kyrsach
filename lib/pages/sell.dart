import 'package:flutter/material.dart';
import 'package:kyrsach/models/profile.dart';
import 'package:kyrsach/components/sel.dart';
import 'package:kyrsach/models/product.dart';
import 'package:kyrsach/models/store.dart';
import 'package:kyrsach/models/sell_item.dart';

class SellPage extends StatefulWidget {
  final Profile? profile;

  const SellPage({required this.profile, Key? key}) : super(key: key);

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  late Future<List<SellItem>> sellItems;
  late Future<List<Store>> stores;
  final SellController _controller = SellController();
  List<Product> availableProducts = [];

  @override
  void initState() {
    super.initState();
    sellItems = _controller.loadSellItems();
    stores = _controller.loadStores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Продажи')),
      body: FutureBuilder<List<SellItem>>(
        future: sellItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных о продажах'));
          }

          final reversedItems = snapshot.data!.reversed.toList();

          return ListView.builder(
            itemCount: reversedItems.length,
            itemBuilder: (context, index) {
              final item = reversedItems[index];
              return _buildSellItem(item);
            },
          );
        },
      ),
      floatingActionButton: widget.profile?.level == 'seller'
          ? FloatingActionButton(
              onPressed: () => _showSellDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Продать товар',
            )
          : null,
    );
  }

  Widget _buildSellItem(SellItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        color: const Color.fromARGB(255, 228, 232, 240),
        child: ListTile(
          title: Text(item.product.name),
          subtitle: Text('${item.product.quantity} ${item.product.unit} - ${item.price} ₽'),
          onTap: () => _showSellInfo(context, item),
        ),
      ),
    );
  }

  void _showSellInfo(BuildContext context, SellItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация о продаже:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Продавец:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text('ФИО: ${item.profile.fullName}'),
            Text('Магазин: ${item.profile.store}'),
            const SizedBox(height: 20),
            Text('Дата продажи: ${item.sellDate}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSellDialog(BuildContext context) async {
    final sellDateController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedProduct;
    int selectedQuantity = 0;

    try {
      final storesList = await stores;
      final currentStore = storesList.firstWhere(
        (store) => store.name == widget.profile?.store,
        orElse: () => Store.empty(),
      );
      
      if (currentStore.name.isEmpty) {
        throw Exception('Магазин не найден');
      }

      availableProducts = currentStore.products;

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Регистрация продажи'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: sellDateController,
                      decoration: const InputDecoration(labelText: 'Дата продажи (ДД.ММ.ГГГГ)'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedProduct,
                      items: availableProducts.map((product) {
                        return DropdownMenuItem(
                          value: product.name,
                          child: Text('${product.name} (${product.quantity} ${product.unit})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedProduct = value),
                      decoration: const InputDecoration(labelText: 'Товар'),
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Количество'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => selectedQuantity = int.tryParse(value) ?? 0,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedProduct == null || selectedQuantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните все поля правильно')),
                      );
                      return;
                    }

                    final product = availableProducts.firstWhere(
                      (p) => p.name == selectedProduct,
                      orElse: () => Product.empty(),
                    );

                    if (product.name.isEmpty) {
                      throw Exception('Товар не найден');
                    }

                    if (selectedQuantity > product.quantity) {
                      throw Exception('Недостаточно товара');
                    }

                    final newItem = SellItem(
                      price: double.tryParse(priceController.text) ?? 0.0,
                      product: Product(
                        name: product.name,
                        unit: product.unit,
                        quantity: selectedQuantity,
                      ),
                      profile: widget.profile!,
                      sellDate: sellDateController.text,
                    );

                    Navigator.pop(context);
                    await _controller.saveSellItem(newItem, widget.profile!.store);
                    setState(() => sellItems = _controller.loadSellItems());
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}