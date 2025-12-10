// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:ui';
import 'package:coffeeapp/CustomCard/dasheddivider.dart';
import 'package:coffeeapp/CustomMethod/generateCouponCode.dart';
import 'package:coffeeapp/CustomMethod/generateCustomId.dart';
import 'package:coffeeapp/CustomMethod/getCurrentFormattedDateTime.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/coupon.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/constants/app_colors.dart'; 
import 'package:flutter/material.dart';
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
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDiscountCoupon = TextEditingController();
  String? _selectedTable = '';
  late List<TableStatus> _tableNumbers = [];
  late final List<String> _coupons = [];

  // Theme Helpers
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get cardColor => widget.isDark ? AppColors.cardDark : Colors.white;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
  Color get subTextColor => widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerPhone.dispose();
    _controllerName.dispose();
    _controllerDiscountCoupon.dispose();
    super.dispose();
  }

  late int currentRankIndex;

  Future<void> Buy(OrderItem orderItem, String id) async {
    await FirebaseDBManager.orderService.createOrder(orderItem);

    String currentRank = GlobalData.userDetail.rank;

    for (CartItem cartItem in GlobalData.cartItemList) {
      cartItem.idOrder = orderItem.id;
      await FirebaseDBManager.cartService.addCartItem(cartItem);
      GlobalData.userDetail.point += cartItem.amount;
    }

    await FirebaseDBManager.tableStatusService.updateBookingStatus(id, true);

    switch (GlobalData.userDetail.rank) {
      case 'Hạng đồng':
        currentRankIndex = 0;
        break;
      case 'Hạng bạc':
        currentRankIndex = 1;
        break;
      case 'Hạng vàng':
        currentRankIndex = 2;
        break;
      case 'Hạng kim cương xanh':
        currentRankIndex = 3;
        break;
      case 'Hạng kim cương tím':
        currentRankIndex = 4;
        break;
      case 'Hạng kim cương đỏ':
        currentRankIndex = 5;
        break;
      default:
        currentRankIndex = 6;
        break;
    }
    if (currentRankIndex == 1 &&
        GlobalData.userDetail.point >= 200 &&
        GlobalData.userDetail.point < 300) {
      GlobalData.userDetail.rank = 'Hạng bạc';
    } else if (currentRankIndex == 2 &&
        GlobalData.userDetail.point >= 300 &&
        GlobalData.userDetail.point < 400) {
      GlobalData.userDetail.rank = 'Hạng vàng';
    } else if (currentRankIndex == 3 &&
        GlobalData.userDetail.point >= 400 &&
        GlobalData.userDetail.point < 500) {
      GlobalData.userDetail.rank = 'Hạng kim cương xanh';
    } else if (currentRankIndex == 4 &&
        GlobalData.userDetail.point >= 500 &&
        GlobalData.userDetail.point < 600) {
      GlobalData.userDetail.rank = 'Hạng kim cương tím';
    } else if (currentRankIndex == 5 && GlobalData.userDetail.point >= 600) {
      GlobalData.userDetail.rank = 'Hạng kim cương đỏ';
    }

    if (currentRank != GlobalData.userDetail.rank) {
      switch (currentRank) {
        case 'Hạng đồng':
          GlobalData.userDetail.point -= 200;
          break;
        case 'Hạng bạc':
          GlobalData.userDetail.point -= 300;
          break;
        case 'Hạng vàng':
          GlobalData.userDetail.point -= 400;
          break;
        case 'Hạng kim cương xanh':
          GlobalData.userDetail.point -= 500;
          break;
        case 'Hạng kim cương tím':
          GlobalData.userDetail.point -= 600;
          break;
      }
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

    setState(() {
      GlobalData.cartItemList.clear();
      _controllerPhone.text = '';
      _controllerName.text = '';
      _controllerDiscountCoupon.text = '';
      _selectedTable = '';
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;

    Coupon coupon = await FirebaseDBManager.couponService.getCoupon(
      GlobalData.userDetail.email,
    );

    for (String code in coupon.codes) {
      _coupons.add(code);
    }

    _tableNumbers = await FirebaseDBManager.tableStatusService
        .getTablesByBookingStatus(false);
  }

  // ignore: non_constant_identifier_names
  String GetSizeString(SizeOption size) {
    switch (size) {
      case SizeOption.Small:
        return "Nhỏ";
      case SizeOption.Medium:
        return "Vừa";
      case SizeOption.Large:
        return "Lớn";
    }
  }

  final f = DateFormat('yyyy-MM-dd hh:mm');
  int max = 10;
  String bankName = 'Vietcombank';
  int min = 0;

  @override
  Widget build(BuildContext context) {
    var format = NumberFormat("#,###", "vi_VN");

    late double subTotal = 0;
    late double deliveryCharge = 0;
    late double discount = 0;
    late double total = 0;
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
        title: Text(
          "Giỏ hàng",
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: textColor
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. LIST CART ITEMS ---
                          if (GlobalData.cartItemList.isEmpty)
                            _buildEmptyCart()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: GlobalData.cartItemList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 15),
                              itemBuilder: (context, index) {
                                final item = GlobalData.cartItemList[index];
                                return _buildCartItem(item, format);
                              },
                            ),

                          const SizedBox(height: 30),

                          // --- 2. CUSTOMER INFO ---
                          Text("Thông tin nhận hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 15),
                          
                          _buildTextField(_controllerName, "Họ và tên", Icons.person_outline),
                          const SizedBox(height: 12),
                          _buildTextField(_controllerPhone, "Số điện thoại", Icons.phone_outlined),
                          const SizedBox(height: 12),
                          
                          // Dropdown Table
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedTable,
                              dropdownColor: cardColor,
                              style: TextStyle(color: textColor),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.table_bar_outlined, color: AppColors.primary),
                                hintText: "Chọn bàn",
                              ),
                              items: [
                                DropdownMenuItem(value: '', child: Text("-- Chọn bàn --", style: TextStyle(color: subTextColor))),
                                ..._tableNumbers.map((TableStatus value) {
                                  return DropdownMenuItem(value: value.nameTable, child: Text(value.nameTable, style: TextStyle(color: textColor)));
                                }),
                              ],
                              onChanged: (val) => setState(() => _selectedTable = val!),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- 3. COUPON ---
                          Text("Ưu đãi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(_controllerDiscountCoupon, "Nhập mã giảm giá", Icons.local_offer_outlined),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (GlobalData.cartItemList.isNotEmpty && _controllerDiscountCoupon.text.isNotEmpty) {
                                      if (_coupons.contains(_controllerDiscountCoupon.text)) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Áp dụng mã thành công!"), backgroundColor: Colors.green));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã không tồn tại!"), backgroundColor: Colors.red));
                                        _controllerDiscountCoupon.text = '';
                                      }
                                    } else {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập mã hợp lệ"), backgroundColor: Colors.orange));
                                       _controllerDiscountCoupon.text = '';
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                ),
                                child: const Text("Áp dụng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // --- 4. BILL DETAILS ---
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow("Tạm tính", "${format.format(subTotal)} đ"),
                                _buildSummaryRow("Phí dịch vụ", "${format.format(tiencong)} đ"),
                                _buildSummaryRow("Giảm giá", "-${format.format(discount)} đ", isDiscount: true),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: DashedDivider(
                                    width: double.infinity,
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Tổng cộng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                    Text("${format.format(total)} đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- 5. BOTTOM CHECKOUT BUTTON ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_tableNumbers.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hết bàn')));
                          return;
                        }
                        if (GlobalData.cartItemList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống')));
                          return;
                        }
                        if (_controllerName.text.isEmpty || _controllerPhone.text.isEmpty || _selectedTable!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đặt hàng thành công!\nVui lòng chuyển khoản qua $bankName.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.payment, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Thanh toán ngay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildEmptyCart() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.remove_shopping_cart_outlined, size: 60, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 15),
          Text(
            "Giỏ hàng đang trống",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: subTextColor),
          ),
          const SizedBox(height: 5),
          Text(
            "Hãy chọn thêm món ngon nhé!",
            style: TextStyle(fontSize: 14, color: subTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, NumberFormat format) {
    return Slidable(
      key: ValueKey(item.product.name),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: cardColor,
                  title: Text("Xóa món?", style: TextStyle(color: textColor)),
                  content: Text("Bạn muốn xóa ${item.product.name}?", style: TextStyle(color: subTextColor)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirmed == true) {
                setState(() => GlobalData.cartItemList.remove(item));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa ${item.product.name}")));
              }
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                item.product.imageUrl, 
                width: 80, height: 80, 
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(color: Colors.grey[200], width: 80, height: 80, child: const Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  const SizedBox(height: 4),
                  Text("Size: ${GetSizeString(item.size)}", style: TextStyle(fontSize: 13, color: subTextColor)),
                  const SizedBox(height: 8),
                  Text("${format.format(item.product.price)} đ", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            Column(
              children: [
                InkWell(
                  onTap: () => setState(() { if(item.amount < max) item.amount++; }),
                  child: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("${item.amount}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                ),
                InkWell(
                  onTap: () => setState(() { if(item.amount > 1) item.amount--; }),
                  child: Icon(Icons.remove_circle_outline, color: subTextColor, size: 28),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.primary),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: subTextColor, fontSize: 15)),
          Text(value, style: TextStyle(color: isDiscount ? Colors.green : textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}