import 'dart:ui';
import 'package:coffeeapp/models/productfavourite.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:intl/intl.dart';

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

  final Map<SizeOption, String> sizes = {
    SizeOption.Small: 'S',
    SizeOption.Medium: 'M',
    SizeOption.Large: 'L',
  };
  late SizeOption currentSize;
  late double basePrice;
  double get currentPrice {
    switch (currentSize) {
      case SizeOption.Small: return basePrice;
      case SizeOption.Medium: return basePrice * 1.5;
      case SizeOption.Large: return basePrice * 2;
    }
  }

  bool isFavorite = false;

  // Theme Helpers
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get cardColor => widget.isDark ? AppColors.cardDark : Colors.white;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
  Color get subTextColor => widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

  @override
  void initState() {
    super.initState();
    currentSize = SizeOption.Small;
    basePrice = widget.product.price;
    _loadFavouriteData();
  }

  Future<void> _loadFavouriteData() async {
    if (GlobalData.userDetail.email.isEmpty) {
      if(mounted) setState(() => isFavorite = false);
      return;
    }
    // Simple fetch without blocking UI too much
    try {
      productFavouriteList = await FirebaseDBManager.favouriteService.getFavouritesByEmail(GlobalData.userDetail.email);
      if(mounted) {
        setState(() {
          isFavorite = productFavouriteList.any((e) => e.productName.trim().toLowerCase() == widget.product.name.trim().toLowerCase());
        });
      }
    } catch(e) {
      debugPrint("Error loading favorite: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    if (GlobalData.userDetail.email.isEmpty) {
      _showSnackBar('Bạn cần đăng nhập để sử dụng tính năng này', isError: true);
      return;
    }

    try {
      // Optimistic update
      setState(() => isFavorite = !isFavorite);
      
      await FirebaseDBManager.favouriteService.toggleFavourite(GlobalData.userDetail.email, widget.product.name);
      await _loadFavouriteData(); // Sync exact state
      widget.onFavoriteChanged?.call();

    } catch (e) {
      setState(() => isFavorite = !isFavorite); // Revert on error
      _showSnackBar('Đã xảy ra lỗi. Vui lòng thử lại.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildBody(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)), // Space for bottom bar
            ],
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          )
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: Center(
        child: _buildGlassBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Center(
          child: _buildGlassBtn(
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? Colors.redAccent : textColor,
            onTap: _toggleFavorite,
          ),
        ),
        const SizedBox(width: 20),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_image_${widget.product.name}_${widget.index}', // Ensure tag matches source
          child: Stack(
            fit: StackFit.expand,
            children: [
             widget.product.imageUrl.startsWith('http')
                  ? Image.network(widget.product.imageUrl, fit: BoxFit.cover)
                  : Image.asset(widget.product.imageUrl, fit: BoxFit.cover),
              
              // Gradient Overlay for better text readability if needed or just style
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black12,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.3],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBtn({required IconData icon, Color? color, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.8),
            boxShadow: [
              if (!widget.isDark)
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
            ]
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Icon(icon, color: color ?? textColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        transform: Matrix4.translationValues(0, -20, 0), // Pull up to overlap image
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         if (widget.product.type.isNotEmpty) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              widget.product.type.toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        Text(
                          widget.product.name,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),
                  ),
                  _buildRatingBadge(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              Text(
                widget.product.description,
                style: TextStyle(color: subTextColor, fontSize: 15, height: 1.6),
              ),
              
              const SizedBox(height: 24),
              
              Text("Size", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              Row(
                children: sizes.entries.map((entry) {
                  bool isSelected = currentSize == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => currentSize = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 16),
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (widget.isDark ? Colors.grey[700]! : Colors.grey[300]!),
                          width: 1.5
                        ),
                         boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? Colors.white : subTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            widget.product.rating.toStringAsFixed(1),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(
            ' (${widget.product.reviewCount})',
            style: TextStyle(fontSize: 12, color: subTextColor),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return ClipRRect(
       // Improve blur effect integration
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5)
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: TextStyle(color: subTextColor, fontSize: 14)),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${format.format(currentPrice * amountBuy)} đ',
                      key: ValueKey(currentPrice),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
        
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined),
                    SizedBox(width: 10),
                    Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
      Product productChosen = Product(
        createDate: widget.product.createDate,
        name: widget.product.name,
        imageUrl: widget.product.imageUrl,
        description: widget.product.description,
        rating: widget.product.rating,
        reviewCount: widget.product.reviewCount,
        price: currentPrice,
        type: widget.product.type,
      );

      CartItem cartItem = CartItem(
        productName: widget.product.name,
        amount: amountBuy,
        size: currentSize,
        idOrder: '',
        product: productChosen,
      );

      // Add to cart logic
      var existingItem = GlobalData.cartItemList.where((e) =>
          e.productName.trim().toLowerCase() == cartItem.product.name.trim().toLowerCase() && 
          e.size == cartItem.size);

      if (existingItem.isNotEmpty) {
        var item = existingItem.first;
        if (item.amount + cartItem.amount > max) {
          item.amount = max;
        } else {
          item.amount += cartItem.amount;
        }
      } else {
        // Simple ID generation for demo
        cartItem.id = (GlobalData.cartItemList.length + 1).toString();
        GlobalData.cartItemList.add(cartItem);
      }
      
      _showSnackBar('Đã thêm ${cartItem.amount} x ${cartItem.productName} vào giỏ!');
      Navigator.pop(context);
  }
}
