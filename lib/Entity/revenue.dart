import 'package:cloud_firestore/cloud_firestore.dart';

class Revenue {
  final String date;
  final double totalRevenue;
  final int totalOrders;
  final List<String> orderIds;

  Revenue({
    required this.date,
    required this.totalRevenue,
    required this.totalOrders,
    required this.orderIds,
  });

  // DÙNG cho QUERY SNAPSHOT (Stream)
  factory Revenue.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Revenue(
      date: data['date'],
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      orderIds: List<String>.from(data['orderIds'] ?? []),
    );
  }

  // DÙNG CHO WRITE
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'orderIds': orderIds,
    };
  }
}
