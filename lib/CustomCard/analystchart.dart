import 'dart:ui';

import 'package:coffeeapp/Entity/chartdata.dart';
import 'package:coffeeapp/Entity/namedchartdatalist.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var formatter = DateFormat('yyyy');
    formattedDate = formatter.format(DateTime.now());
    totalRevenue = 0;
    totalProductSold = 0;
    totalOrderDeliveried = 0;
    totalInterest = 0;

    if (widget.chartDataList.isEmpty) {
      return;
    }

    if (widget.chartDataList[0].data.isNotEmpty &&
        widget.chartDataList[1].data.isNotEmpty &&
        widget.chartDataList[2].data.isNotEmpty &&
        widget.chartDataList[3].data.isNotEmpty) {
      totalRevenue = widget.chartDataList[0].data.fold<double>(
        0,
        (sum, data) => sum + data.value,
      );
      totalProductSold = widget.chartDataList[1].data.fold<double>(
        0,
        (sum, data) => sum + data.value,
      );

      totalOrderDeliveried = widget.chartDataList[2].data.fold<double>(
        0,
        (sum, data) => sum + data.value,
      );

      totalInterest = widget.chartDataList[3].data.fold<double>(
        0,
        (sum, data) => sum + data.value,
      );
    }
  }

  final double sizePieChart = 150;
  late double totalRevenue,
      totalProductSold,
      totalOrderDeliveried,
      totalInterest;

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

                buildPieChartSection(
                  title: 'Doanh thu',
                  dataList: widget.chartDataList[0].data.isNotEmpty
                      ? widget.chartDataList[0].data
                      : [],
                  total: totalRevenue,
                  sizePieChart: sizePieChart,
                  sectionColors: Colors.primaries,
                ),
                buildPieChartSection(
                  title: 'Sản phẩm đã bán',
                  dataList: widget.chartDataList[1].data.isNotEmpty
                      ? widget.chartDataList[1].data
                      : [],
                  total: totalProductSold,
                  sizePieChart: sizePieChart,
                  sectionColors: [
                    Colors.redAccent,
                    Colors.cyanAccent,
                    Colors.blue,
                    Colors.deepOrangeAccent,
                    Colors.pink,
                    Colors.purpleAccent,
                    Colors.orange,
                  ],
                ),
                buildPieChartSection(
                  title: 'Đơn hàng đã giao',
                  dataList: widget.chartDataList[2].data.isNotEmpty
                      ? widget.chartDataList[2].data
                      : [],
                  total: totalOrderDeliveried,
                  sizePieChart: sizePieChart,
                  sectionColors: [
                    Colors.teal,
                    Colors.greenAccent,
                    Colors.blue,
                    Colors.amber,
                    Colors.pink,
                    Colors.cyan,
                    Colors.orange,
                  ],
                ),
                buildPieChartSection(
                  title: 'Lợi nhuận',
                  dataList: widget.chartDataList[3].data.isNotEmpty
                      ? widget.chartDataList[3].data
                      : [],
                  total: totalInterest,
                  sizePieChart: sizePieChart,
                  sectionColors: [
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.deepOrange,
                    Colors.lightGreen,
                    Colors.purpleAccent,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPieChartSection({
    required String title,
    required List<ChartData> dataList,
    required double total,
    required double sizePieChart,
    required List<Color> sectionColors,
  }) {
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
        dataList.isNotEmpty
            ? Center(
                child: SizedBox(
                  height: 380,
                  width: 380,
                  child: PieChart(
                    PieChartData(
                      sections: List.generate(dataList.length, (index) {
                        final data = dataList[index];
                        final percentage = (data.value / total) * 100;
                        return PieChartSectionData(
                          value: data.value.toDouble(),
                          title:
                              '${data.month}\n${percentage.toStringAsFixed(1)}%',
                          color: sectionColors[index % sectionColors.length],
                          radius: sizePieChart,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        );
                      }),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
              )
            : Text(
                'Dữ liệu không có',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 68, 68),
                ),
              ),
        const SizedBox(height: 30),
      ],
    );
  }
}
