import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/revenue.dart';

class RevenueService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  //// SAVE REVENUE
  static Future<void> saveRevenue({
    required double amount,
    required String orderId,
  }) async {
    final now = DateTime.now();
    final dateId =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final revenueRef =
        _firestore.collection('revenue').doc(dateId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(revenueRef);

      if (snapshot.exists) {
        final data = snapshot.data()!;
        transaction.update(revenueRef, {
          'totalRevenue': (data['totalRevenue'] ?? 0) + amount,
          'totalOrders': (data['totalOrders'] ?? 0) + 1,
          'orderIds': FieldValue.arrayUnion([orderId]),
        });
      } else {
        final revenue = Revenue(
          date: dateId,
          totalRevenue: amount,
          totalOrders: 1,
          orderIds: [orderId],
        );
        transaction.set(revenueRef, revenue.toMap());
      }
    });
  }
}
