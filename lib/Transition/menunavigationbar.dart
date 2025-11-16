// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/UI/MainScreen/category.dart';
import 'package:coffeeapp/UI/MainScreen/home.dart';
import 'package:coffeeapp/UI/MainScreen/profile.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// ignore: must_be_immutable
class MenuNavigationBar extends StatefulWidget {
  late bool isDark;
  late int selectedIndex;
  MenuNavigationBar({
    required this.isDark,
    required this.selectedIndex,
    super.key,
  });

  @override
  State<MenuNavigationBar> createState() => _MenuNavigationBarState();
}

class _MenuNavigationBarState extends State<MenuNavigationBar> {
  void updateDarkMode(bool value) {
    setState(() {
      widget.isDark = value;
    });
  }

  List<Widget> _pages = <Widget>[];
  @override
  void initState() {
    super.initState();

    _pages = <Widget>[
      Center(
        child: Home(isDark: widget.isDark, onDarkChanged: updateDarkMode),
      ),
      Center(
        child: Category(isDark: widget.isDark, onDarkChanged: updateDarkMode),
      ),
      Center(child: Profile(isDark: widget.isDark)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _pages = <Widget>[
      Center(
        child: Home(isDark: widget.isDark, onDarkChanged: updateDarkMode),
      ),
      Center(
        child: Category(isDark: widget.isDark, onDarkChanged: updateDarkMode),
      ),
      Center(child: Profile(isDark: widget.isDark)),
    ];
    return Scaffold(
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
        child: _pages[widget.selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white70, // Same as GNav background
              borderRadius: BorderRadius.circular(10),
            ),
            child: GNav(
              gap: 5,
              backgroundColor: Colors.transparent, // Use container's color
              color: Colors.grey[800],
              activeColor: Colors.orange[200],
              tabBackgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              selectedIndex: widget.selectedIndex,
              onTabChange: (index) {
                setState(() {
                  widget.selectedIndex = index;
                });
              },
              tabs: [
                GButton(icon: Icons.home, text: 'Trang chính'),
                GButton(icon: Icons.apps, text: 'Danh mục nước uống'),
                GButton(icon: Icons.person, text: 'Cá nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
