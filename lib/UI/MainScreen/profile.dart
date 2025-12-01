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
import 'package:firebase_auth/firebase_auth.dart';

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
    String imageRank = ranks.entries
        .firstWhere((element) => element.key == GlobalData.userDetail.rank)
        .value;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    /// Avatar
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                            AssetImage(GlobalData.userDetail.photoURL),
                          ),
                          const SizedBox(height: 5),

                          Text(
                            GlobalData.userDetail.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                GlobalData.userDetail.rank,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 3, 180),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Image.asset(
                                imageRank,
                                width: 35,
                                height: 35,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Menu
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          MenuItem(
                            title: "Thông tin tài khoản",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserInformation(isDark: widget.isDark, index: 2),
                                ),
                              );
                            },
                          ),
                          MenuItem(
                            title: "Giỏ hàng",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Cart(isDark: widget.isDark, index: 2),
                                ),
                              );
                            },
                          ),
                          MenuItem(
                            title: "Lịch sử đơn hàng",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoryOrder(isDark: widget.isDark, index: 2),
                                ),
                              );
                            },
                          ),
                          MenuItem(title: "Cài đặt"),
                          MenuItem(title: "Về app"),
                          
                        MenuItem(
                          title: "Đăng xuất",
                          onTap: () async {
                            final navigator = Navigator.of(context);

                            try {
                              // ✅ Gọi logout chính thức
                              await FirebaseDBManager.authService.logout();

                              // ✅ Reset lại session cho chắc (đợi Firebase clear cache)
                              await Future.delayed(const Duration(milliseconds: 300));

                              // ✅ Xóa dữ liệu user hiện tại trong GlobalData
                              GlobalData.userDetail = UserDetail(
                                uid: "",
                                username: "",
                                email: "",
                                password: "",
                                photoURL: "",
                                rank: "",
                                point: 0,
                                role: "",
                              );

                              // ✅ Quay lại màn hình login, xóa toàn bộ navigation stack
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const CoffeeLoginRegisterScreen(),
                                ),
                                (route) => false,
                              );
                            } catch (e) {
                              debugPrint("❌ Lỗi khi đăng xuất: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Đăng xuất thất bại!")),
                                );
                              }
                            }
                          },
                        ),










                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
