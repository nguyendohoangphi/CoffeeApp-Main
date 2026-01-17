// ignore_for_file: prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';
import 'package:coffeeapp/utils/executeratingdisplay.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/screens/Product/product_detail.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ProductcardRecommended extends StatefulWidget {
  final bool isDark;
  final int index;
  final Product product;
  final VoidCallback? onFavoriteChanged;

  ProductcardRecommended({
    super.key,
    required this.product,
    required this.isDark,
    required this.index,
    this.onFavoriteChanged,
  });

  @override
  State<ProductcardRecommended> createState() => _ProductcardRecommendedState();
}

class _ProductcardRecommendedState extends State<ProductcardRecommended> {
  final format = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final cardColor = widget.isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subTimeColor = widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              isDark: widget.isDark,
              index: 0,
              product: widget.product,
              onFavoriteChanged: widget.onFavoriteChanged,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             AppColors.getShadow(widget.isDark),
          ],
        ),
        child: Row(
          children: [
            // Image container with Hero animation
            Hero(
              tag: 'product_img_${widget.product.name}_${widget.index}',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildProductImage(widget.product.imageUrl),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                    ) ?? TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Executeratingdisplay(rate: widget.product.rating),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '(${widget.product.reviewCount} đánh giá)',
                          style: TextStyle(
                            fontSize: 12,
                            color: subTimeColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: format.format(widget.product.price),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text: ' đ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary.withOpacity(0.8),
                              ),
                            ),
                          ]
                        )
                      ),
                      
                      // Quick Add Button
                      InkWell(
                        onTap: _addToCart,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  void _addToCart() {
    setState(() {
      CartItem cartItem = CartItem(
        productName: widget.product.name,
        amount: 1,
        size: SizeOption.Small,
        idOrder: '',
        product: widget.product,
      );

      var existingItem = GlobalData.cartItemList.indexWhere((element) =>
          element.productName.trim().toLowerCase() == cartItem.productName.trim().toLowerCase() &&
          element.size == cartItem.size);

      if (existingItem != -1) {
         if(GlobalData.cartItemList[existingItem].amount < 10){
            GlobalData.cartItemList[existingItem].amount++;
         }
      } else {
        cartItem.id = (GlobalData.cartItemList.length + 1).toString();
        GlobalData.cartItemList.add(cartItem);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm ${widget.product.name} vào giỏ hàng"),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
    });
  }
}
