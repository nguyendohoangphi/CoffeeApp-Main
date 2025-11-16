import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';

class EditCategoryPage extends StatefulWidget {
  final CategoryProduct category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.category.displayName,
    );
    _imageUrlController = TextEditingController(text: widget.category.imageUrl);
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final updatedCategory = CategoryProduct(
        id: widget.category.id,
        createDate: widget.category.createDate,
        name: widget.category.name, // Không được thay đổi
        imageUrl: _imageUrlController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      Navigator.pop(context, updatedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa danh mục')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: enumToString(widget.category.name),
                decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                readOnly: true,
              ),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Không được bỏ trống' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL hình ảnh'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Không được bỏ trống' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveCategory,
                child: const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
