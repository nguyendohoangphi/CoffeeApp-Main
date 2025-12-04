import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
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
      extendBody: true, 
      backgroundColor: Colors.transparent, 

      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Cart(isDark: _isDark, index: _selectedIndex),
                  ),
                ).then((value) => refreshCart());
              },
              backgroundColor: const Color(0xFFFF8A00),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -12, end: -10),
                showBadge: GlobalData.cartItemList.isNotEmpty,
                badgeContent: Text(
                  GlobalData.cartItemList.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
            )
          : null,
      
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topLeft,
        duration: const Duration(seconds: 6),
        primaryColors: _isDark
            ? ColorSetupBackground.primaryColorsDark
            : ColorSetupBackground.primaryColorsLight,
        secondaryColors: _isDark
            ? ColorSetupBackground.secondaryColorsDark
            : ColorSetupBackground.secondaryColorsLight,
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15), 
          decoration: BoxDecoration(
            // --- ĐÃ ĐỔI MÀU TẠI ĐÂY ---
            // Dùng màu 0xFF3B3D45 để giống hệt cái khung trong Profile
            color: _isDark ? const Color(0xFF3B3D45) : Colors.white, 
            
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: GNav(
              gap: 8,
              backgroundColor: Colors.transparent,
              color: Colors.grey[400], // Màu icon chưa chọn (sáng hơn chút cho dễ nhìn trên nền xám)
              activeColor: Colors.white,
              tabBackgroundColor: const Color(0xFFFF8A00), 
              padding: const EdgeInsets.all(12),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Trang chủ',
                ),
                GButton(
                  icon: Icons.grid_view_rounded,
                  text: 'Danh mục',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Tài khoản',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}