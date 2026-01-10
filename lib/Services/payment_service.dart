import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the daily revenue summary stored in the 'revenue' collection.
class Revenue {
  final String date; // Document ID in YYYY-MM-DD format
  final double totalRevenue;
  final int totalOrders;
  final List<String> orderIds;

  Revenue({
    required this.date,
    required this.totalRevenue,
    required this.totalOrders,
    required this.orderIds,
  });

  // Factory constructor to create a Revenue object from a Firestore document
  factory Revenue.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Revenue(
      date: doc.id,
      totalRevenue: (data['totalRevenue'] as num).toDouble(),
      totalOrders: data['totalOrders'] as int,
      orderIds: List<String>.from(data['orderIds']),
    );
  }

  // Method to convert a Revenue object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'orderIds': orderIds,
    };
  }
}


/// A service to simulate payment processing.
/// In a real-world scenario, this would make HTTP requests to your backend,
/// which in turn communicates with the payment gateway (e.g., MoMo).
class PaymentService {

  /// Simulates processing a payment for a given order.
  ///
  /// This function fakes a delay to mimic a network call to a backend.
  /// It will always return `true` to simulate a successful payment for this demo.
  /// 
  /// Returns `true` for a successful payment, `false` otherwise.
  Future<bool> processPayment({
    required double amount,
    required String orderId,
  }) async {
    print(' simulating a call to a backend payment gateway...');
    print('Processing payment for order $orderId with amount $amount');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you'd get a real response from your backend.
    // For this demo, we'll always assume the payment is successful.
    print('Payment successful!');
    return true; 
  }
}
