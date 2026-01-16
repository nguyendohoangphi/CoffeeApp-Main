// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  // 1. Tông màu chính (Brand Colors)
  static const Color primary = Color(0xFFFF8A00); // Cam ấm (Nút chính, Icon active)
  static const Color secondary = Color(0xFF4E342E); // Nâu cà phê đậm (Text tiêu đề, Background tối)
  static const Color accent = Color(0xFF81C784); // Xanh lá nhẹ (Badge, Success, Vegetarian)

  // 2. Tông màu nền (Backgrounds)
  static const Color backgroundLight = Color(0xFFFFF9F0); // Kem sữa (Nền sáng chủ đạo)
  static const Color backgroundDark = Color(0xFF2C2C2C); // Xám đen ấm (Nền tối chủ đạo)
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF3B3D45); // Màu card chế độ tối (như bạn thích ở Profile)

  // 3. Tông màu chữ (Text)
  static const Color textMainLight = Color(0xFF2D2D2D); // Chữ đen trên nền sáng
  static const Color textSubLight = Color(0xFF757575); // Chữ phụ
  static const Color textMainDark = Colors.white; // Chữ trắng trên nền tối
  static const Color textSubDark = Colors.white70;

  static const Color coffeeBlack = Color(0xFF000000); // Nền đen như repo
  static const Color coffeeOrange = Color(0xFFFFA500); // Accent orange for text/button
  static final Color coffeeWhiteOpacity = Colors.white.withOpacity(0.1);
  static final Color overlayOpacity = Colors.black.withOpacity(0.7);
  
  // 4. Gradient (Cho đẹp, hiện đại)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9E44), Color(0xFFFF8A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
}
