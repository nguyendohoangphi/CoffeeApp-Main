import 'dart:ui';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/models/orderitem.dart';
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
  Color get cardColor => widget.isDark ? AppColors.cardDark : Colors.white;
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
      return dateB.compareTo(dateA);
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
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(
                   color: AppColors.getShadow(widget.isDark).color, 
                   blurRadius: 10, 
                   offset: const Offset(0, 4)
                 )
              ]
            ),
            child: Icon(Icons.arrow_back, color: textColor, size: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            // Push replacement to ensure proper state in nav bar if needed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuNavigationBar(
                  isDark: widget.isDark,
                  selectedIndex: widget.index,
                ),
              ),
            );
          },
        ),
        title: Text(
          "Lịch sử đơn hàng", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)
        ),
      ),
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (context, asyncSnapshot) {
          final format = NumberFormat("#,###", "vi_VN");
          
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          if (orderItemList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     padding: const EdgeInsets.all(30),
                     decoration: BoxDecoration(
                       color: AppColors.primary.withOpacity(0.1),
                       shape: BoxShape.circle
                     ),
                     child: Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.primary.withOpacity(0.5)),
                   ),
                  const SizedBox(height: 24),
                  Text(
                    "Chưa có đơn hàng nào", 
                    style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hãy thưởng thức ly cà phê đầu tiên nhé!", 
                    style: TextStyle(color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight, fontSize: 16)
                  ),
                ],
              ),
            );
          }

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: orderItemList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                OrderItem orderItem = orderItemList[index];
                
                // Get items specifically for this order
                var itemsFromDB = cartItemList.where((element) => element.idOrder == orderItem.id).toList();
                if (itemsFromDB.isNotEmpty) {
                  orderItem.cartItems = itemsFromDB;
                }
                
                Color statusColor = AppColors.primary;
                String statusText = orderItem.statusOrder.toString().split('.').last;
                if (statusText == 'Waiting') {
                  statusText = 'Đang chờ';
                  statusColor = Colors.orange;
                } else if (statusText == 'Confirmed') {
                   statusText = 'Đã xác nhận';
                   statusColor = Colors.blue;
                } else if (statusText == 'Done') {
                   statusText = 'Hoàn thành';
                   statusColor = Colors.green;
                } else if (statusText == 'Cancelled') {
                   statusText = 'Đã hủy';
                   statusColor = Colors.red;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getShadow(widget.isDark).color,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderItem.createDate.split('–')[0].trim(), // Only Date
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                                ),
                                Text(
                                   orderItem.createDate.split('–')[1].trim(), // Only Time
                                   style: TextStyle(color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight, fontSize: 13),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withOpacity(0.3))
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(color: widget.isDark ? Colors.grey[800] : Colors.grey[100], height: 1),

                      // Products
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: orderItem.cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final item = orderItem.cartItems[i];
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: item.product.imageUrl.startsWith('http')
                                    ? Image.network(
                                        item.product.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 64, height: 64),
                                      )
                                    : Image.asset(
                                        item.product.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 64, height: 64),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${_getSizeString(item.size)}  •  x${item.amount}",
                                      style: TextStyle(color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${format.format(item.product.price * item.amount)} đ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15),
                              ),
                            ],
                          );
                        }
                      ),

                      Divider(color: widget.isDark ? Colors.grey[800] : Colors.grey[100], height: 1),

                      // Total
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: widget.isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tổng tiền", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
                            Text(
                              "${format.format(double.tryParse(orderItem.total) ?? 0)} đ",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
                            ),
                          ],
                        ),
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

