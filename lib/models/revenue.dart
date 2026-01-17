import 'package:cloud_firestore/cloud_firestore.dart';

class Revenue {
  final String date;
  final double totalRevenue;
  final int totalOrders;
  final List<String> orderIds;
  final int productsSold; // Số lượng sản phẩm bán ra
  final double totalProfit; // Lợi nhuận

  Revenue({
    required this.date,
    required this.totalRevenue,
    required this.totalOrders,
    required this.orderIds,
    required this.productsSold,
    required this.totalProfit,
  });

  // DÙNG cho QUERY SNAPSHOT (Stream)
  factory Revenue.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Xử lý field 'date': có thể là String (dd/MM/yyyy) hoặc Timestamp
    String dateStr;
    if (data['date'] is Timestamp) {
        // Convert Timestamp to String (dd/MM/yyyy)
        DateTime dateTime = (data['date'] as Timestamp).toDate();
        dateStr = "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    } else {
        dateStr = data['date'].toString();
    }

    return Revenue(
      date: dateStr,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      orderIds: List<String>.from(data['orderIds'] ?? []),
      productsSold: data['productsSold'] ?? 0,
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
    );
  }

  // DÙNG CHO WRITE
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'orderIds': orderIds,
      'productsSold': productsSold,
      'totalProfit': totalProfit,
    };
  }
}
