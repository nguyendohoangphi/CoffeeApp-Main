import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  late List<CategoryProduct> categoryProducts;

  Future<void> LoadData() async {
    categoryProducts = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      if (categoryProducts
          .where(
            (element) =>
                element.name.toLowerCase().trim() ==
                _nameController.text.toLowerCase().trim(),
          )
          .isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loại nước uống này đã tồn tại')),
        );
        return;
      }
      String newId = 'cat';
      if (categoryProducts.isEmpty) {
        newId += '1';
      } else {
        int i = 1;
        while (true) {
          if (categoryProducts
              .where((element) => int.parse(element.id.split('cat')[1]) == i)
              .isEmpty) {
            break;
          }
          i++;
        }
        newId += i.toString();
      }

      final newCategory = CategoryProduct(
        id: newId,
        createDate: DateTime.now().toIso8601String(),
        name: _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );
      await FirebaseDBManager.categoryProductService.createCategoryProduct(
        newCategory,
      );
      Navigator.pop(context, newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm danh mục sản phẩm')),
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (context, asyncSnapshot) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên thể loại',
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Không được bỏ trống'
                        : null,
                  ),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên hiển thị',
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Không được bỏ trống'
                        : null,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL hình ảnh',
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Không được bỏ trống'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: const Text('Lưu'),
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
