import 'dart:ui';

import 'package:coffeeapp/CustomMethod/generateCouponCode.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/userdetail.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Transition/menunavigationbar_admin.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:video_player/video_player.dart';

class CoffeeLoginRegisterScreen extends StatefulWidget {
  const CoffeeLoginRegisterScreen({super.key});

  @override
  State<CoffeeLoginRegisterScreen> createState() =>
      _CoffeeLoginRegisterScreenState();
}

class _CoffeeLoginRegisterScreenState extends State<CoffeeLoginRegisterScreen> {
  late VideoPlayerController _controller;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _loginUsername = TextEditingController();
  final _loginPassword = TextEditingController();

  final _registerUsername = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();

  final LinearGradient coffeeGradient = LinearGradient(
    colors: [
      Color.fromARGB(170, 75, 56, 50), // dark roast with 66% opacity
      Color.fromARGB(170, 133, 68, 66), // reddish coffee
      Color.fromARGB(170, 217, 176, 140), // caramel tone
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  late List<UserDetail> userDetailList = [];
  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset(
            "assets/video/istockphoto-1439347335-640_adpp_is.mp4",
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.setLooping(true);
            _controller.setVolume(0);
            _controller.play();
          });
  }

  Future<void> LoadData() async {
    userDetailList = await FirebaseDBManager.authService.getAllUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void clearLoginFields() {
    _loginUsername.clear();
    _loginPassword.clear();
  }

  void clearRegisterFields() {
    _registerUsername.clear();
    _registerPassword.clear();
    _registerConfirm.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background video
        if (_controller.value.isInitialized)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

        /// Foreground Content
        Scaffold(
          backgroundColor: Colors.black.withOpacity(0.3), // translucent overlay
          body: FutureBuilder<void>(
            future: LoadData(),
            builder: (context, asyncSnapshot) {
              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: const Text(
                        '☕ Cà phê Đậu Chill',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            if (_currentPage != index) {
                              if (index == 0) {
                                LoadData();
                                clearRegisterFields(); // Swiped to Login
                              } else {
                                LoadData();
                                clearLoginFields(); // Swiped to Register
                              }
                              _currentPage = index;
                            }
                          },
                          children: [_buildLoginForm(), _buildRegisterForm()],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _currentPage == 0
                            ? 'Lướt sang trái để đăng ký →'
                            : '← Lướt sang phải để đăng nhập',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildField(_loginUsername, 'Tên đăng nhập'),
          SizedBox(height: 12),
          _buildField(_loginPassword, 'Mật khẩu', obscure: true),
          SizedBox(height: 24),
          coffeeButton('Đăng nhập', () async {
            if (_loginUsername.text.isEmpty || _loginPassword.text.isEmpty) {
              showMessage("Vui lòng điền cả tên người dùng và mật khẩu");
              return;
            }

            if (userDetailList
                .where((element) => element.email == _loginUsername.text)
                .isEmpty) {
              showMessage("Tài khoản này chưa từng tồn tại");
              return;
            } else {
              if (userDetailList
                      .firstWhere(
                        (element) => element.email == _loginUsername.text,
                      )
                      .password !=
                  _loginPassword.text) {
                showMessage("Sai mật khẩu");
                return;
              }
            }
            GlobalData.userDetail = (await FirebaseDBManager.authService
                .getUserDetail(_loginUsername.text))!;

            showMessage("Đăng nhập thành công");
            _loginUsername.text = '';
            _loginPassword.text = '';
            Navigator.pop(context);
            if (GlobalData.userDetail.rank == "Rank Admin") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuNavigationbarAdmin(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MenuNavigationBar(isDark: false, selectedIndex: 0),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildField(_registerUsername, 'Tên đăng nhập'),
          SizedBox(height: 12),
          _buildField(_registerPassword, 'Mật khẩu', obscure: true),
          SizedBox(height: 12),
          _buildField(_registerConfirm, 'Xác nhận Mật khẩu', obscure: true),
          SizedBox(height: 24),
          coffeeButton('Đăng ký', () async {
            if (_registerUsername.text.isEmpty ||
                _registerPassword.text.isEmpty ||
                _registerConfirm.text.isEmpty) {
              showMessage("Vui lòng điền hết chỗ trống còn lại.");
              return;
            }

            if (_registerPassword.text != _registerConfirm.text) {
              showMessage("Mật khẩu không khớp.");
              return;
            }

            if (userDetailList
                .where((element) => element.email == _registerUsername.text)
                .isNotEmpty) {
              showMessage("Tài khoản này đã tồn tại");
              return;
            }

            await FirebaseDBManager.authService.registerWithEmail(
              user: UserDetail(
                displayName: _registerUsername.text.split('@')[0],
                email: _registerUsername.text,
                password: _registerPassword.text,
                photoURL: 'assets/images/drink/user.png',
                rank: 'Hạng đồng',
                point: 0,
              ),
            );
            await FirebaseDBManager.couponService.addSingleCouponCode(
              _registerUsername.text,
              generateCouponCode(),
            );
            showMessage("Đăng ký thành công");
            _registerUsername.text = '';
            _registerPassword.text = '';
            _registerConfirm.text = '';

            userDetailList = await FirebaseDBManager.authService.getAllUsers();
          }),
        ],
      ),
    );
  }

  Widget coffeeButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: coffeeGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.4).withAlpha(170),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: coffeeGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3).withAlpha(170),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 1)),
    );
  }
}
