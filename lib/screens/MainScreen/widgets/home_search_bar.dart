// ignore_for_file: deprecated_member_use

import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
//import 'package:coffeeapp/models/product.dart';
import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final bool isDark;
  final Function(String) onProductSelected;

  const HomeSearchBar({
    super.key, 
    required this.isDark,
    required this.onProductSelected,
  });

  Widget _buildProductImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 45, height: 45, fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[200], width: 45, height: 45, child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey)),
      );
    } else {
      return Image.asset(
        url,
        width: 45, height: 45, fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[200], width: 45, height: 45, child: const Icon(Icons.image, size: 20, color: Colors.grey)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final Color textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [AppColors.getShadow(isDark)],
        ),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              hintText: "Tìm kiếm đồ uống yêu thích...",
              hintStyle: MaterialStateProperty.all(TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 14,
              )),
              textStyle: MaterialStateProperty.all(TextStyle(color: textColor)),
              surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
              leading: Icon(
                Icons.search_rounded, 
                color: isDark ? AppColors.primaryDark : AppColors.primary
              ),
              onTap: () => controller.openView(),
              onChanged: (_) => controller.openView(),
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                controller.closeView(value);
                onProductSelected(value.trim());
              },
            );
          },
          suggestionsBuilder: (context, controller) async {
            final keyword = controller.text.trim();
            final productSearchList = await FirebaseDBManager.productService.searchProductsByName(keyword);

            if (productSearchList.isEmpty) {
              return [
                 ListTile(
                  leading: const Icon(Icons.search_off_rounded, color: Colors.grey),
                  title: const Text("Không tìm thấy món nào"),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  tileColor: isDark ? AppColors.backgroundDark : Colors.white,
                ),
              ];
            }

            return productSearchList.map((product) {
              return ListTile(
                tileColor: isDark ? AppColors.backgroundDark : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 45,
                  height: 45,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200, 
                  ),
                  child: _buildProductImage(product.imageUrl),
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "${product.price} đ",
                  style: TextStyle(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  controller.closeView(product.name);
                  onProductSelected(product.name);
                },
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
