import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Services/payment_service.dart';

class RevenueService {
  final CollectionReference _revenueRef =
      FirebaseFirestore.instance.collection('revenue');

  /// Provides a stream of daily revenue documents, ordered by date descending.
  Stream<List<Revenue>> getRevenueStream() {
    return _revenueRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Revenue.fromFirestore(doc)).toList();
    });
  }
}
