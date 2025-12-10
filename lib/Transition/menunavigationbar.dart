import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
import 'package:coffeeapp/constants/app_colors.dart'; // Import file màu mới
import 'package:flutter/material.dart';
import 'package:coffeeapp/UI/MainScreen/category.dart';
import 'package:coffeeapp/UI/MainScreen/home.dart';
import 'package:coffeeapp/UI/MainScreen/profile.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:badges/badges.dart' as badges;

class MenuNavigationBar extends StatefulWidget {
  final bool isDark;
  final int selectedIndex;

  const MenuNavigationBar({
    required this.isDark,
    required this.selectedIndex,
    super.key,
  });

  @override
  State<MenuNavigationBar> createState() => _MenuNavigationBarState();
}

class _MenuNavigationBarState extends State<MenuNavigationBar> {
  late bool _isDark;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _selectedIndex = widget.selectedIndex;
  }

  void updateDarkMode(bool value) {
    setState(() {
      _isDark = value;
    });
  }

  void refreshCart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Home(isDark: _isDark, onDarkChanged: updateDarkMode),
      Category(isDark: _isDark, onDarkChanged: updateDarkMode),
      Profile(isDark: _isDark),
    ];

    return Scaffold(
      extendBody: true, // Để nền tràn xuống dưới bottom bar
      backgroundColor: _isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      // --- NÚT GIỎ HÀNG NỔI (Floating Cart) ---
      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(isDark: _isDark, index: _selectedIndex),
                  ),
                ).then((value) => refreshCart());
              },
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -12, end: -10),
                showBadge: GlobalData.cartItemList.isNotEmpty,
                badgeContent: Text(
                  GlobalData.cartItemList.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
            )
          : null,

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      // --- THANH ĐIỀU HƯỚNG HIỆN ĐẠI ---
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            color: _isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GNav(
              gap: 8,
              backgroundColor: Colors.transparent,
              color: _isDark ? Colors.grey[400] : Colors.grey[600],
              activeColor: Colors.white,
              iconSize: 24,
              tabBackgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(12),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Trang chủ'),
                GButton(icon: Icons.grid_view_rounded, text: 'Thực đơn'),
                GButton(icon: Icons.person_rounded, text: 'Tài khoản'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}