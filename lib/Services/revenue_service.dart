import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/models/revenue.dart';

class RevenueService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  //// SAVE REVENUE
  static Future<void> saveRevenue({
    required double amount,
    required String orderId,
    required int productsCount,
    required double profit,
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
          'productsSold': (data['productsSold'] ?? 0) + productsCount,
          'totalProfit': (data['totalProfit'] ?? 0) + profit,
          // Update month/year just in case, though they shouldn't change for the same dateId
          'month': now.month, 
          'year': now.year,
        });
      } else {
        final revenue = Revenue(
          date: dateId,
          totalRevenue: amount,
          totalOrders: 1,
          orderIds: [orderId],
          productsSold: productsCount,
          totalProfit: profit,
        );
        final revenueData = revenue.toMap();
        revenueData['month'] = now.month;
        revenueData['year'] = now.year;
        
        transaction.set(revenueRef, revenueData);
      }
    });
  }
  

  /// Provides a stream of daily revenue documents, ordered by date descending.
  Stream<List<Revenue>> getRevenueStream() {
    return _firestore
        .collection('revenue')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Revenue.fromFirestore(doc)).toList();
    });
  }

  /// Get revenue list for a specific year
  static Future<List<Revenue>> getRevenueByYear(int year) async {
    // Note: This requires an index on 'year' if data is large, 
    // but for now standard query should work fine or prompt index creation
    final snapshot = await _firestore
        .collection('revenue')
        .where('year', isEqualTo: year)
        .get();

    return snapshot.docs.map((doc) => Revenue.fromFirestore(doc)).toList();
  }
}
