import 'dart:ui';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/chartdata.dart';
import 'package:coffeeapp/models/namedchartdatalist.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalystChart extends StatefulWidget {
  final List<NamedChartData> chartDataList;

  const AnalystChart({super.key, required this.chartDataList});

  @override
  State<AnalystChart> createState() => _AnalystChartState();
}

class _AnalystChartState extends State<AnalystChart> {
  late String formattedDate;
  late double totalRevenue, totalProductSold, totalOrderDeliveried, totalInterest;

  @override
  void initState() {
    super.initState();
    var formatter = DateFormat('yyyy');
    formattedDate = formatter.format(DateTime.now());
    totalRevenue = 0;
    totalProductSold = 0;
    totalOrderDeliveried = 0;
    totalInterest = 0;

    if (widget.chartDataList.isEmpty || widget.chartDataList.length < 4) {
      return;
    }

    if (widget.chartDataList[0].data.isNotEmpty &&
        widget.chartDataList[1].data.isNotEmpty &&
        widget.chartDataList[2].data.isNotEmpty &&
        widget.chartDataList[3].data.isNotEmpty) {
      
      totalRevenue = widget.chartDataList[0].data.fold<double>(0, (sum, data) => sum + data.value);
      totalProductSold = widget.chartDataList[1].data.fold<double>(0, (sum, data) => sum + data.value);
      totalOrderDeliveried = widget.chartDataList[2].data.fold<double>(0, (sum, data) => sum + data.value);
      totalInterest = widget.chartDataList[3].data.fold<double>(0, (sum, data) => sum + data.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thống kê - $formattedDate',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                if (widget.chartDataList.length >= 4) ...[
                  _buildBarChartSection(
                    title: 'Doanh thu',
                    dataList: widget.chartDataList[0].data,
                    barColor: Colors.blueAccent,
                  ),
                   _buildBarChartSection(
                    title: 'Sản phẩm đã bán',
                    dataList: widget.chartDataList[1].data,
                    barColor: Colors.orangeAccent,
                  ),
                   _buildBarChartSection(
                    title: 'Đơn hàng đã giao',
                    dataList: widget.chartDataList[2].data,
                    barColor: Colors.green,
                  ),
                   _buildBarChartSection(
                    title: 'Lợi nhuận',
                    dataList: widget.chartDataList[3].data,
                    barColor: Colors.purpleAccent,
                  ),
                ] else
                  const Center(child: Text("Dữ liệu không đầy đủ")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartSection({
    required String title,
    required List<ChartData> dataList,
    required Color barColor,
  }) {
    if (dataList.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
             const SizedBox(height: 16),
             const Text('Dữ liệu không có', style: TextStyle(fontSize: 16, color: Colors.grey)),
             const SizedBox(height: 30),
          ],
        );
    }

    // Find max Y for scaling
    double maxY = 0;
    for (var item in dataList) {
      if (item.value > maxY) maxY = item.value.toDouble();
    }
    if (maxY == 0) maxY = 10;
    maxY = maxY * 1.2; // Add buffer

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
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
                    // Get data item safely
                    String month = "";
                    if (group.x.toInt() < dataList.length) {
                       month = dataList[group.x.toInt()].month;
                    }
                    return BarTooltipItem(
                      "$month\n",
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: currency.format(rod.toY),
                          style: TextStyle(
                            color: barColor, // Use bar color for value
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                      if (index < 0 || index >= dataList.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dataList[index].month,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
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
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: dataList.asMap().entries.map((e) {
                final index = e.key;
                final data = e.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.value.toDouble(),
                      color: barColor,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: barColor.withOpacity(0.05),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
