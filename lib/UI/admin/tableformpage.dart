import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';

class TableFormPage extends StatefulWidget {
  final TableStatus? table;

  const TableFormPage({super.key, this.table});

  @override
  State<TableFormPage> createState() => _TableFormPageState();
}

class _TableFormPageState extends State<TableFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isBooked = false;

  late List<TableStatus> tables = [];

  late Future<void> _loadDataFuture;

  Future<void> LoadData() async {
    tables = await FirebaseDBManager.tableStatusService.getTableStatusList();
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
    if (widget.table != null) {
      _nameController.text = widget.table!.nameTable;
      _isBooked = widget.table!.isBooked;
    }
  }

  void _save(bool isEdit) {
    if (_formKey.currentState!.validate()) {
      String idTable = 'T';
      if (!isEdit) {
        if (tables
            .where(
              (element) =>
                  element.nameTable.toLowerCase().trim() ==
                  _nameController.text.toLowerCase().trim(),
            )
            .isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tên bàn này đã tồn tại')));
          return;
        }
        String newID = '';

        if (tables.isNotEmpty) {
          int i = 1;
          while (true) {
            newID = '';
            if (i < 10) {
              newID = '${idTable}0${i.toString()}';
            } else {
              newID = '$idTable${i.toString()}';
            }
            if (tables
                .where(
                  (element) =>
                      element.id.toLowerCase().trim() ==
                      newID.toLowerCase().trim(),
                )
                .isEmpty) {
              break;
            }
            i++;
          }
          idTable = newID;
        } else {
          idTable += '01';
        }
      }
      final newTable = TableStatus(
        id: isEdit ? widget.table!.id : idTable,
        createDate:
            widget.table?.createDate ?? DateTime.now().toIso8601String(),
        nameTable: _nameController.text,
        isBooked: _isBooked,
      );

      Navigator.pop(context, newTable);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.table != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Chỉnh sửa bàn' : 'Thêm bàn')),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, asyncSnapshot) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    readOnly: isEdit, // Không cho đổi tên khi sửa
                    decoration: const InputDecoration(labelText: 'Tên bàn'),
                    validator: (value) =>
                        value!.isEmpty ? 'Không được để trống' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Đã đặt'),
                    value: _isBooked,
                    onChanged: (value) {
                      setState(() => _isBooked = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _save(isEdit),
                    child: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
