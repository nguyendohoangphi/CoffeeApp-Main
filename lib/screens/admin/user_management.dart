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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
  }

  Future<void> LoadData() async {
    users = await FirebaseDBManager.authService.getAllUsers();
    filteredUsers = users;
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((u) => 
        u.username.toLowerCase().contains(query.toLowerCase()) || 
        u.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _deleteUser(UserDetail user) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa người dùng ${user.username}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection("UserDetail").doc(user.uid).delete();
      setState(() {
        users.removeWhere((u) => u.uid == user.uid);
        _filterUsers(_searchController.text);
      });
    }
  }

  void _navigateToAdd() async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserFormPage()),
    );

    if (newUser != null) {
      await FirebaseDBManager.authService.register(
        username: newUser.username,
        email: newUser.email,
        password: newUser.password!,
      );
      setState(() {
        _loadDataFuture = LoadData();
      });
    }
  }

  void _navigateToEdit(UserDetail user) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
    );

    if (updatedUser != null) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
           // Header
           Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quản lý người dùng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm user...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        onChanged: _filterUsers,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _navigateToAdd,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Thêm mới", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (filteredUsers.isEmpty) {
                  return const Center(child: Text("Không tìm thấy người dùng nào"));
                }

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                        columns: const [
                          DataColumn(label: Text("Avatar")),
                          DataColumn(label: Text("Tên hiển thị", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Xếp hạng", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Điểm", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Hành động", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredUsers.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(CircleAvatar(
                                backgroundImage: AssetImage(user.photoURL.isNotEmpty ? user.photoURL : 'assets/default_avatar.png'),
                                radius: 18,
                              )),
                              DataCell(Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(user.email)),
                              DataCell(_buildRankBadge(user.rank)),
                              DataCell(Text(user.point.toString())),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                    onPressed: () => _navigateToEdit(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteUser(user),
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }

  Widget _buildRankBadge(String rank) {
    Color color = Colors.grey;
    if (rank.contains("Vàng")) color = Colors.orange;
    else if (rank.contains("Bạc")) color = Colors.grey;
    else if (rank.contains("Đồng")) color = Colors.brown;
    else if (rank.contains("Kim cương")) color = Colors.purpleAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(rank, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
