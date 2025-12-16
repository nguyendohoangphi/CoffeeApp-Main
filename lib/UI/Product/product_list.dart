// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:coffeeapp/UI/Product/product_detail.dart'; 
import 'package:intl/intl.dart';

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
  Color get backgroundColor => widget.isDark ? const Color(0xFF1A1D1F) : const Color(0xFFF7F8FA);
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
  Color get cardColor => widget.isDark ? const Color(0xFF252A32) : Colors.white;
  Color get subTextColor => widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Add a small delay for smoother transition
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<Product> fetchedList = [];
    if (widget.nameProduct.isNotEmpty) {
      // Search mode
      fetchedList = await FirebaseDBManager.productService.searchProductsByName(widget.nameProduct);
    } else {
      // Category mode
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
    String title = widget.nameProduct.isNotEmpty
        ? 'Kết quả cho "${widget.nameProduct}"'
        : widget.productType;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: isLoading
            ? Center(key: const ValueKey('loading'), child: Lottie.asset('assets/background/loading.json', width: 150, height: 150))
            : productList.isEmpty
                ? _buildEmptyState()
                : _buildProductGrid(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/background/coffee_pour.json', width: 200, height: 200),
          const SizedBox(height: 20),
          Text(
            "Không có sản phẩm nào",
            style: TextStyle(
              color: subTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    var format = NumberFormat.decimalPattern("vi_VN");
    return SafeArea(
      key: const ValueKey('grid'),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7, // Adjust ratio for the new card design
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            // Add entrance animation for each card
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetail(
                              isDark: widget.isDark,
                              index: index,
                              product: product,
                            ),
                          ),
                        );
                      },
                      child: _buildModernProductCard(product, format),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernProductCard(Product product, NumberFormat format) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with rating
          Expanded(
            flex: 10,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(product.imageUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Product Info
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    Text(
                       '${format.format(product.price)} đ', 
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                       Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper for image loading, consistent with home screen
  Widget _buildProductImage(String url) {
    final errorWidget = Container(
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
    
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => errorWidget,
        loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator(
              strokeWidth: 2.0,
              value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
            ));
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => errorWidget,
      );
    }
  }
}