import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/payment_status.dart';  

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
  final String note;

  final PaymentStatus paymentStatus;  
  final String? transactionId;  
  final bool isMockPayment;  

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
    this.note = '',
    this.paymentStatus = PaymentStatus.pending,  
    this.transactionId,  
    this.isMockPayment = false,  
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
    note: json['note'] ?? '',
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
    'note': note,
  };
}

// ignore: constant_identifier_names
enum StatusOrder { Waiting, Processing, Shipping, Finished }
