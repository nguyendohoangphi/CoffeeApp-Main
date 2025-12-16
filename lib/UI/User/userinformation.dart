import 'dart:ui';
import 'package:animate_gradient/animate_gradient.dart';
//import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/coupon.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/constants/app_colors.dart'; // Import bộ màu chuẩn
import 'package:firebase_auth/firebase_auth.dart';
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
  late List<String> coupons = [];

  // Theme Helpers
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get cardColor => widget.isDark ? AppColors.cardDark : Colors.white;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
  Color get subTextColor => widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

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

  @override
  void initState() {
    super.initState();
    _resetData();
  }

  void _resetData() {
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

  Future<void> LoadData() async {
    _resetData();

    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;

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
      case 'Hạng đồng': currentRank = 0; break;
      case 'Hạng bạc': currentRank = 1; break;
      case 'Hạng vàng': currentRank = 2; break;
      case 'Hạng kim cương xanh': currentRank = 3; break;
      case 'Hạng kim cương tím': currentRank = 4; break;
      case 'Hạng kim cương đỏ': currentRank = 5; break;
    }

    nextRank = currentRank < 5 ? currentRank + 1 : 5;
    pointsToNext = (nextRank * 100) - GlobalData.userDetail.point;
    rankProgress = GlobalData.userDetail.point / (nextRank * 100);
    if (rankProgress > 1) rankProgress = 1;
  }

  @override
  Widget build(BuildContext context) {
    var format = NumberFormat("#,###", "vi_VN");

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
          },
        ),
        title: Text(
          'Thông tin tài khoản',
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: textColor
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (context, asyncSnapshot) {
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER CARD (Rank) ---
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimateGradient(
                            primaryColors: rankGradients.entries.elementAt(currentRank).value.entries.first.value,
                            secondaryColors: rankGradients.entries.elementAt(currentRank).value.entries.last.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Họa tiết nền mờ (Optional)
                                Positioned(right: -30, top: -30, child: Icon(Icons.star, size: 150, color: Colors.white.withOpacity(0.1))),
                                
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundImage: AssetImage(GlobalData.userDetail.photoURL),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      GlobalData.userDetail.username,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        GlobalData.userDetail.rank,
                                        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- SECTION 1: TỔNG QUAN ---
                      _buildSectionTitle("Thống kê hoạt động"),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(Icons.shopping_bag_outlined, "Đơn hàng đã đặt", "$totalOrders", Colors.blueAccent),
                            _buildDivider(),
                            _buildStatRow(Icons.local_cafe_outlined, "Số ly đã uống", "$totalDrinks", Colors.brown),
                            _buildDivider(),
                            _buildStatRow(Icons.payments_outlined, "Tổng chi tiêu", "${format.format(totalPayment)} đ", Colors.green),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- SECTION 2: DANH SÁCH ĐỒ UỐNG ---
                      _buildSectionTitle("Đồ uống đã thử"),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: drinkList.map((drink) {
                          return Chip(
                            label: Text(drink, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                            backgroundColor: cardColor,
                            avatar: Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                            elevation: 2,
                            shadowColor: Colors.black12,
                            padding: const EdgeInsets.all(8),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 25),

                      // --- SECTION 3: TIẾN TRÌNH ---
                      Row(
                        children: [
                          _buildSectionTitle("Tiến trình thăng hạng", noPadding: true),
                          const Spacer(),
                          Image.asset(ranks.entries.elementAt(currentRank).value, width: 30, height: 30),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: rankProgress.clamp(0.0, 1.0),
                                minHeight: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Cần thêm $pointsToNext điểm để lên ${ranks.entries.elementAt(nextRank).key}",
                              style: TextStyle(color: subTextColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- SECTION 4: COUPON ---
                      _buildSectionTitle("Kho Voucher"),
                      SizedBox(
                        height: 140,
                        child: coupons.isEmpty 
                          ? Center(child: Text("Bạn chưa có mã giảm giá nào", style: TextStyle(color: subTextColor)))
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: coupons.length,
                              separatorBuilder: (_,__) => const SizedBox(width: 15),
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.confirmation_number_outlined, color: Colors.orange, size: 30),
                                      const SizedBox(height: 10),
                                      Text(
                                        coupons[index],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
                                      ),
                                      const Text("Mã giảm giá", style: TextStyle(fontSize: 12, color: Colors.orangeAccent)),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),

                      const SizedBox(height: 30),

                      // --- NÚT ĐỔI MẬT KHẨU ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: const Icon(Icons.lock_reset),
                          label: const Text("Đổi mật khẩu"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildSectionTitle(String title, {bool noPadding = false}) {
    return Padding(
      padding: noPadding ? EdgeInsets.zero : const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: textColor
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
          ),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.1), height: 20);
  }

  // Logic Dialog Đổi mật khẩu (Giữ nguyên logic)
  Future<void> _showChangePasswordDialog() async {
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();
    bool isOldVisible = false;
    bool isNewVisible = false;
    bool isConfirmVisible = false;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.security, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text("Đổi mật khẩu", style: TextStyle(color: textColor)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPassField(oldPassController, "Mật khẩu cũ", isOldVisible, () => setStateDialog(() => isOldVisible = !isOldVisible)),
                    const SizedBox(height: 15),
                    _buildPassField(newPassController, "Mật khẩu mới", isNewVisible, () => setStateDialog(() => isNewVisible = !isNewVisible)),
                    const SizedBox(height: 15),
                    _buildPassField(confirmPassController, "Nhập lại mật khẩu mới", isConfirmVisible, () => setStateDialog(() => isConfirmVisible = !isConfirmVisible)),
                    
                    if (isLoading)
                      const Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator(color: AppColors.primary)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy", style: TextStyle(color: subTextColor)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    // ... (Giữ nguyên logic xử lý Firebase của bạn) ...
                    final oldPass = oldPassController.text.trim();
                    final newPass = newPassController.text.trim();
                    final confirmPass = confirmPassController.text.trim();

                    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❗Vui lòng nhập đầy đủ thông tin."), backgroundColor: Colors.orange));
                      return;
                    }
                    if (newPass != confirmPass) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Mật khẩu xác nhận không khớp."), backgroundColor: Colors.red));
                      return;
                    }

                    setStateDialog(() => isLoading = true);
                    try {
                      final user = FirebaseAuth.instance.currentUser!;
                      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPass);
                      await user.reauthenticateWithCredential(cred);
                      await user.updatePassword(newPass);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Đổi mật khẩu thành công!"), backgroundColor: Colors.green));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
                    } finally {
                      setStateDialog(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPassField(TextEditingController controller, String label, bool isVisible, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subTextColor),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: subTextColor),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}