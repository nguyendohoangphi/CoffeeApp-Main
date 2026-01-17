// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:ui';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/models/userdetail.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/screens/User/userinformation.dart';
import 'package:coffeeapp/constants/app_colors.dart'; 
import 'package:flutter/material.dart';
import 'package:coffeeapp/screens/Login_Register/coffeeloginregisterscreen.dart';
import 'package:coffeeapp/screens/Order/cart.dart';
import 'package:coffeeapp/screens/Order/historyorder.dart';

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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      /// --- 1. USER INFO CARD ---
                      Column(
                        children: [
                          // Avatar Container with Hero
                          Hero(
                            tag: 'profile_avatar',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3), 
                                    blurRadius: 20, 
                                    offset: const Offset(0, 8)
                                  )
                                ]
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(GlobalData.userDetail.photoURL.isNotEmpty ? GlobalData.userDetail.photoURL : 'assets/images/default_avatar.png'),
                                onBackgroundImageError: (_, __) {},
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Name
                          Text(
                            GlobalData.userDetail.username.isNotEmpty ? GlobalData.userDetail.username : "User",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),

                          // Rank Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.5))
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(imageRank, width: 20, height: 20, errorBuilder: (_,__,___) => const Icon(Icons.star, color: AppColors.primary, size: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  GlobalData.userDetail.rank.isNotEmpty ? GlobalData.userDetail.rank : "Thành viên mới",
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

                      const SizedBox(height: 40),

                      /// --- 2. MENU GROUP 1: CÁ NHÂN ---
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child)
                          );
                        },
                        child: Column(
                          children: [
                            _buildSectionTitle("Cá nhân"),
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                   BoxShadow(
                                     color: AppColors.getShadow(widget.isDark).color, 
                                     blurRadius: 15, 
                                     offset: const Offset(0, 5)
                                   )
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
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),

                      /// --- 3. MENU GROUP 2: ỨNG DỤNG ---
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child)
                          );
                        },
                        child: Column(
                          children: [
                            _buildSectionTitle("Ứng dụng"),
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                   BoxShadow(
                                     color: AppColors.getShadow(widget.isDark).color, 
                                     blurRadius: 15, 
                                     offset: const Offset(0, 5)
                                   )
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// --- 4. LOGOUT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                             try {
                                await FirebaseDBManager.authService.logout();
                                GlobalData.userDetail = UserDetail(uid: "", username: "", email: "", password: "", photoURL: "", rank: "", point: 0, role: "");
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const CoffeeLoginRegisterScreen()),
                                  (route) => false,
                                );
                              } catch (e) {
                                debugPrint(e.toString());
                              }
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 5,
                            shadowColor: Colors.redAccent.withOpacity(0.4),
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
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Widget dòng menu
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
           child: Row(
             children: [
               Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Text(
                  title, 
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)
                 ),
               ),
               Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
             ],
           ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 20),
      child: Divider(color: widget.isDark ? Colors.grey[800] : Colors.grey[100], height: 1),
    );
  }
}
