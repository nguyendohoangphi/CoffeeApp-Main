import 'dart:ui';
import 'package:coffeeapp/CustomCard/productcard_list.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/constants/app_colors.dart'; 
import 'package:flutter/material.dart';

class ProductList extends StatefulWidget {
  final String nameProduct;
  final String productType;
  final bool isDark;
  final int index;

  const ProductList({
    super.key,
    required this.nameProduct,
    required this.productType,
    required this.isDark,
    required this.index,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late List<Product> productList = [];
  bool isLoading = true;

  // Theme Helpers
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Product> fetchedList = [];
    if (widget.nameProduct.isNotEmpty) {
      // Chế độ Tìm kiếm
      fetchedList = await FirebaseDBManager.productService.searchProductsByName(widget.nameProduct);
    } else {
      // Chế độ Danh mục
      fetchedList = await FirebaseDBManager.productService.getProductsByType(widget.productType);
    }

    if (mounted) {
      setState(() {
        productList = fetchedList;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xác định tiêu đề trang
    String title = widget.nameProduct.isNotEmpty 
        ? "Kết quả: \"${widget.nameProduct}\"" 
        : widget.productType;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : productList.isEmpty
              ? _buildEmptyState()
              : SafeArea(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 cột
                        childAspectRatio: 0.75, // Tỷ lệ thẻ (cao hơn rộng)
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        return ProductcardList(
                          product: productList[index],
                          isDark: widget.isDark,
                          index: index,
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy sản phẩm nào",
            style: TextStyle(
              color: Colors.grey[600], 
              fontSize: 18, 
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}