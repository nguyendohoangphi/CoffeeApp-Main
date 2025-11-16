import 'package:coffeeapp/Entity/Product.dart';

class CartItem {
  late String id;
  late String idOrder;
  final String productName;
  late Product product;
  final SizeOption size;
  late int amount;

  CartItem({
    required this.idOrder,
    required this.productName,
    required this.product,
    required this.amount,
    required this.size,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    idOrder: json['idOrder'],
    productName: json['productName'],
    amount: json['amount'],
    size: stringToEnum(SizeOption.values, json['size']),
    product: Product(
      createDate: '',
      name: '',
      imageUrl: '',
      description: '',
      rating: 0,
      reviewCount: 0,
      price: 0,
      type: "Cà phê",
    ),
  );

  Map<String, dynamic> toJson(String idOrder) => {
    'idOrder': idOrder,
    'productName': productName,
    'size': enumToString(size),
    'amount': amount,
  };
}

// ignore: constant_identifier_names
enum SizeOption { Small, Medium, Large }
