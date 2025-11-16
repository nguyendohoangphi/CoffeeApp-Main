import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/coupon.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserInformation extends StatefulWidget {
  final bool isDark;
  final int index;
  const UserInformation({super.key, required this.isDark, required this.index});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  late int currentRank = 0;
  late int totalOrders = 0;
  late int totalDrinks = 0;
  late double totalPayment = 0;
  late List<String> drinkList = [];
  late List<OrderItem> orderItemList = [];
  late List<CartItem> cartItemList = [];

  Map<String, String> ranks = {
    'Hạng đồng': 'assets/images/rank/r1.png',
    'Hạng bạc': 'assets/images/rank/r0.png',
    'Hạng vàng': 'assets/images/rank/r2.png',
    'Hạng kim cương xanh': 'assets/images/rank/r3.png',
    'Hạng kim cương tím': 'assets/images/rank/r4.png',
    'Hạng kim cương đỏ': 'assets/images/rank/r5.png',
  };

  Map<String, Map<String, List<Color>>> rankGradients = {
    'bronze': {
      'primary': [Color(0xFFCD7F32), Color(0xFFB87333), Colors.white],
      'secondary': [Colors.white, Color(0xFFB87333), Color(0xFFCD7F32)],
    },
    'silver': {
      'primary': [Color(0xFFC0C0C0), Colors.grey, Colors.white],
      'secondary': [Colors.white, Colors.grey, Color(0xFFC0C0C0)],
    },
    'gold': {
      'primary': [Color(0xFFFFD700), Color(0xFFFFC107), Colors.white],
      'secondary': [Colors.white, Color(0xFFFFC107), Color(0xFFFFD700)],
    },
    'blue diamond': {
      'primary': [Colors.lightBlueAccent, Colors.blue, Colors.white],
      'secondary': [Colors.white, Colors.blueAccent, Colors.lightBlue],
    },
    'purple diamond': {
      'primary': [Colors.purpleAccent, Colors.deepPurple, Colors.white],
      'secondary': [Colors.white, Colors.deepPurpleAccent, Colors.purple],
    },
    'red diamond': {
      'primary': [Colors.redAccent, Colors.red, Colors.white],
      'secondary': [Colors.white, Colors.red, Colors.redAccent],
    },
  };
  late List<String> coupons = []; // Customize as needed

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentRank = 0;
    totalOrders = 0;
    totalDrinks = 0;
    totalPayment = 0;
    drinkList = [];
    coupons = [];
  }

  late int nextRank = 0;
  late int pointsToNext = 0;
  late double rankProgress = 0;
  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    currentRank = 0;
    totalOrders = 0;
    totalDrinks = 0;
    totalPayment = 0;
    drinkList = [];
    coupons = [];

    GlobalData.userDetail = (await FirebaseDBManager.authService.getUserDetail(
      GlobalData.userDetail.email,
    ))!;

    Coupon coupon = await FirebaseDBManager.couponService.getCoupon(
      GlobalData.userDetail.email,
    );

    for (String code in coupon.codes) {
      coupons.add(code);
    }

    orderItemList = await FirebaseDBManager.orderService.getOrdersByEmail(
      GlobalData.userDetail.email,
    );

    for (OrderItem orderItem in orderItemList) {
      cartItemList.addAll(
        await FirebaseDBManager.cartService.getCartItemsByOrder(orderItem.id),
      );
    }

    totalOrders = orderItemList.length;
    for (CartItem cartItem in cartItemList) {
      if (!drinkList.contains(cartItem.productName)) {
        drinkList.add(cartItem.productName);
        totalDrinks++;
      }
    }
    for (OrderItem orderItem in orderItemList) {
      totalPayment += double.parse(orderItem.total);
    }
    switch (GlobalData.userDetail.rank) {
      case 'Hạng đồng':
        currentRank = 0;
        break;
      case 'Hạng bạc':
        currentRank = 1;
        break;
      case 'Hạng vàng':
        currentRank = 2;
        break;
      case 'Hạng kim cương xanh':
        currentRank = 3;
        break;
      case 'Hạng kim cương tím':
        currentRank = 4;
        break;
      case 'Hạng kim cương đỏ':
        currentRank = 5;
        break;
    }

    nextRank = currentRank < 5 ? currentRank + 1 : 5;
    pointsToNext = (nextRank * 100) - GlobalData.userDetail.point;
    rankProgress = GlobalData.userDetail.point / (nextRank * 100);
    if (rankProgress > 1) {
      rankProgress = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    var format = NumberFormat("#,###", "vi_VN");

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
            elevation: 2.0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            ),
            title: Text('Thông tin tài khoản'),
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
          builder: (context, asyncSnapshot) {
            return SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      AnimateGradient(
                        primaryBeginGeometry: const AlignmentDirectional(0, 1),
                        primaryEndGeometry: const AlignmentDirectional(0, 2),
                        secondaryBeginGeometry: const AlignmentDirectional(
                          2,
                          0,
                        ),
                        secondaryEndGeometry: const AlignmentDirectional(
                          0,
                          -0.8,
                        ),
                        primaryColors: rankGradients.entries
                            .elementAt(currentRank)
                            .value
                            .entries
                            .first
                            .value,
                        secondaryColors: rankGradients.entries
                            .elementAt(currentRank)
                            .value
                            .entries
                            .last
                            .value,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  GlobalData.userDetail.photoURL,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                GlobalData.userDetail.displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                GlobalData.userDetail.rank,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // BODY
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimateGradient(
                          primaryColors: const [
                            Color(0xFFFDEBD0), // Vàng nhạt
                            Color(0xFFFFF3E0), // Kem sáng
                            Color(0xFFEDE7F6), // Tím pastel
                          ],
                          secondaryColors: const [
                            Color(0xFFFFF8E1), // Vàng sáng
                            Color(0xFFE0F7FA), // Xanh sáng nhẹ
                            Color(0xFFF3E5F5), // Tím nhẹ
                          ],
                          duration: const Duration(seconds: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildSectionTitle("☕ Tổng Quan"),
                                ListTile(
                                  leading: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.brown,
                                  ),
                                  title: const Text("Tổng đơn hàng đã đặt"),
                                  trailing: Text("$totalOrders"),
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.local_cafe,
                                    color: Colors.brown,
                                  ),
                                  title: const Text("Tổng nước uống đã uống"),
                                  trailing: Text("$totalDrinks"),
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.payment,
                                    color: Colors.brown,
                                  ),
                                  title: const Text("Tổng tiền đã thanh toán"),
                                  trailing: Text(
                                    "${format.format(totalPayment)} đ",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      buildSectionTitle("☕ Nước Uống Đã Thử"),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: drinkList.map((drink) {
                          return Chip(
                            label: Text(drink),
                            backgroundColor: Colors.brown[100],
                            avatar: const Icon(Icons.coffee, size: 16),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          buildSectionTitle("🎖️ Tiến Trình Hạng"),
                          SizedBox(width: 10),
                          Image.asset(
                            ranks.entries.elementAt(currentRank).value,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Stack(
                          children: [
                            // Background bar
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),

                            // Foreground progress with AnimateGradient
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: rankProgress.clamp(
                                    0,
                                    1,
                                  ), // Progress width
                                  child: AnimateGradient(
                                    primaryColors: rankGradients.entries
                                        .elementAt(currentRank)
                                        .value
                                        .entries
                                        .first
                                        .value,
                                    secondaryColors: rankGradients.entries
                                        .elementAt(currentRank)
                                        .value
                                        .entries
                                        .last
                                        .value,
                                    duration: const Duration(seconds: 4),
                                    primaryBegin: Alignment.centerLeft,
                                    primaryEnd: Alignment.centerRight,
                                    secondaryBegin: Alignment.centerRight,
                                    secondaryEnd: Alignment.centerLeft,
                                    child: Container(height: 10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Điểm còn lại để đạt hạng tiếp theo (${ranks.entries.elementAt(nextRank).key}): $pointsToNext điểm",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 10),
                      Column(
                        children: [
                          buildSectionTitle("🎁 Phiếu Giảm Giá"),
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: 200, // fixed height for the list
                                child: ListView.builder(
                                  itemCount: coupons.length,
                                  itemBuilder: (context, index) {
                                    final coupon = coupons[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.local_offer,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              coupon,
                                              style: const TextStyle(
                                                fontSize: 16,
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
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: Center(
                              child: AnimateGradient(
                                primaryColors: const [
                                  Color(0xFF6D4C41), // Coffee brown đậm
                                  Color(0xFF8D6E63), // Mocha
                                  Color(0xFFA1887F), // Latte
                                ],
                                secondaryColors: const [
                                  Color(0xFF5D4037), // Cacao đậm
                                  Color(0xFF795548), // Nâu dịu nhẹ
                                  Color(0xFFBCAAA4), // Sữa nâu
                                ],
                                duration: const Duration(seconds: 5),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Change password logic
                                    },
                                    icon: const Icon(Icons.lock_outline),
                                    label: const Text("Thay đổi mật khẩu"),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: const Color(
                                        0xFF512DA8,
                                      ), // Tím đậm dịu
                                      backgroundColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      shadowColor: Colors.black26,
                                      elevation: 6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Update password
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.isDark ? Colors.orange[200] : Colors.brown[800],
        ),
      ),
    );
  }
}
