// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  // 1. Tông màu chính (Brand Colors)
  static const Color primary = Color(0xFFFF8A00); 
  static const Color primaryDark = Color(0xFFFF9E44); // Cam sáng hơn cho Dark mode

  // 2. Màu nền (Backgrounds) - Clean & Minimalist
  static const Color backgroundLight = Color(0xFFF8F9FA); // Trắng khói, hiện đại hơn màu kem cũ
  static const Color backgroundDark = Color(0xFF1A1D1F); // Đen sâu, ít ám xanh/nâu hơn
  
  // 3. Surface (Card, Dialog, Sheet)
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF272B30); // Xám đậm, phân tách rõ với nền

  // 4. Text Colors - High Contrast
  static const Color textMainLight = Color(0xFF1A1D1F); // Đen than (Soft Black)
  static const Color textMainDark = Color(0xFFFFFFFF);
  
  static const Color textSubLight = Color(0xFF6F767E); // Xám trung tính
  static const Color textSubDark = Color(0xFF9A9FA5);

  // 5. Functional Colors
  static const Color success = Color(0xFF83BF6E);
  static const Color error = Color(0xFFFF6A55);
  static const Color info = Color(0xFF2A85FF);

  // 6. Gradients & Shadows
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9E44), Color(0xFFFF8A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF1A1D1F).withOpacity(0.1),
    blurRadius: 20,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static BoxShadow darkShadow = BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  // 7. Legacy Mapping 
  static const Color secondary = Color(0xFF4E342E); 
  static const Color accent = success; 
  
  // Helper để lấy màu shadow theo theme
  static BoxShadow getShadow(bool isDark) => isDark ? darkShadow : softShadow;

  // ===== Legacy aliases =====
static const Color primaryColor = primary;

static const Color backgroundColor = backgroundLight;

static const Color surfaceColor = cardLight;

static const Color textMain = textMainLight;

}
