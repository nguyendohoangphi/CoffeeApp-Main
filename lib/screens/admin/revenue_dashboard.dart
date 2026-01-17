import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/revenue.dart';
import 'package:coffeeapp/screens/admin/widgets/admin_summary_card.dart';
import 'package:coffeeapp/screens/admin/widgets/revenue_chart.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueDashboardPage extends StatelessWidget {
  const RevenueDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Báo cáo Doanh thu",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
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
              child:
                  Text("Chưa có dữ liệu doanh thu.", style: TextStyle(fontSize: 16)),
            );
          }

          final revenueDocs = snapshot.data!;
          // Sort data by date (assuming date is comparable string like YYYY-MM-DD or we trust the order.
          // The current date format seems to be dd/MM/yyyy based on previous code.
          // String comparison for dd/MM/yyyy is NOT correct for sorting.
          // Ideally we should parse to DateTime.
          revenueDocs.sort((a, b) {
             try {
               final dateA = DateFormat('dd/MM/yyyy').parse(a.date);
               final dateB = DateFormat('dd/MM/yyyy').parse(b.date);
               return dateA.compareTo(dateB);
             } catch (e) {
               return 0;
             }
          });
          
          
          // Calculate summary metrics
          double totalRevenue = 0;
          int totalOrders = 0;
          for (var doc in revenueDocs) {
            totalRevenue += doc.totalRevenue;
            totalOrders += doc.totalOrders;
          }
          double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Section
                Row(
                  children: [
                    Expanded(
                      child: AdminSummaryCard(
                        title: "Tổng doanh thu",
                        value: "${currencyFormat.format(totalRevenue)} đ",
                        icon: Icons.monetization_on,
                        iconColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminSummaryCard(
                        title: "Tổng đơn hàng",
                        value: "$totalOrders",
                        icon: Icons.shopping_bag,
                        iconColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdminSummaryCard(
                  title: "Giá trị trung bình / đơn",
                  value: "${currencyFormat.format(avgOrderValue)} đ",
                  icon: Icons.analytics,
                  iconColor: Colors.blue,
                ),

                const SizedBox(height: 24),

                // Chart Section
                RevenueChart(revenueData: revenueDocs),

                const SizedBox(height: 24),
                const Text(
                  "Lịch sử chi tiết",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),

                // Recent Transactions List (Reverse order to show newest first)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: revenueDocs.length,
                  itemBuilder: (context, index) {
                    // Show newest first
                    final dailyRevenue = revenueDocs[revenueDocs.length - 1 - index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_today,
                              color: AppColors.primaryColor, size: 20),
                        ),
                        title: Text(
                          dailyRevenue.date,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "${dailyRevenue.totalOrders} đơn hàng",
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

