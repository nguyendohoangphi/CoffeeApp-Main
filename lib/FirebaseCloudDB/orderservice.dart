import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class OrderService {
  final CollectionReference _ordersRef = FirebaseFirestore.instance.collection(
    TableInDatabase.OrderTable,
  );

  // CREATE
  Future<void> createOrder(OrderItem order) async {
    try {
      await _ordersRef.doc(order.id).set(order.toJson());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // READ - Get all orders for a user
  Future<List<OrderItem>> getOrdersByEmail(String email) async {
    final snapshot = await _ordersRef.where('email', isEqualTo: email).get();

    if (snapshot.docs.isEmpty) {
      print("No orders found for email: $email");
      return [];
    }

    return snapshot.docs
        .map((doc) => OrderItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // READ - Get all orders (Admin or general listing)
  Future<List<OrderItem>> getAllOrders() async {
    final snapshot = await _ordersRef.get();

    if (snapshot.docs.isEmpty) {
      print("No orders found in the database.");
      return [];
    }

    return snapshot.docs
        .map((doc) => OrderItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // UPDATE - Change status
  Future<void> updateOrderStatus(String id, StatusOrder newStatus) async {
    try {
      await _ordersRef.doc(id).update({'statusOrder': enumToString(newStatus)});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // DELETE
  Future<void> deleteOrder(String id) async {
    try {
      await _ordersRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}
