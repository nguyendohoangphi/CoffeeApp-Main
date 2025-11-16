import 'dart:ui';

import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/admin/addCategorypage.dart';
import 'package:coffeeapp/UI/admin/editcategorypage.dart';
import 'package:flutter/material.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  late List<CategoryProduct> categories = [];
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = LoadData();
  }

  Future<void> LoadData() async {
    categories = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();
  }

  Future<void> _deleteCategory(String id) async {
    setState(() {
      categories.removeWhere((c) => c.id == id);
    });

    await FirebaseDBManager.categoryProductService.deleteCategoryProduct(id);
  }

  void _navigateToEdit(CategoryProduct category) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(category: category),
      ),
    );
    if (updated != null) {
      int index = categories.indexWhere((c) => c.id == updated.id);

      setState(() {
        if (index != -1) categories[index] = updated;
      });

      if (index != -1) {
        await FirebaseDBManager.categoryProductService.updateCategoryProduct(
          categories[index],
        );
        setState(() {
          _loadDataFuture = LoadData();
        });
      }
    }
  }

  void _navigateToAdd() async {
    final newCategory = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategoryPage()),
    );
    if (newCategory != null) {
      setState(() {
        categories.add(newCategory);
      });

      await FirebaseDBManager.categoryProductService.createCategoryProduct(
        newCategory,
      );

      setState(() {
        _loadDataFuture = LoadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh mục sản phẩm')),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, asyncSnapshot) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Dismissible(
                  key: Key(cat.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteCategory(cat.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(cat.imageUrl),
                    ),
                    title: Text(cat.displayName),
                    subtitle: Text(enumToString(cat.name)),
                    onTap: () => _navigateToEdit(cat),
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
