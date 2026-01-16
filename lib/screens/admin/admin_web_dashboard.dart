// ignore_for_file: deprecated_member_use
import 'package:coffeeapp/screens/SplashScreen/splashscreen.dart';
import 'package:coffeeapp/screens/admin/analystpage.dart';
import 'package:coffeeapp/screens/admin/category_managementpage.dart';
import 'package:coffeeapp/screens/admin/order_managementpage.dart';
import 'package:coffeeapp/screens/admin/product_managementpage.dart';
import 'package:coffeeapp/screens/admin/revenue_dashboard.dart';
import 'package:coffeeapp/screens/admin/table_management.dart';
import 'package:coffeeapp/screens/admin/user_management.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class AdminWebDashboard extends StatefulWidget {
  const AdminWebDashboard({super.key});

  @override
  State<AdminWebDashboard> createState() => _AdminWebDashboardState();
}

class _AdminWebDashboardState extends State<AdminWebDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AnalystPage(),
    const RevenueDashboardPage(),
    const ProductManagementPage(),
    const CategoryManagementPage(),
    const OrderManagementPage(),
    const TableManagementPage(),
    const UserManagementPage(),
  ];

  final List<String> _titles = [
    "Biểu Đồ Doanh Thu",
    "Báo cáo Doanh thu",
    "Produce",
    "Category",
    "Order",
    "Table",
    "User",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), 
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(),

          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _titles[_selectedIndex],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D3748),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text("Hôm nay", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Dynamic Page Area
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _selectedIndex < _pages.length
                                  ? _pages[_selectedIndex]
                                  : const Center(child: Text("chưa có ")),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: SIDEBAR ---
  Widget _buildSidebar() {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(4, 0),
          )
        ],
      ),
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage("assets/logo.png"), 
                      fit: BoxFit.cover,
                    ),
                    color: AppColors.primary, 
                  ),
                  child: const Icon(Icons.coffee, color: Colors.white), 
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "COFFEE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      "Manager",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // User Profile Card (Mini)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/admin_avatar.png"), // Ảnh Admin
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Admin Name",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Super Admin",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionTitle("THỐNG KÊ"),
                _buildMenuItem(0, "Dashboard", Icons.analytics_outlined),
                _buildMenuItem(1, "Doanh thu", Icons.monetization_on_outlined),
                
                const SizedBox(height: 16),
                _buildSectionTitle("QUẢN LÝ"),
                _buildMenuItem(2, "Sản phẩm", Icons.coffee_outlined),
                _buildMenuItem(3, "Danh mục", Icons.category_outlined),
                _buildMenuItem(4, "Đơn hàng", Icons.receipt_long_outlined),
                _buildMenuItem(5, "Bàn & Khu vực", Icons.table_restaurant_outlined),
                _buildMenuItem(6, "Người dùng", Icons.people_outline),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildMenuItem(7, "Đăng xuất", Icons.logout_rounded, isLogout: true),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TOP HEADER ---
  Widget _buildTopHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Search Bar (Visual only)
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Tìm kiếm...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
          
          // Icons Actions
          _buildHeaderIconAction(Icons.notifications_none_rounded, hasBadge: true),
          const SizedBox(width: 16),
          _buildHeaderIconAction(Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildHeaderIconAction(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 22),
        ),
        if (hasBadge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon, {bool isLogout = false}) {
    final isSelected = _selectedIndex == index && !isLogout;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isLogout) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? Colors.white 
                      : (isLogout ? Colors.redAccent : Colors.grey.shade500),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : (isLogout ? Colors.redAccent : const Color(0xFF505050)),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (isSelected) const Spacer(),
                if (isSelected) 
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 12)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
