// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:ui';
import 'package:animate_gradient/animate_gradient.dart';
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

class _CartState extends State<Cart> {
  final double tiencong = 10000;
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDiscountCoupon = TextEditingController();
  String? _selectedTable = '';
  late List<TableStatus> _tableNumbers = []; // Customize as needed
  late final List<String> _coupons = []; // Customize as needed
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

  Widget _buildSummaryRow(String title, String value,
      {Color? valueColor, bool isTotal = false, required bool isDark}) {
    final textStyle = TextStyle(
      fontSize: isTotal ? 18 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
    );
    final valueTextStyle = TextStyle(
      fontSize: isTotal ? 18 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: valueColor ??
          (isDark ? AppColors.textMainDark : AppColors.textMainLight),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textStyle),
        Text(value, style: valueTextStyle),
      ],
    );
  }

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimateGradient(
          primaryBegin: Alignment.topLeft,
          primaryEnd: Alignment.bottomRight,
          secondaryBegin: Alignment.bottomRight,
          secondaryEnd: Alignment.topLeft,
          duration: const Duration(seconds: 6),
          primaryColors: widget.isDark
              ? ColorSetupBackground.primaryColorsDark
              : ColorSetupBackground.primaryColorsLight,
          secondaryColors: widget.isDark
              ? ColorSetupBackground.secondaryColorsDark
              : ColorSetupBackground.secondaryColorsLight,
          child: AppBar(
            backgroundColor: Colors.transparent,

            elevation: 0, // Removed shadow for a flatter look
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: true,
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
              icon: Icon(Icons.arrow_back,
                  color: widget.isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight),
            ),

            title: Text(
              "Giỏ hàng",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topLeft,
        duration: const Duration(seconds: 6),
        primaryColors: widget.isDark
            ? ColorSetupBackground.primaryColorsDark
            : ColorSetupBackground.primaryColorsLight,
        secondaryColors: widget.isDark
            ? ColorSetupBackground.secondaryColorsDark
            : ColorSetupBackground.secondaryColorsLight,
        child: FutureBuilder<void>(
          future: LoadData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Cart items
                        GlobalData.cartItemList.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(24),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? AppColors.cardDark.withOpacity(0.5)
                                      : AppColors.cardLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 60,
                                        color: widget.isDark
                                            ? AppColors.textSubDark
                                            : AppColors.textSubLight,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Không có gì trong giỏ hàng. Quay lại chọn sản phẩm đi",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isDark
                                              ? AppColors.textMainDark
                                              : AppColors.textMainLight,
                                        ),
                                      ),
                                    ],
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
                                    key: ValueKey(item),
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          onPressed: (_) {
                                            setState(() {
                                              GlobalData.cartItemList.remove(item);
                                            });
                                          },
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
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
                                          if (item.amount < max)
                                            item.amount++;
                                        });
                                      },
                                      onDecrement: () {
                                        setState(() {
                                          if (item.amount > 1) item.amount--;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),

                        const SizedBox(height: 24),

                        // Delivery Info
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: widget.isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Thông tin đặt hàng",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDark
                                          ? AppColors.textMainDark
                                          : AppColors.textMainLight),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _controllerPhone,
                                  decoration: InputDecoration(
                                    labelText: "Số điện thoại",
                                    hintText: "Nhập số điện thoại",
                                    prefixIcon: Icon(Icons.phone,
                                        color: AppColors.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _controllerName,
                                  decoration: InputDecoration(
                                    labelText: "Họ và tên",
                                    hintText: "Nhập họ và tên",
                                    prefixIcon: Icon(Icons.person,
                                        color: AppColors.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedTable,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedTable = newValue!;
                                    });
                                  },
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: '',
                                      child: Text(
                                        "--Chọn bàn--",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ..._tableNumbers.map((TableStatus value) {
                                      return DropdownMenuItem<String>(
                                        value: value.nameTable,
                                        child: Text(value.nameTable),
                                      );
                                    }),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Bàn",
                                    prefixIcon: Icon(Icons.table_bar_rounded,
                                        color: AppColors.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Discount Coupon
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: widget.isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _controllerDiscountCoupon,
                              decoration: InputDecoration(
                                labelText: "Phiếu giảm giá",
                                hintText: "Nhập mã giảm giá",
                                prefixIcon: Icon(Icons.card_giftcard,
                                    color: AppColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (GlobalData
                                              .cartItemList.isNotEmpty &&
                                          _controllerDiscountCoupon
                                              .text.isNotEmpty) {
                                        if (_coupons
                                            .where((element) =>
                                                element ==
                                                _controllerDiscountCoupon.text)
                                            .isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Mã giảm giá đã được áp dụng!"),
                                              backgroundColor:
                                                  AppColors.accent,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Mã giảm giá này không tồn tại!"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          _controllerDiscountCoupon.text = '';
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Vui lòng nhập mã giảm giá hợp lệ"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        _controllerDiscountCoupon.text = '';
                                      }
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  child: Text(
                                    'Áp dụng',
                                    style: TextStyle(color: AppColors.textMainDark),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        //Subtotal, delivery charge, discount and total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                'Tạm tính:',
                                '${format.format(subTotal)} đ',
                                isDark: widget.isDark,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Phí vận chuyển:',
                                '${format.format(deliveryCharge)} đ',
                                isDark: widget.isDark,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Giảm giá:',
                                '${format.format(discount)} đ',
                                valueColor: AppColors.accent,
                                isDark: widget.isDark,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Tiền công:',
                                '${format.format(tiencong)} đ',
                                valueColor: AppColors.accent,
                                isDark: widget.isDark,
                              ),
                              const SizedBox(height: 12),
                              DashedDivider(
                                width: double.infinity,
                                dashWidth: 6,
                                dashSpace: 4,
                                thickness: 1,
                                color: widget.isDark
                                    ? AppColors.textSubDark
                                    : AppColors.textSubLight,
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                'Tổng cộng:',
                                '${format.format(total)} đ',
                                isTotal: true,
                                isDark: widget.isDark,
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
            );
          },
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  if (_tableNumbers.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Hết bàn')));
                    return;
                  }

                  if (GlobalData.cartItemList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chưa có sản phẩm nào trong giỏ hàng'),
                      ),
                    );
                    return;
                  }

                  if (_controllerName.text.isEmpty ||
                      _controllerPhone.text.isEmpty ||
                      _selectedTable!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Còn thiếu thông tin')),
                    );
                    return;
                  }

                  OrderItem orderItem = OrderItem(
                    id: generateCustomId(),
                    timeOrder: getCurrentFormattedDateTime(),
                    cartItems: GlobalData.cartItemList,
                    statusOrder: StatusOrder.Waiting,
                    createDate: DateFormat(
                      'dd/MM/yyyy – HH:mm:ss',
                    ).format(DateTime.now()),
                    email: GlobalData.userDetail.email,
                    table: _tableNumbers
                        .firstWhere(
                          (element) => element.nameTable == _selectedTable,
                        )
                        .nameTable,
                    phone: _controllerPhone.text,
                    name: _controllerName.text,
                    total: total.toString(),
                    coupon: _controllerDiscountCoupon.text,
                  );

                  Buy(
                    orderItem,
                    _tableNumbers
                        .firstWhere(
                          (element) => element.nameTable == _selectedTable,
                        )
                        .id,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đặt nước uống thành công\nVui lòng chờ đợi ở bàn đã chọn và chuyển khoản qua $bankName để tiến hành xử lý đơn hàng',
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Thanh toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


