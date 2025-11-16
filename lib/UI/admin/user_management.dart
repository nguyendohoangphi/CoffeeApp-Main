import 'dart:ui';

import 'package:coffeeapp/Entity/userdetail.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/admin/UserFormPage.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late List<UserDetail> users = [];

  late Future<void> _loadDataFuture;
  late List<UserDetail> filteredUsers = [];
  Future<void> LoadData() async {
    users = await FirebaseDBManager.authService.getAllUsers();
    filteredUsers = searchText.isEmpty
        ? users
        : users
              .where(
                (u) =>
                    u.displayName.toLowerCase().contains(
                      searchText.toLowerCase(),
                    ) ||
                    u.email.toLowerCase().contains(searchText.toLowerCase()),
              )
              .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = LoadData();
  }

  String searchText = "";

  Future<void> _deleteUser(String email) async {
    setState(() {
      users.removeWhere((user) => user.email == email);
    });
    await FirebaseDBManager.authService.deleteUserByEmail(email);
  }

  void _navigateToAdd() async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserFormPage()),
    );
    if (newUser != null) {
      setState(() => users.add(newUser));
      await FirebaseDBManager.authService.registerWithEmail(user: newUser);
    }
  }

  void _navigateToEdit(UserDetail user) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
    );
    if (updatedUser != null) {
      final index = users.indexWhere((u) => u.email == updatedUser.email);

      setState(() {
        if (index != -1) users[index] = updatedUser;
      });
      await FirebaseDBManager.authService.updateUserPointAndRank(
        users[index].email,
        users[index].point,
        users[index].rank,
      );
      await FirebaseDBManager.authService.updateUserPasswordInFirestore(
        users[index].email,
        users[index].password,
      );
    }
  }

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
              onChanged: (value) => setState(() => searchText = value),
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
                  key: Key(user.email),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteUser(user.email),
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
                    title: Text(user.displayName),
                    subtitle: Text('${user.email} - ${user.rank}'),
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
