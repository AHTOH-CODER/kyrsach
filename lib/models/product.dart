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

  factory Product.empty() => Product(
    name: '',
    unit: '',
    quantity: 0,
  );
}