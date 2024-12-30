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
  String deliveryDate; // Добавлено поле deliveryDate

  StockItem({
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.supplier,
    required this.deliveryDate, // Добавлено в конструктор
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      name: json['name'],
      unit: json['unit'],
      price: json['price'],
      quantity: json['quantity'],
      supplier: Supplier.fromJson(json['supplier']),
      deliveryDate: json['deliveryDate'], // Теперь правильно извлекаем deliveryDate
    );
  }

  Map<String, dynamic> toJson() { // Реализован метод toJson
    return {
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'supplier': supplier.toJson(), // Вызов метода toJson у Supplier
      'deliveryDate': deliveryDate, // Добавлено в JSON представление
    };
  }
}
