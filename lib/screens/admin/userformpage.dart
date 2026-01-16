import 'package:coffeeapp/models/userdetail.dart';
import 'package:flutter/material.dart';

class UserFormPage extends StatefulWidget {
  final UserDetail? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _photoURLController = TextEditingController();
  final _rankController = TextEditingController();
  final _pointController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email;
      _passwordController.text = widget.user!.password ?? '';
      _photoURLController.text = widget.user!.photoURL;
      _rankController.text = widget.user!.rank;
      _pointController.text = widget.user!.point.toString();
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newUser = UserDetail(
        uid: widget.user?.uid ?? "",           // thêm uid vào UserDetail
        username: _usernameController.text,
        email: _emailController.text,
       // password: _passwordController.text,
        photoURL: _photoURLController.text,
        rank: _rankController.text,
        point: int.tryParse(_pointController.text) ?? 0,
        role: "user",
      );

      Navigator.pop(context, newUser);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _photoURLController.dispose();
    _rankController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa người dùng" : "Thêm người dùng"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // USERNAME
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (value) =>
                value!.isEmpty ? "Không để trống" : null,
              ),

              // EMAIL
              TextFormField(
                controller: _emailController,
                readOnly: isEdit,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value!.isEmpty ? "Không để trống" : null,
              ),

              // PASSWORD
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                validator: (value) =>
                value!.isEmpty ? "Không để trống" : null,
              ),

              // PHOTO URL
              TextFormField(
                controller: _photoURLController,
                decoration:
                const InputDecoration(labelText: 'Ảnh đại diện (URL hoặc asset)'),
              ),

              // RANK
              TextFormField(
                controller: _rankController,
                decoration: const InputDecoration(labelText: 'Hạng'),
              ),

              // POINT
              TextFormField(
                controller: _pointController,
                decoration: const InputDecoration(labelText: 'Điểm'),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? "Cập nhật" : "Thêm mới"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
