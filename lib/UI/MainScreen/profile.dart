import 'dart:ui';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/User/userinformation.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/menuitem.dart';
import 'package:coffeeapp/UI/Login_Register/coffeeloginregisterscreen.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
import 'package:coffeeapp/UI/Order/historyorder.dart';
import 'package:coffeeapp/Entity/userdetail.dart';

class Profile extends StatefulWidget {
  final bool isDark;
  const Profile({super.key, required this.isDark});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;
  }

  // Map hình ảnh rank
  Map<String, String> ranks = {
    'Hạng đồng': 'assets/images/rank/r1.png',
    'Hạng bạc': 'assets/images/rank/r0.png',
    'Hạng vàng': 'assets/images/rank/r2.png',
    'Hạng kim cương xanh': 'assets/images/rank/r3.png',
    'Hạng kim cương tím': 'assets/images/rank/r4.png',
    'Hạng kim cương đỏ': 'assets/images/rank/r5.png',
  };

  @override
  Widget build(BuildContext context) {
    // Xử lý an toàn nếu rank chưa load kịp
    String imageRank = 'assets/images/rank/r1.png'; 
    if (GlobalData.userDetail.rank.isNotEmpty && ranks.containsKey(GlobalData.userDetail.rank)) {
       imageRank = ranks[GlobalData.userDetail.rank]!;
    }

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (context, snapshot) {
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      /// --- AVATAR & INFO ---
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF8A00), width: 2), // Viền Cam
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: AssetImage(GlobalData.userDetail.photoURL),
                            ),
                          ),
                          // Rank Icon nhỏ ở góc avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Image.asset(imageRank, width: 25, height: 25),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 15),

                      Text(
                        GlobalData.userDetail.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Đổi thành màu trắng
                        ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A00).withOpacity(0.2), // Nền cam mờ
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          GlobalData.userDetail.rank,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF8A00), 
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// --- MENU OPTIONS ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B3D45).withOpacity(0.6), // Màu nền giống Category Button ở Home
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                          ]
                        ),
                        child: Column(
                          children: [
                            _buildMenuRow(context, "Thông tin tài khoản", Icons.person_outline, () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => UserInformation(isDark: widget.isDark, index: 2)));
                            }),
                            _buildDivider(),
                            
                            _buildMenuRow(context, "Giỏ hàng", Icons.shopping_bag_outlined, () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => Cart(isDark: widget.isDark, index: 2)));
                            }),
                             _buildDivider(),

                            _buildMenuRow(context, "Lịch sử đơn hàng", Icons.history, () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryOrder(isDark: widget.isDark, index: 2)));
                            }),
                             _buildDivider(),

                            _buildMenuRow(context, "Cài đặt", Icons.settings_outlined, () {}),
                             _buildDivider(),
                             
                            _buildMenuRow(context, "Về ứng dụng", Icons.info_outline, () {}),
                             _buildDivider(),

                            // Nút Đăng xuất
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: const Icon(Icons.logout, color: Colors.redAccent),
                              ),
                              title: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                try {
                                  await FirebaseDBManager.authService.logout();
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  GlobalData.userDetail = UserDetail(uid: "", username: "", email: "", password: "", photoURL: "", rank: "", point: 0, role: "");
                                  navigator.pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const CoffeeLoginRegisterScreen()),
                                    (route) => false,
                                  );
                                } catch (e) {
                                  // Error handling
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Khoảng trống dưới cùng
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

  Widget _buildMenuRow(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(icon, color: Colors.white70),
      ),
      title: Text(
        title, 
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), height: 1);
  }
}