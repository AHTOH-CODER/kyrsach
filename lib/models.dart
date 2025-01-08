import 'package:kyrsach/pages/profile.dart';

class Product {
  String name;
  String unit;
  int quantity;

  Product({required this.name, required this.unit, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      unit: json['unit'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'quantity': quantity,
    };
  }
}

class Supplier {
  String name;
  String address;
  String directorName;
  String phone;
  String bank;
  String accountNumber;
  String inn;

  Supplier({
    required this.name,
    required this.address,
    required this.directorName,
    required this.phone,
    required this.bank,
    required this.accountNumber,
    required this.inn,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      name: json['name'],
      address: json['address'],
      directorName: json['directorName'],
      phone: json['phone'],
      bank: json['bank'],
      accountNumber: json['accountNumber'],
      inn: json['inn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'directorName': directorName,
      'phone': phone,
      'bank': bank,
      'accountNumber': accountNumber,
      'inn': inn,
    };
  }
}

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
}

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


class OrderItem {
  String status;
  String storeName;
  String orderDate; 
  Product product;

  OrderItem({
    required this.status,
    required this.storeName,
    required this.orderDate, 
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      status: json['status'],
      storeName: json['storeName'],
      orderDate: json['orderDate'],
      product: Product.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() { 
    return {
      'status': status,
      'storeName': storeName, 
      'orderDate': orderDate, 
      'product': product.toJson(),
    };
  }
}


class SellItem {
  String price;
  Profile profile;
  String sellDate; 
  Product product;

  SellItem({
    required this.price,
    required this.profile,
    required this.sellDate,
    required this.product,
  });

  factory SellItem.fromJson(Map<String, dynamic> json) {
    return SellItem(
      price: json['price'],
      profile: Profile.fromJson(json['profile']),
      sellDate: json['sellDate'],
      product: Product.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() { 
    return {
      'price': price,
      'profile': profile.toJson(),
      'orderDate': sellDate, 
      'product': product.toJson(),
    };
  }
}