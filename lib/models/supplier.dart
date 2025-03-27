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