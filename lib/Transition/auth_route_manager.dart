import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/Transition/menunavigationbar_admin.dart';
import 'package:coffeeapp/UI/admin/admin_web_dashboard.dart';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:flutter/material.dart';

class AuthRouteManager {
  /// Hàm điều hướng chính sau khi đăng nhập thành công
  static void goToHome(BuildContext context, String role) {
    // Xóa hết các trang cũ trong stack để không back lại màn hình login được
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => _getDestination(role)),
      (Route<dynamic> route) => false,
    );
  }

  /// Logic quyết định màn hình đích
  static Widget _getDestination(String role) {
    // 1. Nếu là Admin
    if (role == 'admin') {
      if (kIsWeb) {
        // Admin + Web -> Vào Dashboard Web
        return const AdminWebDashboard();
      } else {
        // Admin + Mobile -> Vào giao diện quản lý cũ trên Mobile
        return const MenuNavigationbarAdmin();
      }
    }
    
    // 2. Nếu là User (hoặc các role khác) -> Vào App bán hàng bình thường
    return const MenuNavigationBar(isDark: false, selectedIndex: 0);
  }
}