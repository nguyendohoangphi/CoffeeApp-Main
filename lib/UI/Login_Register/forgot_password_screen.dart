import 'package:flutter/material.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      appBar: AppBar(
        title: const Text("Khôi phục mật khẩu"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Nhập email để nhận liên kết đặt lại mật khẩu",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _email,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Email đăng ký tài khoản",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF424242),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (_email.text.trim().isEmpty) {
                  _showMessage("Vui lòng nhập email");
                  return;
                }

                final msg = await FirebaseDBManager.authService
                    .sendResetPassword(_email.text.trim());

                _showMessage(msg);
              },
              child: const Text(
                "Gửi email khôi phục",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
