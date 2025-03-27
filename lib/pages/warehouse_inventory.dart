import 'package:flutter/material.dart';
import 'package:kyrsach/models/product.dart';
import 'package:kyrsach/components/war.dart';

class WarehouseInventory extends StatefulWidget {
  @override
  _WarehouseInventoryViewState createState() => _WarehouseInventoryViewState();
}

class _WarehouseInventoryViewState extends State<WarehouseInventory> {
  final WarehouseInventoryController _controller = WarehouseInventoryController();

  @override
  void initState() {
    super.initState();
    _controller.loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Содержимое склада'),
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: _controller.inventoryItems,
        builder: (context, inventoryData, _) {
          if (inventoryData.isEmpty) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Склад пуст'));
            }
          }

          return ListView.builder(
            itemCount: inventoryData.length,
            itemBuilder: (context, index) {
              final item = inventoryData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  color: const Color.fromARGB(255, 228, 232, 240),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} ${item.unit}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}