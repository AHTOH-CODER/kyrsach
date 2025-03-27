import 'package:flutter/material.dart';
import 'package:kyrsach/models/store.dart';

class ProductListScreen extends StatelessWidget {
  final Store store;

  ProductListScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
      ),
      body: ListView.builder(
        itemCount: store.products.length,
        itemBuilder: (context, index) {
          final product = store.products[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Container(
              color: const Color.fromARGB(255, 228, 232, 240),
              child: ListTile(
                title: Text(product.name),
                subtitle: Text('${product.quantity} ${product.unit}'),
              ),
            ),
          );
        },
      ),
    );
  }
}