import 'package:kyrsach/models/supplier.dart';

class StockItem {
  String name;
  String unit;
  double price;
  int quantity;
  Supplier supplier;
  String deliveryDate; 

  StockItem({
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.supplier,
    required this.deliveryDate, 
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      name: json['name'],
      unit: json['unit'],
      price: json['price'],
      quantity: json['quantity'],
      supplier: Supplier.fromJson(json['supplier']),
      deliveryDate: json['deliveryDate'],
    );
  }

  Map<String, dynamic> toJson() { 
    return {
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'supplier': supplier.toJson(), 
      'deliveryDate': deliveryDate, 
    };
  }
}
