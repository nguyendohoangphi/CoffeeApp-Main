// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:ui';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/userdetail.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/User/userinformation.dart';
import 'package:coffeeapp/constants/app_colors.dart'; 
import 'package:flutter/material.dart';
import 'package:coffeeapp/UI/Login_Register/coffeeloginregisterscreen.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
import 'package:coffeeapp/UI/Order/historyorder.dart';

class Profile extends StatefulWidget {
  final bool isDark;
  const Profile({super.key, required this.isDark});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get cardColor => widget.isDark ? AppColors.cardDark : Colors.white;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;

  Future<void> loadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;
  }

  final Map<String, String> ranks = {
    'Hạng đồng': 'assets/images/rank/r1.png',
    'Hạng bạc': 'assets/images/rank/r0.png',
    'Hạng vàng': 'assets/images/rank/r2.png',
    'Hạng kim cương xanh': 'assets/images/rank/r3.png',
    'Hạng kim cương tím': 'assets/images/rank/r4.png',
    'Hạng kim cương đỏ': 'assets/images/rank/r5.png',
  };

  @override
  Widget build(BuildContext context) {
    String imageRank = 'assets/images/rank/r1.png';
    if (GlobalData.userDetail.rank.isNotEmpty && ranks.containsKey(GlobalData.userDetail.rank)) {
       imageRank = ranks[GlobalData.userDetail.rank]!;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<void>(
        future: loadData(),
        builder: (context, snapshot) {
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
                    children: [
                      const SizedBox(height: 20),

                      /// --- 1. USER INFO CARD ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            children: [
                              // Avatar Container
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 3),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 5))
                                  ]
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(GlobalData.userDetail.photoURL),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Name
                              Text(
                                GlobalData.userDetail.username,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              
                              const SizedBox(height: 8),

                              // Rank Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.5))
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(imageRank, width: 20, height: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      GlobalData.userDetail.rank,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// --- 2. MENU GROUP 1: CÁ NHÂN ---
                      _buildSectionTitle("Cá nhân"),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))
                          ]
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem("Thông tin tài khoản", Icons.person_outline, () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => UserInformation(isDark: widget.isDark, index: 2)));
                            }),
                            _buildDivider(),
                            _buildMenuItem("Giỏ hàng của tôi", Icons.shopping_bag_outlined, () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => Cart(isDark: widget.isDark, index: 2)));
                            }),
                             _buildDivider(),
                            _buildMenuItem("Lịch sử đơn hàng", Icons.history, () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryOrder(isDark: widget.isDark, index: 2)));
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),

                      /// --- 3. MENU GROUP 2: ỨNG DỤNG ---
                      _buildSectionTitle("Ứng dụng"),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))
                          ]
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem("Cài đặt", Icons.settings_outlined, () {}),
                            _buildDivider(),
                            _buildMenuItem("Về chúng tôi", Icons.info_outline, () {}),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// --- 4. LOGOUT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () async {
                            // Logout Logic
                             try {
                                await FirebaseDBManager.authService.logout();
                                GlobalData.userDetail = UserDetail(uid: "", username: "", email: "", password: "", photoURL: "", rank: "", point: 0, role: "");
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const CoffeeLoginRegisterScreen()),
                                  (route) => false,
                                );
                              } catch (e) {
                                print(e);
                              }
                          },
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          label: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100), // Khoảng trống dưới cùng cho BottomBar
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

  // Widget tiêu đề nhóm
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // Widget dòng menu
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title, 
        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.1), height: 1, indent: 60, endIndent: 20);
  }
}