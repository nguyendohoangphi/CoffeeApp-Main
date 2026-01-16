// File: lib/UI/Login_Register/forgot_password_screen.dart

// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AppTheme {
  static const Color primary = Color(0xFFB2640A); 
  static const backgroundLight = Color(0xFFF8F7F5); 
  static const textMain = Color(0xFF1C150D); 
  static const textSub = Color(0xFF9C7649); 
  static const borderLight = Color(0xFFE8DCCE); 
  static const white = Colors.white;
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  bool _isLoading = false;

  void _showMessage(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : AppTheme.primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _handleSendResetLink() async {
    if (_email.text.trim().isEmpty) {
      _showMessage("Vui lòng nhập email của bạn");
      return;
    }

    setState(() => _isLoading = true);
    final msg = await FirebaseDBManager.authService.sendResetPassword(_email.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (msg == "OK") {
      _showMessage("Đã gửi liên kết khôi phục đến email của bạn!", isError: false);
      Navigator.pop(context); 
    } else {
      _showMessage(msg);
    }
  }
  // -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroHeader(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Texts
                      const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Enter your registered email below to receive password reset instructions.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSub,
                          fontSize: 14,
                          height: 1.5, // leading-relaxed
                        ),
                      ),

                      const SizedBox(height: 32),

                     
                      _ModernTextField(
                        hint: "Email Address",
                        icon: Symbols.mail,
                        controller: _email,
                      ),

                      const SizedBox(height: 24),

                      // Send Button
                      _ActionButton(
                        text: "SEND LINK",
                        onPressed: _handleSendResetLink,
                      ),

                      const SizedBox(height: 40),

                     
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Remember your password? ",
                            style: TextStyle(color: AppTheme.textMain, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Lottie.asset('assets/background/loading.json', width: 150, height: 150),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeroHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background
        Container(
          height: 320, // Aspect ratio ~4/3
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)), 
            image: DecorationImage(
              image: AssetImage('assets/background/login_hero.jpg'), 
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.backgroundLight.withOpacity(0.0),
                  AppTheme.backgroundLight.withOpacity(0.4),
                  AppTheme.backgroundLight,
                ],
              ),
            ),
          ),
        ),

        // Custom Back Button (Top Left) 
        Positioned(
          top: 50,
          left: 24,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // backdrop-blur-md
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.3), // bg-white/30
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textMain, size: 20),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),

        // Logo & Title 
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              Transform.rotate(
                angle: 3 * math.pi / 180, 
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  // Icon lock_reset như HTML
                  child: const Icon(Symbols.lock_reset, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PhINoM',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'RECOVERY', 
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- REUSABLE WIDGETS (Same as Login Screen) ---

class _ModernTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  const _ModernTextField({
    required this.hint, 
    required this.icon, 
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(999), // Pill shape
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textMain),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textSub.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: AppTheme.textSub),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          elevation: 8,
          shadowColor: AppTheme.primary.withOpacity(0.3),
          shape: const StadiumBorder(), // Pill shape
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
