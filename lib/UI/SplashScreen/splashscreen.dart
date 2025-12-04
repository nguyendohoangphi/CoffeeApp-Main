import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:coffeeapp/UI/Login_Register/coffeeloginregisterscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  late final AudioPlayer _audioPlayer;
  late final AnimationController _animationController;
  late final AnimationController _fadeOutController;

  @override
  void initState() {
    super.initState();

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
      // màu nền
      backgroundColor: const Color(0xFFFFF4E0), 
      
      body: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0)
            .animate(CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Transform.scale(
                scale: 1.3, // size
                child: Lottie.asset(
                  'assets/background/coffee_pour.json',
                  controller: _animationController,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _animationController
                      ..duration = composition.duration
                      ..forward();

                    final totalMs = composition.duration.inMilliseconds;

                    // Fade-out âm thanh
                    _audioPlayer.onPositionChanged.listen((pos) {
                      if (pos.inMilliseconds >= totalMs - 600) {
                        final remaining =
                            totalMs - pos.inMilliseconds.toDouble().clamp(0, 600);
                        _audioPlayer.setVolume(remaining / 600);
                      }
                    });

                    // Bắt đầu fade-out màn hình
                    Future.delayed(Duration(milliseconds: totalMs - 600), () {
                      _fadeOutController.forward();
                    });

                    // Chuyển màn hình
                    Future.delayed(Duration(milliseconds: totalMs - 200), () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const CoffeeLoginRegisterScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
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

              
            ],
          ),
        ),
      ),
    );
  }
}