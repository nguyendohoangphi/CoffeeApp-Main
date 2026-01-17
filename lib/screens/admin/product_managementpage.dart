import 'dart:ui';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/screens/admin/addeditproductpage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late List<Product> mockProducts = [];
  late List<Product> productSearchList = [];
  late Future<void> _loadDataFuture;
  final TextEditingController _searchController = TextEditingController();

  Future<void> LoadData() async {
    mockProducts = await FirebaseDBManager.productService.getProducts();
    productSearchList = mockProducts;
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
  }

  void _filterProducts(String query) {
    setState(() {
      productSearchList = mockProducts.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditProductPage()),
    );
    if (result == true) setState(() => _loadDataFuture = LoadData());
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditProductPage(product: product)),
    );
    if (result == true) setState(() => _loadDataFuture = LoadData());
  }

  Future<void> _deleteProduct(Product product) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa ${product.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseDBManager.productService.deleteProductByName(product.name);
      setState(() => _loadDataFuture = LoadData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");

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
                const Text("Quản lý sản phẩm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Tìm sản phẩm...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        onChanged: _filterProducts,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Thêm mới", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          // Grid Content
          Expanded(
            child: FutureBuilder(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (productSearchList.isEmpty) {
                  return const Center(child: Text("Không tìm thấy sản phẩm"));
                }

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: productSearchList.length,
                    itemBuilder: (context, index) {
                      final product = productSearchList[index];
                      return _buildProductCard(product, currencyFormat);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, NumberFormat format) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset( // Should be network if URL is http
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _editProduct(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteProduct(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.delete, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${format.format(product.price)} đ",
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
