import 'dart:ui';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';

class ProductDetail extends StatefulWidget {
  final int index;
  final bool isDark;
  final Product product;
  final VoidCallback? onFavoriteChanged;

  const ProductDetail({
    required this.index,
    required this.isDark,
    super.key,
    required this.product,
    this.onFavoriteChanged,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late List<ProductFavourite> productFavouriteList = [];
  var format = NumberFormat("#,###", "vi_VN");
  late int amountBuy = 1;
  final int max = 10;
  final int min = 1;

  final Map<SizeOption, String> sizes = {
    SizeOption.Small: 'S',
    SizeOption.Medium: 'M',
    SizeOption.Large: 'L',
  };
  late SizeOption currentSize;
  late double basePrice;
  late double priceUpdated;
  bool isFavorite = false;

  // Theme Helpers
  Color get backgroundColor => widget.isDark ? const Color(0xFF1A1D1F) : const Color(0xFFF7F8FA);
  Color get cardColor => widget.isDark ? const Color(0xFF252A32) : Colors.white;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
  Color get subTextColor => widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

  @override
  void initState() {
    super.initState();
    currentSize = SizeOption.Small;
    basePrice = widget.product.price;
    priceUpdated = widget.product.price;
    _loadFavouriteData();
  }

  Future<void> _loadFavouriteData() async {
    if (GlobalData.userDetail.email.isEmpty) {
      setState(() => isFavorite = false);
      return;
    }
    productFavouriteList = await FirebaseDBManager.favouriteService.getFavouritesByEmail(GlobalData.userDetail.email);
    setState(() {
      isFavorite = productFavouriteList.any((e) => e.productName.trim().toLowerCase() == widget.product.name.trim().toLowerCase());
    });
  }

  Future<void> _toggleFavorite() async {
    // Check if user is logged in
    if (GlobalData.userDetail.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để sử dụng tính năng này'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseDBManager.favouriteService.toggleFavourite(GlobalData.userDetail.email, widget.product.name);

      await _loadFavouriteData();

      widget.onFavoriteChanged?.call();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updatePrice() {
    switch (currentSize) {
      case SizeOption.Small:
        priceUpdated = basePrice;
        break;
      case SizeOption.Medium:
        priceUpdated = basePrice * 1.5;
        break;
      case SizeOption.Large:
        priceUpdated = basePrice * 2;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updatePrice();
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildProductInfo(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      pinned: true,
      backgroundColor: backgroundColor,
      elevation: 0.5,
      leading: Center(
        child: _buildCircleBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Center(
          child: _buildCircleBtn(
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? Colors.redAccent : textColor,
            onTap: _toggleFavorite,
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_image_${widget.product.name}_${widget.index}', // Unique tag
          child: Image.asset(
            widget.product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBtn({required IconData icon, Color? color, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(56),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.5),
          ),
          child: InkWell(
            onTap: onTap,
            child: Icon(icon, color: color ?? textColor, size: 20),
          ),
        ),
      ),
    );
  }

 SliverToBoxAdapter _buildProductInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.type.isNotEmpty) ...[
              Text(
                widget.product.type,
                style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            
            // Product Name
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
            ),

            if (widget.product.reviewCount >= 60) ...[
              const SizedBox(height: 16), 
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    widget.product.rating.toStringAsFixed(1),
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.product.reviewCount} reviews)',
                    style: TextStyle(color: subTextColor, fontSize: 16)
                  ),
                ],
              ),
              const SizedBox(height: 24), 
            ] else ...[
              const SizedBox(height: 16),
            ],

            // Description
            Text(
              "Mô tả",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product.description,
              style: TextStyle(color: subTextColor, fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Size Selection
            Text(
              "Kích thước",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: sizes.entries.map((entry) {
                bool isSelected = currentSize == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => currentSize = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    // Full width minus padding and spacing
                    width: (MediaQuery.of(context).size.width - 48 - 30) / 3, 
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : subTextColor.withOpacity(0.5), 
                        width: 1.5
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tổng giá', style: TextStyle(color: subTextColor, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${format.format(priceUpdated * amountBuy)} đ',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),

          // Add to cart button
          ElevatedButton(
            onPressed: () {
              // Same logic as before
              Product productChosen = Product(
                createDate: widget.product.createDate, name: widget.product.name, imageUrl: widget.product.imageUrl,
                description: widget.product.description, rating: widget.product.rating, reviewCount: widget.product.reviewCount,
                price: priceUpdated, type: widget.product.type,
              );
              CartItem cartItem = CartItem(
                productName: widget.product.name, amount: amountBuy, size: currentSize, idOrder: '', product: productChosen,
              );

              var existingItem = GlobalData.cartItemList.where((e) =>
                  e.productName.trim().toLowerCase() == cartItem.product.name.trim().toLowerCase() && e.size == cartItem.size);

              if (existingItem.isNotEmpty) {
                var item = existingItem.first;
                if (item.amount + cartItem.amount > max) {
                  item.amount = max;
                } else {
                  item.amount += cartItem.amount;
                }
              } else {
                int id = 0;
                while (GlobalData.cartItemList.any((e) => e.id == id.toString())) {
                  id++;
                }
                cartItem.id = id.toString();
                GlobalData.cartItemList.add(cartItem);
              }
              
              // Show a confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('Đã thêm ${cartItem.amount} x ${cartItem.productName} vào giỏ!'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate back to the previous screen
               Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_bag_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text("Thêm vào giỏ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}