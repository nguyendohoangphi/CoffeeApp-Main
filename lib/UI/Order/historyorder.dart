import 'dart:ui';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/constants/app_colors.dart'; // Import màu
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/orderItemcard.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';

class HistoryOrder extends StatefulWidget {
  final bool isDark;
  final int index;
  const HistoryOrder({super.key, required this.isDark, required this.index});

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder> {
  late List<OrderItem> orderItemList = [];
  late List<CartItem> cartItemList = [];

  // Theme Helpers
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;

  Future<void> LoadData() async {
    orderItemList = await FirebaseDBManager.orderService.getOrdersByEmail(GlobalData.userDetail.email);
    for (OrderItem orderItem in orderItemList) {
      cartItemList.addAll(await FirebaseDBManager.cartService.getCartItemsByOrder(orderItem.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () {
            Navigator.pop(context);
            // Có thể bạn không cần push lại MenuNavigationBar nếu chỉ muốn back
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuNavigationBar(
                      isDark: widget.isDark,
                      selectedIndex: widget.index,
                    ),
                  ),
                );          },
        ),
        title: Text("Lịch sử đơn hàng", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
      ),
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (orderItemList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orderItemList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                OrderItem orderItem = orderItemList[index];
                orderItem.cartItems = cartItemList.where((element) => element.idOrder == orderItem.id).toList();
                
                // Trả về widget OrderItemCard 
                //  gọi OrderItemCard 
                return OrderItemCard(
                  orderItem: orderItem,
                  isDark: widget.isDark,
                  index: widget.index,
                );
              },
              
            ),
          );
        },
      ),
    );
  }
}