import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/tablestatus.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/screens/admin/TableFormPage.dart';
import 'package:flutter/material.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  late List<TableStatus> tables = [];
  late Future<void> _loadDataFuture;

  Future<void> LoadData() async {
    tables = await FirebaseDBManager.tableStatusService.getTableStatusList();
    // Sort by name if needed
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
  }

  Future<void> _deleteTable(String id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bàn này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
        await FirebaseDBManager.tableStatusService.deleteTable(id);
        setState(() {
          tables.removeWhere((t) => t.id == id);
        });
    }
  }

  void _navigateToEdit(TableStatus table) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TableFormPage(table: table)),
    );
    if (updated != null) {
      int index = tables.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
         await FirebaseDBManager.tableStatusService.updateBookingStatus(
          tables[index].id,
          tables[index].isBooked,
        );
        setState(() {
          tables[index] = updated;
        });
      }
    }
  }

  void _navigateToAdd() async {
    final newTable = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TableFormPage()),
    );
    if (newTable != null) {
      await FirebaseDBManager.tableStatusService.createTable(newTable);
      setState(() {
        tables.add(newTable);
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
                const Text("Quản lý bàn & Khu vực", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _navigateToAdd,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Thêm bàn mới", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                } else if (tables.isEmpty) {
                   return const Center(child: Text("Chưa có bàn nào"));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // More items per row for tables
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    final isBooked = table.isBooked;
                    return InkWell(
                      onTap: () => _navigateToEdit(table),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBooked ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isBooked ? Colors.red.shade200 : Colors.green.shade200, width: 2),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.table_restaurant_rounded, 
                                    size: 40, 
                                    color: isBooked ? Colors.red : Colors.green
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    table.nameTable,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isBooked ? Colors.red.shade800 : Colors.green.shade800,
                                    ),
                                  ),
                                  Text(
                                    isBooked ? "Đã đặt" : "Trống",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isBooked ? Colors.red.shade600 : Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => _deleteTable(table.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 14, color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
