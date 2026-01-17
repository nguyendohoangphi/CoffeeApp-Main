// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:coffeeapp/utils/executeratingdisplay.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/screens/Product/product_detail.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ProductcardCategorymain extends StatefulWidget {
  late bool isDark;
  final int index;
  final Product product;
  final VoidCallback? onFavoriteChanged;
  
  ProductcardCategorymain({
    super.key,
    required this.product,
    required this.isDark,
    required this.index,
    this.onFavoriteChanged,
  });

  @override
  State<ProductcardCategorymain> createState() =>
      _ProductcardCategorymainState();
}

class _ProductcardCategorymainState extends State<ProductcardCategorymain> {
  var format = NumberFormat.decimalPattern("vi_VN");

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subColor = widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;

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
        width: 170, // Optimized width
        margin: const EdgeInsets.only(right: 16, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             AppColors.getShadow(widget.isDark),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Stack(
              children: [
                Hero(
                  tag: 'product_cat_${widget.product.name}_${widget.index}',
                  child: Container(
                    height: 150, 
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.asset(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Rating Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      backgroundBlendMode: BlendMode.darken
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.product.rating.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.product.reviewCount} đánh giá',
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${format.format(widget.product.price)} đ',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        InkWell(
                          onTap: _addToCart,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
