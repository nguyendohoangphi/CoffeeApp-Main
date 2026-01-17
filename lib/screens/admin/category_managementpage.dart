import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/categoryproduct.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/screens/admin/addCategorypage.dart';
import 'package:coffeeapp/screens/admin/editcategorypage.dart';
import 'package:flutter/material.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  late List<CategoryProduct> categories = [];
  late List<CategoryProduct> filteredCategories = [];
  late Future<void> _loadDataFuture;
  final TextEditingController _searchController = TextEditingController();

  Future<void> LoadData() async {
    categories = await FirebaseDBManager.categoryProductService.getCategoryProductList();
    filteredCategories = categories;
  }

  Future<void> _deleteCategory(String id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa danh mục này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
        await FirebaseDBManager.categoryProductService.deleteCategoryProduct(id);
        setState(() {
          categories.removeWhere((c) => c.id == id);
          _filterCategories(_searchController.text);
        });
    }
  }

  void _navigateToEdit(CategoryProduct category) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCategoryPage(category: category)),
    );
    if (updated != null) {
      int index = categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        await FirebaseDBManager.categoryProductService.updateCategoryProduct(categories[index]);
        setState(() {
          categories[index] = updated;
           _filterCategories(_searchController.text);
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
      await FirebaseDBManager.categoryProductService.createCategoryProduct(newCategory);
      setState(() {
        categories.add(newCategory);
        _filterCategories(_searchController.text);
      });
    }
  }

  void _filterCategories(String query) {
    setState(() {
      filteredCategories = categories.where((cat) {
        return cat.displayName.toLowerCase().contains(query.toLowerCase()) || 
               cat.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
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
                const Text("Quản lý danh mục", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                     SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm danh mục...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        onChanged: _filterCategories,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _navigateToAdd,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Thêm mới", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
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
                } else if (filteredCategories.isEmpty) {
                   return const Center(child: Text("Chưa có danh mục nào"));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.asset(
                                cat.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
                              ),
                            ),
                          ),
                           Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(enumToString(cat.name), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _navigateToEdit(cat),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCategory(cat.id),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
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
