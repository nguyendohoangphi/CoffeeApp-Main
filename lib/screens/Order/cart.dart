// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously, unnecessary_import, deprecated_member_use

import 'dart:ui';
import 'package:coffeeapp/services/payment_service.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/utils/generateCouponCode.dart';
import 'package:coffeeapp/models/coupon.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:flutter/material.dart';
//import 'package:coffeeapp/widgets/dasheddivider.dart';
import 'package:coffeeapp/utils/generateCustomId.dart';
import 'package:coffeeapp/utils/getCurrentFormattedDateTime.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/models/orderitem.dart';
import 'package:coffeeapp/models/tablestatus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  final bool isDark;
  final int index;
  const Cart({required this.isDark, super.key, required this.index});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final double tiencong = 10000;
  final _paymentService = PaymentService();
  bool _isProcessing = false;

  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDiscountCoupon =
      TextEditingController();
  String? _selectedTable = '';
  late List<TableStatus> _tableNumbers = [];
  late final List<String> _coupons = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill user info if available
    _controllerName.text = GlobalData.userDetail.username;
    _controllerPhone.text = GlobalData.userDetail.phone ?? '';
  }

  @override
  void dispose() {
    _controllerPhone.dispose();
    _controllerName.dispose();
    _controllerDiscountCoupon.dispose();
    super.dispose();
  }

  Future<void> _processCheckout(double total) async {
    // 1. Validate inputs
    if (_tableNumbers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Hết bàn')));
      return;
    }
    if (GlobalData.cartItemList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có sản phẩm nào trong giỏ hàng')),
      );
      return;
    }
    if (_controllerName.text.isEmpty ||
        _controllerPhone.text.isEmpty ||
        _selectedTable!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // 2. Create OrderItem object
    final orderItem = OrderItem(
      id: generateCustomId(),
      timeOrder: getCurrentFormattedDateTime(),
      cartItems: GlobalData.cartItemList,
      statusOrder: StatusOrder.Waiting, // Default status
      createDate: DateFormat('dd/MM/yyyy – HH:mm:ss').format(DateTime.now()),
      email: GlobalData.userDetail.email,
      table: _tableNumbers
          .firstWhere((element) => element.nameTable == _selectedTable)
          .nameTable,
      phone: _controllerPhone.text,
      name: _controllerName.text,
      total: total.toString(),
      coupon: _controllerDiscountCoupon.text,
    );

    // 3. Simulate payment processing
    bool paymentSuccess = await _paymentService.processPayment(
      amount: total,
      orderId: orderItem.id,
    );

    // 4. Handle payment result
    if (paymentSuccess) {
      try {
        print("DEBUG: Bắt đầu lưu đơn hàng lên Firebase... ID: ${orderItem.id}");
        // 4a. Place order and update revenue in a transaction
        await FirebaseDBManager.orderService
            .placeOrderAndUpdateRevenue(order: orderItem);
        
        // --- FIX: Lưu chi tiết từng món hàng để HistoryOrder có thể tìm thấy ---
        for (CartItem cartItem in GlobalData.cartItemList) {
          cartItem.idOrder = orderItem.id;
          await FirebaseDBManager.cartService.addCartItem(cartItem);
        }
        // ----------------------------------------------------------------------

        // 4b. Update user points and rank (previously in Buy method)
        await _updateUserPointsAndRank();

        // 4c. Clear cart and reset state
        setState(() {
          GlobalData.cartItemList.clear();
          _controllerDiscountCoupon.text = '';
          _selectedTable = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        print("DEBUG: Lưu đơn hàng thành công!");
        Navigator.of(context).pop(); // Go back from cart
      } catch (e) {
        print("DEBUG: LỖI KHI LƯU ĐƠN HÀNG: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
        );
      }
    } else {
      // Payment failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Thanh toán thất bại, vui lòng thử lại.')),
      );
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _updateUserPointsAndRank() async {
    String currentRank = GlobalData.userDetail.rank;
    
    // Calculate points from the recent order
    int pointsFromOrder = 0;
    for (var item in GlobalData.cartItemList) {
      pointsFromOrder += item.amount;
    }
    GlobalData.userDetail.point += pointsFromOrder;
    
    // Check for rank up
    // This logic could be moved to a configuration file or a service
    if (GlobalData.userDetail.point >= 600) {
        GlobalData.userDetail.rank = 'Hạng kim cương đỏ';
    } else if (GlobalData.userDetail.point >= 500) {
        GlobalData.userDetail.rank = 'Hạng kim cương tím';
    } else if (GlobalData.userDetail.point >= 400) {
        GlobalData.userDetail.rank = 'Hạng kim cương xanh';
    } else if (GlobalData.userDetail.point >= 300) {
        GlobalData.userDetail.rank = 'Hạng vàng';
    } else if (GlobalData.userDetail.point >= 200) {
        GlobalData.userDetail.rank = 'Hạng bạc';
    }

    // Grant coupon if rank changed
    if (currentRank != GlobalData.userDetail.rank) {
      await FirebaseDBManager.couponService.addSingleCouponCode(
        GlobalData.userDetail.email,
        generateCouponCode(),
      );
    }
    
    // Update user profile in Firestore
    await FirebaseDBManager.authService.updateUserPointAndRank(
      GlobalData.userDetail.email,
      GlobalData.userDetail.point,
      GlobalData.userDetail.rank,
    );

    // Delete used coupon
    if (_controllerDiscountCoupon.text.isNotEmpty) {
      await FirebaseDBManager.couponService.deleteCouponCode(
        GlobalData.userDetail.email,
        _controllerDiscountCoupon.text,
      );
    }
    
    // Refresh user data locally
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;
  }

  Future<void> _loadData() async {
    // This function now only loads data required for the dropdowns
    if (_tableNumbers.isEmpty) {
        _tableNumbers = await FirebaseDBManager.tableStatusService.getTablesByBookingStatus(false);
    }
    if (_coupons.isEmpty) {
        Coupon coupon = await FirebaseDBManager.couponService.getCoupon(GlobalData.userDetail.email);
        _coupons.addAll(coupon.codes);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    var format = NumberFormat("#,###", "vi_VN");

    late double subTotal = 0;
    if (GlobalData.cartItemList.isNotEmpty) {
      for (CartItem cartItem in GlobalData.cartItemList) {
        subTotal += cartItem.product.price * cartItem.amount;
      }
    }
    late double discount = _controllerDiscountCoupon.text.isNotEmpty && _coupons.contains(_controllerDiscountCoupon.text) ? subTotal * 0.1 : 0;
    late double total = (subTotal + tiencong) - discount;

    final Color textColor =
        widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final Color subTextColor =
        widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;
    final Color cardColor =
        widget.isDark ? AppColors.cardDark : AppColors.cardLight;

    return Scaffold(
      backgroundColor:
          widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Text(
          "Giỏ hàng",
          style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _tableNumbers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi tải dữ liệu bàn và khuyến mãi:\n${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart items list
                GlobalData.cartItemList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Không có gì trong giỏ hàng.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: subTextColor,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: GlobalData.cartItemList.length,
                        itemBuilder: (context, index) {
                          final item = GlobalData.cartItemList[index];
                          return Slidable(
                            key: ValueKey(item.product.name + item.size.toString()),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.33,
                              children: [
                                SlidableAction(
                                  onPressed: (_) async {
                                    final confirmed =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                title: const Text('Xác nhận xóa'),
                                                content: Text('Bạn có chắc chắn muốn xóa "${item.product.name} - ${_getSizeString(item.size)}" khỏi giỏ hàng?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                                                  TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
                                                ],
                                              ),
                                        );

                                    if (confirmed == true) {
                                      setState(() {
                                        GlobalData.cartItemList.remove(item);
                                      });
                                    }
                                  },
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Xóa',
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      item.product.imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                        Text(_getSizeString(item.size), style: TextStyle(fontSize: 14, color: subTextColor)),
                                        Text('${format.format(item.product.price)} đ', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        color: subTextColor,
                                        onPressed: () {
                                          setState(() {
                                            if (item.amount > 1) item.amount--;
                                          });
                                        },
                                      ),
                                      Text('${item.amount}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: AppColors.primary,
                                        onPressed: () {
                                          setState(() {
                                            if (item.amount < 10) item.amount++;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24),
                // User Info Section
                Text("Thông tin người đặt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerName,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Nhập họ và tên",
                    labelText: "Họ và tên",
                    labelStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controllerPhone,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Nhập số điện thoại",
                    labelText: "Số điện thoại",
                    labelStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTable,
                  onChanged: (String? newValue) => setState(() => _selectedTable = newValue!),
                  items: [
                    const DropdownMenuItem<String>(value: '', child: Text("--Chọn bàn--")),
                    ..._tableNumbers.map((TableStatus value) => DropdownMenuItem<String>(value: value.nameTable, child: Text(value.nameTable))),
                  ],
                  decoration: InputDecoration(
                    labelText: "Bàn",
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.table_bar_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                // Coupon and Totals
                Text("Khuyến mãi & Hóa đơn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerDiscountCoupon,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Nhập mã giảm giá",
                    labelText: "Mã giảm giá",
                    labelStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.card_giftcard, color: AppColors.primary),
                    suffixIcon: TextButton(
                      onPressed: () => setState(() {}), // Trigger rebuild to apply coupon
                      child: const Text('Áp dụng', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tạm tính:', style: TextStyle(fontSize: 16, color: subTextColor)), Text('${format.format(subTotal)} đ', style: TextStyle(fontSize: 16, color: textColor))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tiền công:', style: TextStyle(fontSize: 16, color: subTextColor)), Text('${format.format(tiencong)} đ', style: TextStyle(fontSize: 16, color: textColor))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Giảm giá:', style: TextStyle(fontSize: 16, color: subTextColor)), Text('- ${format.format(discount)} đ', style: const TextStyle(fontSize: 16, color: Colors.green))]),
                      const Divider(height: 24),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)), Text('${format.format(total)} đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary))]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: (_isProcessing || GlobalData.cartItemList.isEmpty)
                ? null
                : () => _processCheckout(total),
            icon: _isProcessing
                ? const SizedBox.shrink()
                : const Icon(Icons.shield_outlined),
            label: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Thanh toán an toàn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
