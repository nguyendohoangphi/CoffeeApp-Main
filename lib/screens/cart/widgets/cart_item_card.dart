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
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: isDark ? AppColors.backgroundDark : Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getSizeString(item.size),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${format.format(item.product.price)} đ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle),
                color: AppColors.accent,
                iconSize: 28,
              ),
              Text(
                '${item.amount}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? AppColors.textMainDark : AppColors.textMainLight,
                ),
              ),
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle),
                color: isDark ? AppColors.textSubDark : Colors.redAccent,
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
