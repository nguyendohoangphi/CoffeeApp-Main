// File: lib/UI/SplashScreen/splashscreen.dart
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
  //  await _audioPlayer.play(AssetSource('audio/coffee_pour_sound.mp3'));
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor: Colors.white, 
      
      body: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0)
            .animate(CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut)),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              Transform.scale(
                scale: 0.5, 
                child: Lottie.asset(
                  'assets/background/coffee_pour.json',
                  controller: _animationController,
                  fit: BoxFit.contain,
                  width: screenWidth, 
                  onLoaded: (composition) {
                    _animationController
                      ..duration = composition.duration
                      ..forward();

                    final totalMs = composition.duration.inMilliseconds;

                    // Logic chuyển màn hình
                    Future.delayed(Duration(milliseconds: totalMs - 200), () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const CoffeeLoginRegisterScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
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