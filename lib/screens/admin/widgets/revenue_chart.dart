import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/revenue.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatelessWidget {
  final List<Revenue> revenueData;

  const RevenueChart({super.key, required this.revenueData});

  @override
  Widget build(BuildContext context) {
    // Chỉ lấy tối đa 7 ngày gần nhất để hiển thị
    final displayData = revenueData.length > 7
        ? revenueData.sublist(revenueData.length - 7)
        : revenueData;

    // Tìm giá trị lớn nhất để scale biểu đồ
    double maxY = 0;
    for (var r in displayData) {
      if (r.totalRevenue > maxY) maxY = r.totalRevenue;
    }
    // Thêm khoảng đệm cho maxY (e.g. + 20%)
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100000; // Default nếu chưa có data

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Biểu đồ Doanh thu (7 ngày)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final currency = NumberFormat("#,##0", "vi_VN");
                      return BarTooltipItem(
                        currency.format(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayData.length) {
                          return const SizedBox.shrink();
                        }
                        // Giả sử date format là dd/MM/yyyy, lấy phần ngày dd
                        final dateStr = displayData[index].date;
                        String day = dateStr.split('/')[0];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Ẩn cột Y bên trái cho gọn
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: displayData.asMap().entries.map((e) {
                  final index = e.key;
                  final data = e.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.totalRevenue,
                        color: AppColors.primaryColor,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppColors.primaryColor.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
