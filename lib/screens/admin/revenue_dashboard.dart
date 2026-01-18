import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/revenue.dart';
import 'package:coffeeapp/screens/admin/widgets/admin_summary_card.dart';
import 'package:coffeeapp/screens/admin/widgets/revenue_chart.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueDashboardPage extends StatefulWidget {
  const RevenueDashboardPage({super.key});

  @override
  State<RevenueDashboardPage> createState() => _RevenueDashboardPageState();
}

class _RevenueDashboardPageState extends State<RevenueDashboardPage> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Chọn tháng',
      fieldLabelText: 'Nhập ngày trong tháng mong muốn',
      fieldHintText: 'dd/MM/yyyy',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Pre-process data to ensure every day of the month has a value (even if 0)
  List<Revenue> _prepareDailyData(List<Revenue> fetchedData, DateTime monthDate) {
    // Determine days in month
    int daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    List<Revenue> fullMonthData = [];

    for (int i = 1; i <= daysInMonth; i++) {
        String dayStr = "$i".padLeft(2, '0');
        // Construct the date string matching the format stored in Firestore (yyyy-MM-dd)
        String dateKey = "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}-$dayStr";
        
        // Find existing data for this day
        // Revenue.fromFirestore converts everything to "dd/MM/yyyy" format
        // So we should match against that.
        String displayDate = "$dayStr/${monthDate.month.toString().padLeft(2, '0')}/${monthDate.year}";

        var daily = fetchedData.firstWhere(
            (r) => r.date == displayDate || r.date == dateKey, // Check both just in case
            orElse: () => Revenue(
                date: displayDate,
                totalRevenue: 0,
                totalOrders: 0,
                orderIds: [],
                productsSold: 0,
                totalProfit: 0
            ) 
        );
        fullMonthData.add(daily);
    }
    return fullMonthData;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");
    final monthFormat = DateFormat("MM/yyyy");

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
        actions: [
          TextButton.icon(
            onPressed: () => _selectMonth(context),
            icon: const Icon(Icons.calendar_month, color: AppColors.primaryColor),
            label: Text(
              monthFormat.format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Revenue>>(
        stream: FirebaseDBManager.revenueService.getMonthlyRevenueStream(_selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }
          
          final rawRevenueDocs = snapshot.data ?? [];
          final revenueDocs = _prepareDailyData(rawRevenueDocs, _selectedDate);

          // Calculate summary metrics from RAW data (only actual sales)
          double totalRevenue = 0;
          int totalOrders = 0;
          for (var doc in rawRevenueDocs) {
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
                        title: "Doanh thu tháng",
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
                  title: "Trung bình / đơn",
                  value: "${currencyFormat.format(avgOrderValue)} đ",
                  icon: Icons.analytics,
                  iconColor: Colors.blue,
                ),

                const SizedBox(height: 24),

                // Chart Section
                Text(
                   "Biểu đồ ngày trong tháng ${monthFormat.format(_selectedDate)}",
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                RevenueChart(revenueData: revenueDocs),

                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chi tiết ngày có đơn",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                     if (rawRevenueDocs.isEmpty)
                        const Text("(Không có dữ liệu)", style: TextStyle(color: Colors.grey))
                  ],
                ),
                
                const SizedBox(height: 12),

                // Recent Transactions List (Only show days with data)
                // Reverse to show latest dates first
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rawRevenueDocs.length,
                  itemBuilder: (context, index) {
                    final dailyRevenue = rawRevenueDocs[rawRevenueDocs.length - 1 - index];
                    
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
                          dailyRevenue.date, // This is already formatted as dd/MM/yyyy from model
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "${dailyRevenue.totalOrders} đơn hàng - ${dailyRevenue.productsSold} sản phẩm",
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
