import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/UI/SplashScreen/splashscreen.dart';
import 'package:coffeeapp/UI/admin/analystpage.dart';
import 'package:coffeeapp/UI/admin/category_managementpage.dart';
import 'package:coffeeapp/UI/admin/order_managementpage.dart';
import 'package:coffeeapp/UI/admin/product_managementpage.dart';
import 'package:coffeeapp/UI/admin/table_management.dart';
import 'package:coffeeapp/UI/admin/user_management.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MenuNavigationbarAdmin extends StatefulWidget {
  const MenuNavigationbarAdmin({super.key});

  @override
  State<MenuNavigationbarAdmin> createState() => _MenuNavigationbarAdminState();
}

class _MenuNavigationbarAdminState extends State<MenuNavigationbarAdmin> {
  late int selectedIndex;
  List<Widget> _pages = <Widget>[];
  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    _pages = <Widget>[
      Center(child: AnalystPage()),
      Center(child: ProductManagementPage()),
      Center(child: CategoryManagementPage()),
      Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          icon: const Icon(Icons.logout),
          label: const Text(
            'Thoát khỏi admin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          },
        ),
      ),
      Center(child: OrderManagementPage()),
      Center(child: TableManagementPage()),
      Center(child: UserManagementPage()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _pages = <Widget>[
      Center(child: AnalystPage()),
      Center(child: ProductManagementPage()),
      Center(child: CategoryManagementPage()),
      Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          icon: const Icon(Icons.logout),
          label: const Text(
            'Thoát khỏi admin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          },
        ),
      ),
      Center(child: OrderManagementPage()),
      Center(child: TableManagementPage()),
      Center(child: UserManagementPage()),
    ];
    return Scaffold(
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topLeft,
        duration: const Duration(seconds: 6),
        primaryColors: ColorSetupBackground.primaryColorsDark,
        secondaryColors: ColorSetupBackground.secondaryColorsDark,
        child: _pages[selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GNav(
                gap: 5,
                backgroundColor: Colors.transparent,
                color: Colors.grey[800],
                activeColor: Colors.orange[200],
                tabBackgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                selectedIndex: selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                tabs: [
                  GButton(icon: Icons.analytics, text: 'Thống kê'),
                  GButton(icon: Icons.storage, text: 'Kho sản phẩm'),
                  GButton(icon: Icons.category, text: 'Danh mục loại sản phẩm'),
                  GButton(icon: Icons.logout, text: 'Đăng xuất'),
                  GButton(
                    icon: Icons.delivery_dining_rounded,
                    text: 'Đơn hàng',
                  ),
                  GButton(icon: Icons.table_bar_sharp, text: 'Bàn'),
                  GButton(
                    icon: Icons.account_circle,
                    text: 'Danh sách người dùng',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
