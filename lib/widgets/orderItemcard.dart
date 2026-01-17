// ignore_for_file: non_constant_identifier_names

import 'dart:ui';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/productfavourite.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/models/orderitem.dart';
import 'package:coffeeapp/screens/Order/historyorder.dart';
import 'package:intl/intl.dart';

class OrderItemCard extends StatefulWidget {
  final OrderItem orderItem;
  final bool isDark;
  final int index;
  const OrderItemCard({
    super.key,
    required this.orderItem,
    required this.isDark,
    required this.index,
  });

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  var format = NumberFormat("#,###", "vi_VN");
  int subtotalAmount = 0;
  double totalPrice = 0;
  String nameOrderStatus = '';
  late List<ProductFavourite> productFavouriteList = [];

  // Optimization: caching future
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
  }

  Future<void> LoadData() async {
    subtotalAmount = 0;
    totalPrice = 0;
    
    // Create a list of futures to load products in parallel
    List<Future<void>> productFutures = [];

    for (CartItem item in widget.orderItem.cartItems) {
      productFutures.add(
        FirebaseDBManager.productService.getProductByName(item.productName).then((productInfo) {
           item.product = productInfo;
           // We need to be careful with concurrent modification of simple variables, 
           // but given the loop structure it's okay-ish, or better calculate after.
           // However, to be safe and simple, let's keep it sequential or simple aggregation.
           // For now, let's stick to the existing logic but inside the loop
        })
      );
    }
    
    await Future.wait(productFutures);

    // Calculate totals after data is loaded to avoid race conditions
    for (CartItem item in widget.orderItem.cartItems) {
       subtotalAmount += item.amount;
       totalPrice += item.amount * item.product.price;
    }

    productFavouriteList = await FirebaseDBManager.favouriteService
        .getFavouritesByEmail(GlobalData.userDetail.email);
  }

  Future<void> AddOrRemove(Product productTarget) async {
    if (productFavouriteList
        .where((element) => element.productName == productTarget.name)
        .isEmpty) {
      await FirebaseDBManager.favouriteService.addFavourite(
        ProductFavourite(
          email: GlobalData.userDetail.email,
          productName: productTarget.name,
        ),
      );
    } else {
      await FirebaseDBManager.favouriteService.removeFavourite(
        GlobalData.userDetail.email,
        productTarget.name,
      );
    }
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 20)),
      );
    } else {
      return Image.asset(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 20)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.orderItem.statusOrder) {
      case StatusOrder.Waiting:
        nameOrderStatus = 'Hàng chờ';
        break;
      case StatusOrder.Processing:
        nameOrderStatus = 'Đang làm';
        break;
      case StatusOrder.Shipping:
        nameOrderStatus = 'Đang giao';
        break;
      case StatusOrder.Finished:
        nameOrderStatus = 'Đã xong';
        break;
    }

    final cardColor = widget.isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subTextColor = widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
           return Container(
             height: 150,
             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
             ),
             child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
           );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [ AppColors.getShadow(widget.isDark) ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top: Cart Items Preview
                SizedBox(
                  height: 90,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.orderItem.cartItems.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        CartItem cartItem = widget.orderItem.cartItems[index];
                        return Container(
                          width: 240,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.isDark ? Colors.black.withOpacity(0.2) : Colors.grey[50], // Soft background
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: widget.isDark ? Colors.white12 : Colors.black12)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildProductImage(cartItem.product.imageUrl),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cartItem.product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${format.format(cartItem.product.price)} đ',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                      ),
                                    ),
                                     Text(
                                      'x${cartItem.amount}', 
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                             
                              GestureDetector(
                                onTap: () async {
                                  // Optimistic UI update could be better, but sticking to logic
                                  await AddOrRemove(cartItem.product);
                                  setState(() {
                                    _loadDataFuture = LoadData(); // Reload to check fav status
                                  });
                                  // Refresh logic is a bit weird in original code (popping/pushing), 
                                  // keeping it local setState for now is smoother unless navigation needed.
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: widget.isDark ? AppColors.backgroundDark : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                                    ]
                                  ),
                                  child: Icon(
                                    productFavouriteList
                                            .any((e) => e.productName == cartItem.product.name)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: productFavouriteList
                                            .any((e) => e.productName == cartItem.product.name)
                                        ? Colors.redAccent
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: widget.isDark ? Colors.grey[800] : Colors.grey[200], thickness: 1),
                const SizedBox(height: 12),

                /// Middle section: Order Details
                buildOrderDetailRow('Mã đơn:', widget.orderItem.id, textColor, subTextColor, isBoldValue: true),
                buildOrderDetailRow('Số lượng:', '$subtotalAmount món', textColor, subTextColor),
                buildOrderDetailRow('Trạng thái:', nameOrderStatus, textColor, AppColors.info, isStatus: true), // Info color for status
                const SizedBox(height: 8),
                buildOrderDetailRow(
                  'Tổng tiền:',
                  '${format.format(totalPrice)} đ',
                  textColor,
                  AppColors.primary, // Primary color for total
                  isTotal: true
                ),

                const SizedBox(height: 16),

                /// Bottom Buttons: only for Finished orders
                if (widget.orderItem.statusOrder == StatusOrder.Finished)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.star_outline_rounded, size: 20),
                          label: const Text('Đánh giá'), // Vietnamese
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12)
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                          label: const Text('Đặt lại', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             padding: const EdgeInsets.symmetric(vertical: 12),
                             elevation: 0
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOrderDetailRow(String title, String value, Color textColor, Color valueColor, {bool isTotal = false, bool isBoldValue = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(
            color: textColor.withOpacity(0.7), 
            fontWeight: FontWeight.w500,
            fontSize: 14
          )),
          isStatus ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ) :
          Text(value, style: TextStyle(
            color: valueColor, 
            fontWeight: isTotal || isBoldValue ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14
          )),
        ],
      ),
    );
  }
}
