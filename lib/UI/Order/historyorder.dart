import 'dart:ui';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/constants/app_colors.dart'; // Import màu
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:intl/intl.dart';

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

  String _getSizeString(SizeOption size) {
    switch (size) {
      case SizeOption.Small:
        return "Nhỏ";
      case SizeOption.Medium:
        return "Vừa";
      case SizeOption.Large:
        return "Lớn";
    }
  }

  Future<void> LoadData() async {
    orderItemList = await FirebaseDBManager.orderService.getOrdersByEmail(GlobalData.userDetail.email);
    
    // Sắp xếp danh sách: Mới nhất lên đầu
    orderItemList.sort((a, b) {
      DateTime dateA = DateFormat('dd/MM/yyyy – HH:mm:ss').parse(a.createDate);
      DateTime dateB = DateFormat('dd/MM/yyyy – HH:mm:ss').parse(b.createDate);
      return dateB.compareTo(dateA); // Giảm dần (Descending)
    });

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
          final format = NumberFormat("#,###", "vi_VN");
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
                // FIX: Chỉ ghi đè nếu tìm thấy dữ liệu trong cartItemList, tránh làm mất dữ liệu nếu đã có sẵn
                var itemsFromDB = cartItemList.where((element) => element.idOrder == orderItem.id).toList();
                if (itemsFromDB.isNotEmpty) {
                  orderItem.cartItems = itemsFromDB;
                }
                
                // Hiển thị chi tiết đơn hàng (Hình ảnh, Tên, Size, Giá)
                return Container(
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Ngày và Trạng thái
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            orderItem.createDate,
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                          ),
                          Text(
                            orderItem.statusOrder.toString().split('.').last,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Danh sách sản phẩm trong đơn
                      ...orderItem.cartItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // --- HIỂN THỊ HÌNH ẢNH ---
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.product.imageUrl.startsWith('http')
                                    ? Image.network(
                                        item.product.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                                      )
                                    : Image.asset(
                                        item.product.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.local_cafe, color: Colors.grey),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                    ),
                                    Text(
                                      "${_getSizeString(item.size)} x${item.amount}",
                                      style: TextStyle(color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              // --- HIỂN THỊ GIÁ ---
                              Text(
                                "${format.format(item.product.price * item.amount)} đ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      // Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                          Text(
                            "${format.format(double.tryParse(orderItem.total) ?? 0)} đ",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              
            ),
          );
        },
      ),
    );
  }
}