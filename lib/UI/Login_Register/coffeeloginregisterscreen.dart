import 'package:flutter/material.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/UI/Login_Register/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/Transition/menunavigationbar_admin.dart';

class CoffeeLoginRegisterScreen extends StatefulWidget {
  const CoffeeLoginRegisterScreen({super.key});

  @override
  State<CoffeeLoginRegisterScreen> createState() =>
      _CoffeeLoginRegisterScreenState();
}

class _CoffeeLoginRegisterScreenState extends State<CoffeeLoginRegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // TEXT CONTROLLERS
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _registerUsername = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();

  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;
  bool _showRegisterConfirm = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await FirebaseAuth.instance.signOut();
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }



        @override
        Widget build(BuildContext context) {
          // Lấy chiều cao bàn phím
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

          return Scaffold(
            backgroundColor: Colors.white,
            // QUAN TRỌNG: Giữ nguyên khung hình, không để bàn phím đẩy layout gốc
            resizeToAvoidBottomInset: false, 

            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Stack(
                children: [
                  // ================= LỚP 1: BACKGROUND CỐ ĐỊNH =================
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/background_coffee.jpg", 
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.3)), // Màu tối nhẹ
                  ),

                  // ================= LỚP 2: NỘI DUNG FORM  =================
                  Positioned.fill(
                    child: SingleChildScrollView(
                      // Cho phép nảy nhẹ kiểu iOS
                      physics: const BouncingScrollPhysics(), 
                      child: Padding(
                        // Padding bottom bằng chiều cao bàn phím để đẩy nội dung lên vừa đủ
                        padding: EdgeInsets.only(bottom: bottomPadding), 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                            // LOGO
                            // Image.asset(
                            //   "assets/images/logo.png",
                            //    height: 100, // Kích thước cố định sang trọng
                            // ),
                            
                            const SizedBox(height: 10),
                            
                            
                            // const Text(
                            //   "Coffee Phinom",
                            //   style: TextStyle(
                            //     fontSize: 28, 
                            //     fontWeight: FontWeight.bold, 
                            //     color: Colors.white, 
                            //     fontFamily: 'Montserrat' 
                            //   ),
                            // ),

                            const SizedBox(height: 30),

                            // KHỐI FORM 
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  )
                                ]
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _currentPage == 0
                                    ? _buildLoginForm()
                                    : _buildRegisterForm(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // TEXT CHUYỂN TRANG
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == 0
                                      ? "Bạn chưa có tài khoản? "
                                      : "Đã có tài khoản? ",
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentPage = _currentPage == 0 ? 1 : 0;
                                    });
                                  },
                                  child: Text(
                                    _currentPage == 0 ? "Đăng ký ngay" : "Đăng nhập",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 194, 103), // Màu cam Coffee
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Khoảng cách dưới cùng để khi scroll không bị sát quá
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }



  // =====================================================================
  // LOGIN FORM 
  // =====================================================================
  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: [
          const SizedBox(height: 20),

          _shopeeTextField(
            hint: "Email address",
            icon: Icons.person_outline,
            controller: _loginEmail,
          ),
          const SizedBox(height: 25),

          _shopeePasswordField(
            hint: "Password",
            controller: _loginPassword,
            isVisible: _showLoginPassword,
            onToggle: () =>
                setState(() => _showLoginPassword = !_showLoginPassword),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: Text("Forgotten password?",
                  style: TextStyle(color: Colors.blue.shade600, fontSize: 14)),
            ),
          ),

          const SizedBox(height: 35),

          // LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // REGISTER FORM 
  // =====================================================================
  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: [
          const SizedBox(height: 20),

          _shopeeTextField(
            hint: "Name",
            icon: Icons.person_outline,
            controller: _registerUsername,
          ),
          const SizedBox(height: 20),

          _shopeeTextField(
            hint: "Email",
            icon: Icons.email_outlined,
            controller: _registerEmail,
          ),
          const SizedBox(height: 20),

          _shopeePasswordField(
            hint: "Password",
            controller: _registerPassword,
            isVisible: _showRegisterPassword,
            onToggle: () => setState(
                () => _showRegisterPassword = !_showRegisterPassword),
          ),
          const SizedBox(height: 20),

          _shopeePasswordField(
            hint: "Confirm password",
            controller: _registerConfirm,
            isVisible: _showRegisterConfirm,
            onToggle: () => setState(
                () => _showRegisterConfirm = !_showRegisterConfirm),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                "Create new account",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // ------------------------ Coffee STYLE FIELDS ------------------------
  // =====================================================================
          Widget _shopeeTextField({
              required String hint,
              required IconData icon,
              required TextEditingController controller,
          }) {
              return Column(
          children: [
                 Row(
                    children: [
                          Icon(icon, color: Colors.grey.shade600, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                              controller: controller,
                                    style: const TextStyle(  fontSize: 15,  color: Colors.black  ),
                                  decoration: InputDecoration(
                                  hintText: hint,
                                  hintStyle:
                                  TextStyle(color:Colors.grey.shade500, fontSize: 15),
                                  border: InputBorder.none,
                                  ),
                              ),
                          ),
                     ],
                 ),
          Container(height: 1, color: Colors.grey.shade300),
          ],
              ) ;
            }


  Widget _shopeePasswordField({
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !isVisible,
                style: const TextStyle(fontSize: 15, color: Colors.black),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
            )
          ],
        ),
        Container(height: 1, color: Colors.grey.shade300),
      ],
    );
  }

  // =====================================================================
  // LOGIC LOGIN / REGISTER 
  // =====================================================================

  Future<void> _handleLogin() async {
    if (_loginEmail.text.isEmpty || _loginPassword.text.isEmpty) {
      _showMessage("Vui lòng nhập email và mật khẩu");
      return;
    }

    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 300));

    final result = await FirebaseDBManager.authService.login(
      email: _loginEmail.text.trim(),
      password: _loginPassword.text.trim(),
    );

    if (result != "OK") {
      _showMessage(result ?? "Đăng nhập thất bại");
      return;
    }

    final profile = await FirebaseDBManager.authService.getProfile();
    if (profile == null) {
      _showMessage("Không thể lấy thông tin người dùng!");
      return;
    }

    GlobalData.userDetail = profile;

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => profile.role == "admin"
            ? MenuNavigationbarAdmin()
            : MenuNavigationBar(isDark: false, selectedIndex: 0),
      ),
      (route) => false,
    );
  }

  Future<void> _handleRegister() async {
    if (_registerUsername.text.isEmpty ||
        _registerEmail.text.isEmpty ||
        _registerPassword.text.isEmpty ||
        _registerConfirm.text.isEmpty) {
      _showMessage("Vui lòng nhập đầy đủ thông tin");
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
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    } else {
      _showMessage(result!);
    }
  }
}
