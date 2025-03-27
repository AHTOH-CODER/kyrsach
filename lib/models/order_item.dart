import 'package:kyrsach/models/product.dart';

class OrderItem {
  final int id;
  final String status;
  final String storeName;
  final String orderDate;
  final Product product;

  OrderItem({
    required this.id,
    required this.status,
    required this.storeName,
    required this.orderDate,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      status: json['status'],
      storeName: json['storeName'],
      orderDate: json['orderDate'],
      product: Product.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'storeName': storeName,
      'orderDate': orderDate,
      'product': product.toJson(),
    };
  }
}