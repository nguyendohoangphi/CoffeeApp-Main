// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:ui';
import 'package:coffeeapp/widgets/colorsetupbackground.dart';
import 'package:coffeeapp/utils/generateCouponCode.dart';
import 'package:coffeeapp/models/coupon.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/widgets/dasheddivider.dart';
import 'package:coffeeapp/utils/generateCustomId.dart';
import 'package:coffeeapp/utils/getCurrentFormattedDateTime.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/models/orderitem.dart';
import 'package:coffeeapp/models/tablestatus.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coffeeapp/screens/cart/widgets/cart_item_card.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  final bool isDark;
  final int index;
  const Cart({required this.isDark, super.key, required this.index});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  final double tiencong = 10000;
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDiscountCoupon = TextEditingController();
  String? _selectedTable = '';
  late List<TableStatus> _tableNumbers = []; 
  late final List<String> _coupons = [];
  
  // Optimization: Cache Future
  late Future<void> _dataLoadingFuture;

  late int currentRankIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controllerPhone.dispose();
    _controllerName.dispose();
    _controllerDiscountCoupon.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> Buy(OrderItem orderItem, String id) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      await FirebaseDBManager.orderService.createOrder(orderItem);

      String currentRank = GlobalData.userDetail.rank;

      for (CartItem cartItem in GlobalData.cartItemList) {
        cartItem.idOrder = orderItem.id;
        await FirebaseDBManager.cartService.addCartItem(cartItem);
        GlobalData.userDetail.point += cartItem.amount;
      }

      await FirebaseDBManager.tableStatusService.updateBookingStatus(id, true);

      // Rank Logic
      switch (GlobalData.userDetail.rank) {
        case 'Hạng đồng': currentRankIndex = 0; break;
        case 'Hạng bạc': currentRankIndex = 1; break;
        case 'Hạng vàng': currentRankIndex = 2; break;
        case 'Hạng kim cương xanh': currentRankIndex = 3; break;
        case 'Hạng kim cương tím': currentRankIndex = 4; break;
        case 'Hạng kim cương đỏ': currentRankIndex = 5; break;
        default: currentRankIndex = 6; break;
      }

      // Upgrade Logic - Simplified
      int points = GlobalData.userDetail.point;
      String newRank = GlobalData.userDetail.rank;

      if (currentRankIndex <= 1 && points >= 200 && points < 300) newRank = 'Hạng bạc';
      else if (currentRankIndex <= 2 && points >= 300 && points < 400) newRank = 'Hạng vàng';
      else if (currentRankIndex <= 3 && points >= 400 && points < 500) newRank = 'Hạng kim cương xanh';
      else if (currentRankIndex <= 4 && points >= 500 && points < 600) newRank = 'Hạng kim cương tím';
      else if (currentRankIndex <= 5 && points >= 600) newRank = 'Hạng kim cương đỏ';
      
      GlobalData.userDetail.rank = newRank;

      // Point deduction for rank upgrade
      if (currentRank != GlobalData.userDetail.rank) {
         if (currentRank == 'Hạng đồng') GlobalData.userDetail.point -= 200;
         else if (currentRank == 'Hạng bạc') GlobalData.userDetail.point -= 300;
         else if (currentRank == 'Hạng vàng') GlobalData.userDetail.point -= 400;
         else if (currentRank == 'Hạng kim cương xanh') GlobalData.userDetail.point -= 500;
         else if (currentRank == 'Hạng kim cương tím') GlobalData.userDetail.point -= 600;

        await FirebaseDBManager.couponService.addSingleCouponCode(
          GlobalData.userDetail.email,
          generateCouponCode(),
        );
      }

      await FirebaseDBManager.authService.updateUserPointAndRank(
        GlobalData.userDetail.email,
        GlobalData.userDetail.point,
        GlobalData.userDetail.rank,
      );
      
      if (_controllerDiscountCoupon.text.isNotEmpty) {
        await FirebaseDBManager.couponService.deleteCouponCode(
          GlobalData.userDetail.email,
          _controllerDiscountCoupon.text,
        );
      }

      GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;

      Navigator.pop(context); // Hide loading

      setState(() {
        GlobalData.cartItemList.clear();
        _controllerPhone.text = '';
        _controllerName.text = '';
        _controllerDiscountCoupon.text = '';
        _selectedTable = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đặt nước uống thành công\nVui lòng chờ đợi ở bàn đã chọn và chuyển khoản qua $bankName để tiến hành xử lý đơn hàng',
          ),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {
      Navigator.pop(context); // Hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _loadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;
    Coupon coupon = await FirebaseDBManager.couponService.getCoupon(
      GlobalData.userDetail.email,
    );
    _coupons.clear();
    for (String code in coupon.codes) {
      _coupons.add(code);
    }
    _tableNumbers = await FirebaseDBManager.tableStatusService
        .getTablesByBookingStatus(false);
  }
  
  String GetSizeString(SizeOption size) {
    switch (size) {
      case SizeOption.Small: return "Nhỏ";
      case SizeOption.Medium: return "Vừa";
      case SizeOption.Large: return "Lớn";
    }
  }

  final f = DateFormat('yyyy-MM-dd hh:mm');
  int max = 10;
  String bankName = 'Vietcombank';
  int min = 0;

  Widget _buildSummaryRow(String title, String value,
      {Color? valueColor, bool isTotal = false, required bool isDark}) {
    final textStyle = TextStyle(
      fontSize: isTotal ? 18 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
    );
    final valueTextStyle = TextStyle(
      fontSize: isTotal ? 20 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
      color: valueColor ?? (isDark ? AppColors.textMainDark : AppColors.textMainLight),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textStyle),
          Text(value, style: valueTextStyle),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
      hintText: "Nhập $label",
      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      filled: true,
      fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    var format = NumberFormat("#,###", "vi_VN");

    double subTotal = 0;
    double deliveryCharge = 0;
    double discount = 0;
    double total = 0;

    if (GlobalData.cartItemList.isNotEmpty) {
      for (CartItem cartItem in GlobalData.cartItemList) {
        subTotal += cartItem.product.price * cartItem.amount;
      }
      if (_controllerDiscountCoupon.text.isNotEmpty) {
        discount = subTotal * 0.1;
      }
      total = (subTotal + deliveryCharge + tiencong) - discount;
    }

    return Scaffold(
      backgroundColor: widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: FutureBuilder<void>(
        future: _dataLoadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
           // Handle errors if needed, but for now fallback to UI to prevent crash
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. App Bar
              SliverAppBar(
                backgroundColor: widget.isDark ? AppColors.backgroundDark.withOpacity(0.9) : AppColors.backgroundLight.withOpacity(0.9),
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                   onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuNavigationBar(
                          isDark: widget.isDark,
                          selectedIndex: widget.index,
                        ),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isDark ? AppColors.cardDark : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [ AppColors.getShadow(widget.isDark) ]
                    ),
                    child: Icon(Icons.arrow_back, color: widget.isDark ? AppColors.textMainDark : AppColors.textMainLight, size: 20),
                  ),
                ),
                title: Text(
                  "Giỏ hàng của bạn",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? AppColors.textMainDark : AppColors.textMainLight
                  ),
                ),
              ),

              // 2. Cart Items
              GlobalData.cartItemList.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppColors.cardDark : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [AppColors.getShadow(widget.isDark)]
                          ),
                          child: Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Giỏ hàng trống trơn!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? AppColors.textMainDark : AppColors.textMainLight,
                          ),
                        ),
                         const SizedBox(height: 12),
                          Text(
                            "Hãy thêm vài món đồ uống ngon lành nào.",
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = GlobalData.cartItemList[index];
                      // Animation Wrapper
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final double slide = 50.0 * (1.0 - _animationController.value);
                          final double fade = _animationController.value;
                          return Opacity(
                            opacity: fade,
                            child: Transform.translate(
                              offset: Offset(0, slide),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Slidable(
                            key: ValueKey(item),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    setState(() {
                                      GlobalData.cartItemList.remove(item);
                                    });
                                  },
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_outline,
                                  label: 'Xóa',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),
                            child: CartItemCard(
                              item: item,
                              format: format,
                              isDark: widget.isDark,
                              getSizeString: GetSizeString,
                              onIncrement: () {
                                setState(() {
                                  if (item.amount < max) item.amount++;
                                });
                              },
                              onDecrement: () {
                                setState(() {
                                  if (item.amount > 1) item.amount--;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: GlobalData.cartItemList.length,
                  ),
                ),

              // 3. Info Section (Only if not empty)
              if (GlobalData.cartItemList.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                         Text("THÔNG TIN ĐẶT HÀNG", style: TextStyle(
                            color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          )),
                          const SizedBox(height: 16),
                          
                          // Form Container
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [AppColors.getShadow(widget.isDark)],
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _controllerPhone,
                                  style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                                  decoration: _buildInputDecoration("Số điện thoại", Icons.phone_rounded, widget.isDark),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _controllerName,
                                  style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                                  decoration: _buildInputDecoration("Họ và tên", Icons.person_rounded, widget.isDark),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedTable!.isEmpty ? null : _selectedTable,
                                  dropdownColor: widget.isDark ? AppColors.cardDark : Colors.white,
                                  style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedTable = newValue!;
                                    });
                                  },
                                  items: _tableNumbers.map((TableStatus value) {
                                    return DropdownMenuItem<String>(
                                      value: value.nameTable,
                                      child: Text(value.nameTable),
                                    );
                                  }).toList(),
                                  decoration: _buildInputDecoration("Bàn", Icons.table_bar_rounded, widget.isDark),
                                  hint: Text("-- Chọn bàn --", style: TextStyle(color: widget.isDark ? Colors.grey[400] : Colors.grey[600])),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Coupon
                          Container(
                            decoration: BoxDecoration(
                              color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: TextField(
                              controller: _controllerDiscountCoupon,
                              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: "Mã giảm giá",
                                labelStyle: TextStyle(color: widget.isDark ? Colors.grey[400] : Colors.grey[600]),
                                hintText: "Nhập mã...",
                                iconColor: AppColors.primary,
                                prefixIcon: const Icon(Icons.card_giftcard, color: AppColors.primary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(6),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (GlobalData.cartItemList.isEmpty) return;
                                      setState(() {
                                         if (_coupons.contains(_controllerDiscountCoupon.text)) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: const Text("Mã giảm giá đã được áp dụng!"), 
                                              backgroundColor: AppColors.success
                                            ));
                                         } else {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text("Mã giảm giá không hợp lệ!"), 
                                              backgroundColor: AppColors.error
                                            ));
                                            _controllerDiscountCoupon.text = '';
                                         }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                    ),
                                    child: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Summary
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [ AppColors.getShadow(widget.isDark) ],
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Tạm tính:', '${format.format(subTotal)} đ', isDark: widget.isDark),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Phí vận chuyển:', '${format.format(deliveryCharge)} đ', isDark: widget.isDark),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Giảm giá:', '-${format.format(discount)} đ', valueColor: AppColors.success, isDark: widget.isDark),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Tiền công:', '${format.format(tiencong)} đ', valueColor: AppColors.info, isDark: widget.isDark),
                                const SizedBox(height: 20),
                                DashedDivider(
                                  width: double.infinity,
                                  dashWidth: 6,
                                  dashSpace: 4,
                                  thickness: 1,
                                  color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight,
                                ),
                                const SizedBox(height: 20),
                                _buildSummaryRow('Tổng cộng:', '${format.format(total)} đ', isTotal: true, isDark: widget.isDark),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100), // Spacing for BottomBar
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      
      // Bottom Bar
      bottomNavigationBar: GlobalData.cartItemList.isNotEmpty ? Container(
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
           color: widget.isDark ? AppColors.cardDark : Colors.white,
           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               blurRadius: 20,
               offset: const Offset(0, -5),
             )
           ],
         ),
         child: SafeArea(
           child: SizedBox(
             width: double.infinity,
             height: 56,
             child: ElevatedButton(
               onPressed: () {
                 if (_tableNumbers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hết bàn'), backgroundColor: AppColors.error));
                    return;
                  }
                  if (_controllerName.text.isEmpty || _controllerPhone.text.isEmpty || (_selectedTable == null || _selectedTable!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin'), backgroundColor: AppColors.error));
                    return;
                  }

                 OrderItem orderItem = OrderItem(
                      id: generateCustomId(),
                      timeOrder: getCurrentFormattedDateTime(),
                      cartItems: GlobalData.cartItemList,
                      statusOrder: StatusOrder.Waiting,
                      createDate: DateFormat('dd/MM/yyyy – HH:mm:ss').format(DateTime.now()),
                      email: GlobalData.userDetail.email,
                      table: _tableNumbers.firstWhere((e) => e.nameTable == _selectedTable).nameTable,
                      phone: _controllerPhone.text,
                      name: _controllerName.text,
                      total: total.toString(),
                      coupon: _controllerDiscountCoupon.text,
                  );
                 
                  Buy(orderItem, _tableNumbers.firstWhere((e) => e.nameTable == _selectedTable).id);
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primary,
                 elevation: 8,
                 shadowColor: AppColors.primary.withOpacity(0.5),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               ),
               child: const Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.payment, color: Colors.white),
                   SizedBox(width: 12),
                   Text("THANH TOÁN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                 ],
               ),
             ),
           ),
         ),
      ) : null,
    );
  }
}
