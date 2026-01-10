import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueDashboardPage extends StatelessWidget {
  const RevenueDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo cáo Doanh thu"),
      ),
      body: StreamBuilder<List<Revenue>>(
        stream: FirebaseDBManager.revenueService.getRevenueStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Chưa có dữ liệu doanh thu."));
          }

          final revenueDocs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: revenueDocs.length,
            itemBuilder: (context, index) {
              final dailyRevenue = revenueDocs[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      dailyRevenue.date.substring(8), // Day of month
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    "Ngày: ${dailyRevenue.date}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Tổng số đơn: ${dailyRevenue.totalOrders}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: Text(
                    "${currencyFormat.format(dailyRevenue.totalRevenue)} đ",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
