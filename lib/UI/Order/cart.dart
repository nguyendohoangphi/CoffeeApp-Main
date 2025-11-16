// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:ui';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/CustomMethod/generateCouponCode.dart';
import 'package:coffeeapp/Entity/coupon.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/dasheddivider.dart';
import 'package:coffeeapp/CustomMethod/generateCustomId.dart';
import 'package:coffeeapp/CustomMethod/getCurrentFormattedDateTime.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
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
  final TextEditingController _controllerDiscountCoupon =
      TextEditingController();
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

    GlobalData.userDetail = (await FirebaseDBManager.authService.getUserDetail(
      GlobalData.userDetail.email,
    ))!;

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
    GlobalData.userDetail = (await FirebaseDBManager.authService.getUserDetail(
      GlobalData.userDetail.email,
    ))!;

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
    final double detailsWidth = 200; // Adjust width to fit your layout
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

            elevation: 4.0,
            // ignore: deprecated_member_use
            shadowColor: Colors.black.withOpacity(0.3),
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
              icon: Icon(Icons.arrow_back, color: Colors.white70),
            ),

            title: Expanded(
              child: Center(
                child: Text(
                  "Giỏ hàng",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Cart items
                        SizedBox(
                          height: 300,
                          child: GlobalData.cartItemList.isEmpty
                              ? Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      0xFFFFF3E0,
                                    ), // light coffee/beige tone
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Không có gì trong giỏ hàng. Quay lại chọn sản phẩm đi",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: GlobalData.cartItemList.length,
                                  itemBuilder: (context, index) {
                                    final item = GlobalData.cartItemList[index];

                                    return Slidable(
                                      key: ValueKey(item.product.name),
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio:
                                            0.33, // 👈 Only swipe 1/3 of width
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) async {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          title: const Text(
                                                            'Xác nhận xóa',
                                                          ),
                                                          content: Text(
                                                            'Bạn có chắc chắn muốn xóa "${item.product.name} - ${GetSizeString(item.size)}" khỏi giỏ hàng?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false),
                                                              child: const Text(
                                                                'Hủy',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                              child: const Text(
                                                                'Xóa',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );

                                              if (confirmed == true) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Xóa thành công ${item.product.name} - ${GetSizeString(item.size)}',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                                setState(() {
                                                  GlobalData.cartItemList
                                                      .remove(item);
                                                });
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Đã hủy xóa ${item.product.name} - ${GetSizeString(item.size)}',
                                                    ),
                                                    backgroundColor:
                                                        Colors.grey,
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },

                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Xóa',
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF3E0),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.brown.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              item.product.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    GetSizeString(item.size),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    item.product.name,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${format.format(item.product.price)} đ',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (item.amount > 1)
                                                        item.amount--;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                  ),
                                                  color: Colors.redAccent,
                                                  iconSize: 24,
                                                ),
                                                Text(
                                                  '${item.amount}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (item.amount < max)
                                                        item.amount++;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_circle_outline,
                                                  ),
                                                  color: Colors.green,
                                                  iconSize: 24,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        SizedBox(height: 10),

                        // Phone
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Số điện thoại",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        TextField(
                          controller: _controllerPhone,
                          decoration: InputDecoration(
                            hintText: "Nhập số điện thoại",
                            hintStyle: TextStyle(color: Colors.orange[200]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(179, 255, 46, 175),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Name
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Họ và tên",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        TextField(
                          controller: _controllerName,
                          decoration: InputDecoration(
                            hintText: "Nhập họ và tên",
                            hintStyle: TextStyle(color: Colors.orange[200]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(179, 255, 46, 175),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Adress
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Bàn",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        //Table
                        DropdownButtonFormField<String>(
                          value: _selectedTable,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTable = newValue!;
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: '',
                              child: Text(
                                "--Chọn--",
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
                            hintText: "Chọn bàn",
                            hintStyle: TextStyle(color: Colors.orange[200]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(179, 255, 46, 175),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.table_bar_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Discount Coupon
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Phiếu giảm giá",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        //Coupon
                        TextField(
                          controller: _controllerDiscountCoupon,
                          decoration: InputDecoration(
                            hintText: "Nhập mã giảm giá",
                            hintStyle: TextStyle(color: Colors.orange[200]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(179, 255, 46, 175),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.card_giftcard,
                              color: Colors.redAccent,
                            ),
                            suffixIcon: SizedBox(
                              width: 100,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (GlobalData.cartItemList.isNotEmpty &&
                                        _controllerDiscountCoupon
                                            .text
                                            .isNotEmpty) {
                                      if (_coupons
                                          .where(
                                            (element) =>
                                                element ==
                                                _controllerDiscountCoupon.text,
                                          )
                                          .isNotEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Mã giảm giá đã được áp dụng!",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Mã giảm giá này không tồn tại!",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        _controllerDiscountCoupon.text = '';
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Vui lòng nhập mã giảm giá hợp lệ",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      _controllerDiscountCoupon.text = '';
                                    }
                                  });
                                },
                                style: TextButton.styleFrom(
                                  elevation: 4,
                                  // ignore: deprecated_member_use
                                  shadowColor: Colors.black.withOpacity(0.3),
                                  minimumSize: const Size(0, 0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: Colors.lightBlueAccent,
                                  textStyle: TextStyle(
                                    color: Colors.orange[400],
                                  ),
                                ),
                                child: Text(
                                  'Áp dụng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[400],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //Subtotal, delivery charge, discount and total
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Subtotal
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Tạm tính:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${format.format(subTotal)} đ',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Delivery Charges
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Phí vận chuyển:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${format.format(deliveryCharge)} đ',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Discount
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Giảm giá:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${format.format(discount)} đ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Discount
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Tiền công:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${format.format(tiencong)} đ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DashedDivider(
                              width: detailsWidth,
                              dashWidth: 6,
                              dashSpace: 4,
                              thickness: 1,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            // Total
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Tổng cộng:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${format.format(total)} đ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimateGradient(
              primaryBegin: Alignment.topLeft,
              primaryEnd: Alignment.bottomRight,
              secondaryBegin: Alignment.bottomRight,
              secondaryEnd: Alignment.topLeft,
              duration: const Duration(seconds: 4),
              primaryColors: const [
                Color(0xFFFFA726), // Orange (harmony, warmth)
                Color(0xFF9575CD), // Deep Purple (balance)
              ],
              secondaryColors: const [
                Color(0xFFD7CCC8), // Latte / Tan (smooth coffee tone)
                Color(0xFFFF7043), // Bright orange accent
              ],
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
                        Icon(Icons.coffee, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Thanh toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
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
      ),
    );
  }
}
