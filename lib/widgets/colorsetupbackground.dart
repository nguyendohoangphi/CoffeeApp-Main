import 'dart:ui';

class ColorSetupBackground {
  // Màu cho Dark Mode (ấm, đậm)
  static final primaryColorsDark = const [
    Color(0xFF3E2723), // Deep dark brown (Cà phê đen rang đậm)
    Color(0xFF4E342E), // Espresso nâu
    Color(0xFF1B1B1B), // Near black
  ];
  static final secondaryColorsDark = const [
    Color(0xFF5D4037), // Brown sâu
    Color(0xFF2E2E2E), // Charcoal grey
    Color(0xFF3E3E3E), // Smoke grey
  ];

  // Màu cho Light Mode (ấm, sáng, tươi)
  static final primaryColorsLight = const [
    Color(0xFFEFEBE9), // Café sữa nền sáng (light latte)
    Color(0xFFD7CCC8), // Mocha nhạt
    Color(0xFFBCAAA4), // Nâu kem nhạt
  ];
  static final secondaryColorsLight = const [
    Color(0xFFEFEBE9), // Matching background
    Color(0xFFF3E5F5), // Hơi ánh tím sữa (nhẹ)
    Color(0xFFFFF3E0), // Cam sữa rất nhạt (gợi caramel)
  ];
}
