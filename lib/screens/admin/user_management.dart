import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/models/userdetail.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/screens/admin/UserFormPage.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late List<UserDetail> users = [];
  late List<UserDetail> filteredUsers = [];
  late Future<void> _loadDataFuture;

  String searchText = "";

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
  }

  // ------------------------------ LOAD USER DATA ----------------------------------
  Future<void> LoadData() async {
    users = await FirebaseDBManager.authService.getAllUsers();

    filteredUsers = searchText.isEmpty
        ? users
        : users
        .where((u) =>
    u.username.toLowerCase().contains(searchText.toLowerCase()) ||
        u.email.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  // ------------------------------ DELETE USER ----------------------------------
  Future<void> _deleteUser(UserDetail user) async {
    // Xóa Firestore theo UID
    await FirebaseFirestore.instance
        .collection("UserDetail")
        .doc(user.uid)
        .delete();

    // Xóa khỏi danh sách
    setState(() {
      users.removeWhere((u) => u.uid == user.uid);
      filteredUsers.removeWhere((u) => u.uid == user.uid);
    });
  }

  // ------------------------------ ADD USER ----------------------------------
  void _navigateToAdd() async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserFormPage()),
    );

    if (newUser != null) {
      // Gọi AuthService.register
      await FirebaseDBManager.authService.register(
        username: newUser.username,
        email: newUser.email,
        password: newUser.password!,
      );

      // Reload data
      setState(() {
        _loadDataFuture = LoadData();
      });
    }
  }

  // ------------------------------ EDIT USER ----------------------------------
  void _navigateToEdit(UserDetail user) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
    );

    if (updatedUser != null) {
      final index = users.indexWhere((u) => u.uid == updatedUser.uid);

      if (index != -1) {
        setState(() {
          users[index] = updatedUser;
        });

        // Update rank + point
        await FirebaseDBManager.authService.updateUserPointAndRank(
          updatedUser.uid,
          updatedUser.point,
          updatedUser.rank,
        );

        setState(() {
          _loadDataFuture = LoadData();
        });
      }
    }
  }

  // ------------------------------ UI BUILD ----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý người dùng"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Tìm kiếm...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  filteredUsers = users
                      .where(
                        (u) =>
                    u.username
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                        u.email
                            .toLowerCase()
                            .contains(value.toLowerCase()),
                  )
                      .toList();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, asyncSnapshot) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Dismissible(
                  key: Key(user.uid),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteUser(user),
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(user.photoURL),
                    ),
                    title: Text(user.username),
                    subtitle: Text("${user.email} - ${user.rank}"),
                    onTap: () => _navigateToEdit(user),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
