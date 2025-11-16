import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';

class OrderItem {
  final String id;
  final String createDate;
  final String timeOrder;
  late StatusOrder statusOrder;
  late List<CartItem> cartItems;
  final String email;
  final String table;
  final String phone;
  final String name;
  final String total;
  final String coupon;

  OrderItem({
    required this.table,
    required this.phone,
    required this.name,
    required this.id,
    required this.createDate,
    required this.timeOrder,
    required this.statusOrder,
    required this.email,
    required this.cartItems,
    required this.total,
    required this.coupon,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    createDate: json['createDate'],
    timeOrder: json['timeOrder'],
    statusOrder: stringToEnum(StatusOrder.values, json['statusOrder']),
    email: json['email'],
    cartItems: [],
    table: json['table'],
    phone: json['phone'],
    name: json['name'],
    total: json['total'],
    coupon: json['coupon'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createDate': createDate,
    'timeOrder': timeOrder,
    'statusOrder': enumToString(statusOrder),
    'email': email,
    'table': table,
    'phone': phone,
    'name': name,
    'total': total,
    'coupon': coupon,
  };
}

// ignore: constant_identifier_names
enum StatusOrder { Waiting, Processing, Shipping, Finished }
