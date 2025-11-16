import 'package:coffeeapp/CustomCard/analystchart.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/chartdata.dart';
import 'package:coffeeapp/Entity/namedchartdatalist.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnalystPage extends StatefulWidget {
  const AnalystPage({super.key});

  @override
  State<AnalystPage> createState() => _AnalystPageState();
}

class _AnalystPageState extends State<AnalystPage> {
  late List<NamedChartData> chartDataList = [];
  final int tax = 700000;
  final int tiencong = 10000;
  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    List<ChartData> revenue = [];
    List<ChartData> productSold = [];
    List<ChartData> orderDelivered = [];
    List<ChartData> interest = [];

    List<OrderItem> orderItems = await FirebaseDBManager.orderService
        .getAllOrders();
    Map<String, List<CartItem>> cartItemsList = {};
    for (OrderItem orderItem in orderItems) {
      cartItemsList[orderItem.id] = await FirebaseDBManager.cartService
          .getCartItemsByOrder(orderItem.id);
    }
    for (
      int year = DateTime.now().year - 2;
      year < DateTime.now().year + 1;
      year++
    ) {
      for (int month = 1; month < 13; month++) {
        int total = 0;
        int totalOrder = 0;
        int saveMoney = 0;
        List<String> nameProductsSold = [];
        for (OrderItem orderItem in orderItems.where(
          (element) =>
              element.timeOrder.split(' - ')[0].trim().split('/')[1].trim() ==
                  (month < 10 ? "0${month.toString()}" : month.toString()) &&
              element.timeOrder.split(' - ')[0].trim().split('/')[2].trim() ==
                  (year < 10 ? "0${year.toString()}" : year.toString()),
        )) {
          total += int.parse(orderItem.total);
          List<CartItem>? cartItems = cartItemsList[orderItem.id];
          for (CartItem item in cartItems!) {
            if (!nameProductsSold.contains(item.productName)) {
              nameProductsSold.add(item.productName);
            }
          }
          saveMoney += cartItems.length * tiencong;
          totalOrder++;
        }

        revenue.add(ChartData(total, month.toString(), year.toString()));
        productSold.add(
          ChartData(nameProductsSold.length, month.toString(), year.toString()),
        );
        orderDelivered.add(
          ChartData(totalOrder, month.toString(), year.toString()),
        );
        interest.add(ChartData(saveMoney, month.toString(), year.toString()));
      }
    }

    chartDataList = [
      NamedChartData('Doanh thu', revenue),
      NamedChartData('Sản phẩm đã bán', productSold),
      NamedChartData('Đơn hàng đã giao', orderDelivered),
      NamedChartData('Lợi nhuận', interest),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: LoadData(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset(
              'assets/background/loading.json', // Thay bằng đường dẫn đúng tới file Lottie của bạn
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          );
        } else if (asyncSnapshot.hasError) {
          return Center(child: Text('Lỗi: ${asyncSnapshot.error}'));
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnalystChart(chartDataList: chartDataList),
          );
        }
      },
    );
  }
}
