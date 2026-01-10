// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';
import 'package:intl/intl.dart';

class OrderService {
  final CollectionReference _ordersRef = FirebaseFirestore.instance.collection(
    TableInDatabase.OrderTable,
  );
  final CollectionReference _revenueRef =
      FirebaseFirestore.instance.collection('revenue');

  /// Places an order and updates the daily revenue stats within a single atomic transaction.
  Future<void> placeOrderAndUpdateRevenue({required OrderItem order}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the current date in YYYY-MM-DD format to use as the document ID
    final String todayDocId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final DocumentReference orderRef = _ordersRef.doc(order.id);
    final DocumentReference revenueRef = _revenueRef.doc(todayDocId);

    return firestore.runTransaction((transaction) async {
      final DocumentSnapshot revenueSnapshot = await transaction.get(revenueRef);

      double orderTotal = double.tryParse(order.total) ?? 0.0;

      if (!revenueSnapshot.exists) {
        // If the revenue document for today doesn't exist, create it.
        transaction.set(revenueRef, {
          'totalRevenue': orderTotal,
          'totalOrders': 1,
          'orderIds': [order.id],
          'date': Timestamp.now(), // Optional: store the full date for sorting
        });
      } else {
        // If it exists, update it.
        transaction.update(revenueRef, {
          'totalRevenue': FieldValue.increment(orderTotal),
          'totalOrders': FieldValue.increment(1),
          'orderIds': FieldValue.arrayUnion([order.id]),
        });
      }

      // Finally, set the order document itself.
      transaction.set(orderRef, order.toJson());
    }).catchError((error) {
      print("Transaction failed: $error");
      throw Exception("Failed to place order. Please try again.");
    });
  }

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
