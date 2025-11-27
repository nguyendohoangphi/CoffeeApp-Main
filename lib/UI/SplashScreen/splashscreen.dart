import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:coffeeapp/UI/Login_Register/coffeeloginregisterscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String _version = '';
  late final AudioPlayer _audioPlayer;
  late final AnimationController _animationController;
  late final AnimationController _fadeOutController;

  @override
  void initState() {
    super.initState();
    _loadVersion();

    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(vsync: this);
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startSplashFlow());
  }

  Future<void> _startSplashFlow() async {
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource('audio/coffee_pour_sound.mp3'));
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = 'v${info.version}');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0)
            .animate(CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.3,
                child: Lottie.asset(
                  'assets/background/coffee_pour.json',
                  controller: _animationController,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _animationController
                      ..duration = composition.duration
                      ..forward();

                    final totalMs = composition.duration.inMilliseconds;

                    // fade-out nhẹ âm thanh
                    _audioPlayer.onPositionChanged.listen((pos) {
                      if (pos.inMilliseconds >= totalMs - 600) {
                        final remaining =
                            totalMs - pos.inMilliseconds.toDouble().clamp(0, 600);
                        _audioPlayer.setVolume(remaining / 600);
                      }
                    });

                    // ✅ Bắt đầu fade-out toàn màn hình sớm 0.6s
                    Future.delayed(Duration(milliseconds: totalMs - 600), () {
                      _fadeOutController.forward();
                    });

                    // ✅ Điều hướng sớm hơn 200ms để không khựng
                    Future.delayed(Duration(milliseconds: totalMs - 200), () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const CoffeeLoginRegisterScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut, // 🎨 fade-in mượt
                                ),
                                child: child,
                              ),
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "☕ PhiNom Coffee",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Coffee crafted with love.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _version,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
