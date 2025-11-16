import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomMethod/executeratingdisplay.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Product/product_detail.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductcardCategorymain extends StatefulWidget {
  late bool isDark;
  final int index;
  final Product product;
  ProductcardCategorymain({
    super.key,
    required this.product,
    required this.isDark,
    required this.index,
  });

  @override
  State<ProductcardCategorymain> createState() =>
      _ProductcardCategorymainState();
}

class _ProductcardCategorymainState extends State<ProductcardCategorymain> {
  var format = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.product.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          textAlign: TextAlign.left,
                          widget.product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Executeratingdisplay(rate: widget.product.rating),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.product.reviewCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${format.format(widget.product.price)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
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
                              .amount += cartItem
                              .amount;
                          if (GlobalData.cartItemList
                                  .firstWhere(
                                    (element) =>
                                        element.productName
                                                .trim()
                                                .toLowerCase() ==
                                            cartItem.product.name
                                                .trim()
                                                .toLowerCase() &&
                                        element.size == cartItem.size,
                                  )
                                  .amount >
                              10) {
                            GlobalData.cartItemList
                                    .firstWhere(
                                      (element) =>
                                          element.productName
                                                  .trim()
                                                  .toLowerCase() ==
                                              cartItem.product.name
                                                  .trim()
                                                  .toLowerCase() &&
                                          element.size == cartItem.size,
                                    )
                                    .amount =
                                10;
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
