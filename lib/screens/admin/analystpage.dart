import 'package:coffeeapp/widgets/analystchart.dart';
import 'package:coffeeapp/models/chartdata.dart';
import 'package:coffeeapp/models/namedchartdatalist.dart';
import 'package:coffeeapp/models/revenue.dart';
import 'package:coffeeapp/services/revenue_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnalystPage extends StatefulWidget {
  const AnalystPage({super.key});

  @override
  State<AnalystPage> createState() => _AnalystPageState();
}

class _AnalystPageState extends State<AnalystPage> {
  late List<NamedChartData> chartDataList = [];

  Future<List<NamedChartData>> LoadData() async {
    List<ChartData> revenue = [];
    List<ChartData> productSold = [];
    List<ChartData> orderDelivered = [];
    List<ChartData> interest = [];

    final now = DateTime.now();

    // Query data from 2 years ago to next year
    for (int year = now.year - 2; year < now.year + 1; year++) {
      // Get revenues for the year
      List<Revenue> yearlyRevenues = await RevenueService.getRevenueByYear(year);

      // Initialize monthly stats
      Map<int, Map<String, dynamic>> monthlyStats = {};
      for (int i = 1; i <= 12; i++) {
        monthlyStats[i] = {
          'revenue': 0.0,
          'productSold': 0,
          'orders': 0,
          'profit': 0.0,
        };
      }

      // Aggregate data
      for (var rev in yearlyRevenues) {
        int month = 0;
        // Parse date to find month. Assumes format yyyy-MM-dd from RevenueService
        // or dd/MM/yyyy from Revenue.fromFirestore fallback
        List<String> parts = rev.date.split('-');
        if (parts.length >= 2) {
           month = int.tryParse(parts[1]) ?? 0;
        } else {
           parts = rev.date.split('/');
           if (parts.length >= 2) {
             month = int.tryParse(parts[1]) ?? 0;
           }
        }

        if (month >= 1 && month <= 12) {
          monthlyStats[month]!['revenue'] += rev.totalRevenue;
          monthlyStats[month]!['productSold'] += rev.productsSold;
          monthlyStats[month]!['orders'] += rev.totalOrders;
          monthlyStats[month]!['profit'] += rev.totalProfit;
        }
      }

      // Add to chart data
      for (int month = 1; month <= 12; month++) {
        final stats = monthlyStats[month]!;
        revenue.add(ChartData(
            (stats['revenue'] as double).toInt(), month.toString(), year.toString()));
        productSold.add(ChartData(
            stats['productSold'] as int, month.toString(), year.toString()));
        orderDelivered.add(ChartData(
            stats['orders'] as int, month.toString(), year.toString()));
        interest.add(ChartData(
            (stats['profit'] as double).toInt(), month.toString(), year.toString()));
      }
    }

    return [
      NamedChartData('Doanh thu', revenue),
      NamedChartData('Sản phẩm đã bán', productSold),
      NamedChartData('Đơn hàng đã giao', orderDelivered),
      NamedChartData('Lợi nhuận', interest),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NamedChartData>>(
      future: LoadData(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset(
              'assets/background/loading.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          );
        } else if (asyncSnapshot.hasError) {
          return Center(child: Text('Lỗi: ${asyncSnapshot.error}'));
        } else if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
           return const Center(child: Text('Không có dữ liệu'));
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnalystChart(chartDataList: asyncSnapshot.data!),
          );
        }
      },
    );
  }
}
