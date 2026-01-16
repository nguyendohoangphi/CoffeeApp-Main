// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:coffeeapp/utils/executeratingdisplay.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/cartitem.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/screens/Product/product_detail.dart';
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

    // if (widget.product.reviewCount < 61) {
    //   return const SizedBox.shrink(); 
    // }

    final maxWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark
              ? [Colors.grey.shade800, Colors.grey.shade700]
              : [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth - 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh sản phẩm
                GestureDetector(
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.product.imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Phần giữa: tên + rating + giá
                Expanded(
                  child: GestureDetector(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên sản phẩm (1 dòng, ellipsis)
                        Text(
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Rating + review
                        Row(
                          children: [
                            Executeratingdisplay(rate: widget.product.rating),
                            const SizedBox(width: 4),
                            // Text(
                            //   '(${widget.product.reviewCount})',
                            //   style: const TextStyle(
                            //     fontSize: 12,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${format.format(widget.product.price)} đ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // +
                Center(
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      maxWidth: 40,
                      minHeight: 40,
                      maxHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        CartItem cartItem = CartItem(
                          productName: widget.product.name,
                          amount: 1,
                          size: SizeOption.Small,
                          idOrder: '',
                          product: widget.product,
                        );

                        int id = 0;
                        while (GlobalData.cartItemList
                            .where(
                              (element) =>
                                  element.productName.trim().toLowerCase() ==
                                      cartItem.product.name
                                          .trim()
                                          .toLowerCase() &&
                                  element.size == cartItem.size &&
                                  element.id == id.toString(),
                            )
                            .isNotEmpty) {
                          id++;
                        }

                        cartItem.id = id.toString();

                        if (GlobalData.cartItemList
                            .where(
                              (element) =>
                                  element.productName.trim().toLowerCase() ==
                                      cartItem.product.name
                                          .trim()
                                          .toLowerCase() &&
                                  element.size == cartItem.size,
                            )
                            .isNotEmpty) {
                          GlobalData.cartItemList
                              .firstWhere(
                                (element) =>
                                    element.productName.trim().toLowerCase() ==
                                        cartItem.product.name
                                            .trim()
                                            .toLowerCase() &&
                                    element.size == cartItem.size,
                              )
                              .amount += cartItem.amount;

                          if (GlobalData.cartItemList
                                  .firstWhere(
                                    (element) =>
                                        element.productName.trim().toLowerCase() ==
                                        cartItem.product.name.trim().toLowerCase() &&
                                        element.size == cartItem.size,
                                  )
                                  .amount >
                              10) {
                            GlobalData.cartItemList
                                .firstWhere(
                                  (element) =>
                                      element.productName.trim().toLowerCase() ==
                                          cartItem.product.name
                                              .trim()
                                              .toLowerCase() &&
                                      element.size == cartItem.size,
                                )
                                .amount = 10;
                          }
                        } else {
                          GlobalData.cartItemList.add(cartItem);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.yellow,
                      size: 24.0,
                      semanticLabel: 'Thêm vào giỏ hàng',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
