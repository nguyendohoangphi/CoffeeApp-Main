import 'dart:ui';

import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/admin/TableFormPage.dart';
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = LoadData();
  }

  Future<void> _deleteTable(String id) async {
    setState(() {
      tables.removeWhere((t) => t.id == id);
    });
    await FirebaseDBManager.tableStatusService.deleteTable(id);
  }

  void _navigateToEdit(TableStatus table) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TableFormPage(table: table)),
    );
    if (updated != null) {
      int index = tables.indexWhere((t) => t.id == updated.id);
      setState(() {
        if (index != -1) tables[index] = updated;
      });
      await FirebaseDBManager.tableStatusService.updateBookingStatus(
        tables[index].id,
        tables[index].isBooked,
      );
    }
  }

  void _navigateToAdd() async {
    final newTable = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TableFormPage()),
    );
    if (newTable != null) {
      setState(() {
        tables.add(newTable);
      });
      await FirebaseDBManager.tableStatusService.createTable(newTable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý bàn')),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, asyncSnapshot) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: ListView.builder(
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                return Dismissible(
                  key: Key(table.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteTable(table.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: Icon(
                      table.isBooked ? Icons.event_busy : Icons.event_available,
                    ),
                    title: Text(table.nameTable),
                    subtitle: Text(table.isBooked ? 'Đã đặt' : 'Chưa đặt'),
                    onTap: () => _navigateToEdit(table),
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
