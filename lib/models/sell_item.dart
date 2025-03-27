import 'package:kyrsach/models/product.dart';
import 'package:kyrsach/models/profile.dart';

class SellItem {
  double price;
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
      'sellDate': sellDate, 
      'product': product.toJson(),
    };
  }
}