import 'package:kyrsach/models/product.dart';

class Store {
  String name;
  String address;
  List<Product> products;

  Store({required this.name, required this.address, required this.products});

  factory Store.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List;
    List<Product> productListParsed = productList.map((i) => Product.fromJson(i)).toList();

    return Store(
      name: json['name'],
      address: json['address'],
      products: productListParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }

  factory Store.empty() => Store(
    name: '',
    address: '',
    products: [],
  );
}