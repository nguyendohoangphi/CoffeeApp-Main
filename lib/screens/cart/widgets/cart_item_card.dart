// ignore_for_file: deprecated_member_use

import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.format,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
    required this.getSizeString,
  });

  final CartItem item;
  final NumberFormat format;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String Function(SizeOption) getSizeString;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
       // horizontal: 20 // Removed as it is handled by the parent list padding usually
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20), // More rounded
        boxShadow: [
          AppColors.getShadow(isDark),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Product Image
            Hero(
              tag: 'product_${item.product.name}_${item.size}_cart', // Unique tag if possible
              child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  item.product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: isDark ? AppColors.backgroundDark : Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 2. Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ) ?? TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getSizeString(item.size),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${format.format(item.product.price)} đ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Quantity Controls
          const SizedBox(width: 8),
          Container(
             decoration: BoxDecoration(
               color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey[50], 
               borderRadius: BorderRadius.circular(12)
             ),
             padding: const EdgeInsets.symmetric(vertical: 4),
             child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuantityBtn(Icons.add, onIncrement, isDark, color: AppColors.success),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${item.amount}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                ),
                _buildQuantityBtn(Icons.remove, onDecrement, isDark, color: AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
         child: Icon(
           icon, 
           size: 20, 
           color: color ?? (isDark ? AppColors.textMainDark : AppColors.textMainLight)
         ),
      ),
    );
  }
}
