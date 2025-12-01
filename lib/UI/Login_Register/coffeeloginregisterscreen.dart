import 'dart:ui';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/Transition/menunavigationbar_admin.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:coffeeapp/UI/Login_Register/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';


class CoffeeLoginRegisterScreen extends StatefulWidget {
  const CoffeeLoginRegisterScreen({super.key});

  @override
  State<CoffeeLoginRegisterScreen> createState() =>
      _CoffeeLoginRegisterScreenState();
}

class _CoffeeLoginRegisterScreenState extends State<CoffeeLoginRegisterScreen> {

//bool isLoading = false;


Future<void> _resetFirebaseAuthSession() async {
  try {
    await FirebaseAuth.instance.signOut(); // Đảm bảo signOut hoàn tất
    await Future.delayed(const Duration(milliseconds: 300)); // Chờ Firebase reset cache
    debugPrint("✅ Firebase session reset thành công");
  } catch (e) {
    debugPrint("⚠️ Lỗi reset Firebase session: $e");
  }
}


 // late VideoPlayerController _controller;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Login fields
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  // Register fields
  final _registerUsername = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();



@override
void initState() {
  super.initState();

  // Đảm bảo reset session Firebase trước khi build UI
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint(" Đã xoá session Firebase trước khi load login");
    } catch (e) {
      debugPrint(" Lỗi reset Firebase session: $e");
    }
  });

//  _controller = VideoPlayerController.asset("assets/video/PhiNomcoffeeIntro.mp4")
//    ..initialize().then((_) {
//      setState(() {});
//      _controller.setLooping(true);
//      _controller.setVolume(0);
//      _controller.play();
//    });
}



  @override
  void dispose() {
  //  _controller.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      //  if (_controller.value.isInitialized)
      //    Positioned.fill(
      //      child: FittedBox(
      //        fit: BoxFit.cover,
      //        child: SizedBox(
      //          width: _controller.value.size.width,
      //          height: _controller.value.size.height,
      //          child: VideoPlayer(_controller),
      //        ),
      //      ),
      //    ),
    Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E2723), Color(0xFF6D4C41)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ),

        // Glass overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text(
                    '☕ PhiNom Coffee',
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  _currentPage == 0
                      ? '👉 Lướt sang trái để đăng ký'
                      : '👈 Lướt sang phải để đăng nhập',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= LOGIN =================
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _glassField(_loginEmail, "Email", Icons.email_outlined),
          const SizedBox(height: 16),
          _glassField(_loginPassword, "Mật khẩu", Icons.lock_outline, obscure: true),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text(
                "Quên mật khẩu?",
                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(height: 30),

          
_gradientButton("Đăng nhập", () async {
  if (_loginEmail.text.isEmpty || _loginPassword.text.isEmpty) {
    if (!mounted) return;
    _showMessage("Vui lòng nhập email và mật khẩu");
    return;
  }

  // ✅ Reset session Firebase cũ
  try {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 300));
  } catch (e) {
    debugPrint("⚠️ Lỗi khi reset session: $e");
  }

  final result = await FirebaseDBManager.authService.login(
    email: _loginEmail.text.trim(),
    password: _loginPassword.text.trim(),
  );

  if (result == "OK") {
    try {
      final profile = await FirebaseDBManager.authService.getProfile();
      if (profile == null) {
        if (!mounted) return;
        _showMessage("Không thể lấy thông tin người dùng!");
        return;
      }

      GlobalData.userDetail = profile;

      // ⚡ Không dùng SnackBar trực tiếp – vì context có thể bị dispose
      if (!mounted) return;

      // ✅ Dùng addPostFrameCallback để show SnackBar an toàn sau khi build xong
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng nhập thành công!")),
          );
        }
      });

      // ✅ Chờ 1 chút rồi điều hướng – tránh conflict context
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      // ✅ Điều hướng bằng context hiện tại (đã kiểm tra)
      final navigator = Navigator.of(context);
      if (GlobalData.userDetail.role == "admin") {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MenuNavigationbarAdmin()),
          (route) => false,
        );
      } else {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MenuNavigationBar(isDark: false, selectedIndex: 0),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy profile hoặc điều hướng: $e");
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng nhập thất bại, vui lòng thử lại.")),
          );
        });
      }
    }
  } else {
    if (mounted) _showMessage(result ?? "Đăng nhập thất bại");
  }
}),


        ],
      ),
    );
  }

  // ================= REGISTER =================
  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _glassField(_registerUsername, "Tên đăng nhập", Icons.person_outline),
          const SizedBox(height: 16),
          _glassField(_registerEmail, "Email", Icons.email_outlined),
          const SizedBox(height: 16),
          _glassField(_registerPassword, "Mật khẩu", Icons.lock_outline, obscure: true),
          const SizedBox(height: 16),
          _glassField(_registerConfirm, "Xác nhận mật khẩu", Icons.lock_outline, obscure: true),
          const SizedBox(height: 30),

          _gradientButton("Đăng ký", () async {
            if (_registerUsername.text.isEmpty ||
                _registerEmail.text.isEmpty ||
                _registerPassword.text.isEmpty ||
                _registerConfirm.text.isEmpty) {
              _showMessage("Vui lòng điền đầy đủ thông tin");
              return;
            }

            if (_registerPassword.text != _registerConfirm.text) {
              _showMessage("Mật khẩu không khớp");
              return;
            }

            final result = await FirebaseDBManager.authService.register(
              username: _registerUsername.text.trim(),
              email: _registerEmail.text.trim(),
              password: _registerPassword.text.trim(),
            );

            if (result == "OK") {
              _showMessage("Đăng ký thành công!");
              _pageController.animateToPage(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            } else {
              _showMessage(result!);
            }
          }),
        ],
      ),
    );
  }

  // ================= COMPONENTS =================
  Widget _gradientButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC107), Color(0xFF6D4C41)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassField(TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
