import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coffeeapp/UI/Login_Register/coffeeloginregisterscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _version = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadVersion();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    // Điều hướng sau 3 giây
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CoffeeLoginRegisterScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = 'v${info.version}');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient nền
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4E342E), // Nâu cà phê
                  Color(0xFFD7CCC8), // Kem latte
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Hiệu ứng mờ overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),

          // Nội dung trung tâm
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo hoặc animation
                Lottie.asset(
                  'assets/background/coffee_animation.json',
                  width: 160,
                  height: 160,
                ),

                const SizedBox(height: 20),

                const Text(
                  "☕ PhiNom Coffee",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  "Coffee crafted with love.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 30),

                // Loading animation
                Lottie.asset(
                  'assets/background/loading.json',
                  width: 120,
                  height: 120,
                ),

                const SizedBox(height: 10),

                // Version
                Text(
                  _version,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
