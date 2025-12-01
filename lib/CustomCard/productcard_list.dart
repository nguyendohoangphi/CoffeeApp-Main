import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomMethod/executeratingdisplay.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Product/product_detail.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductcardList extends StatefulWidget {
  late bool isDark;
  final int index;
  final Product product;

  ProductcardList({
    super.key,
    required this.product,
    required this.isDark,
    required this.index,
  });

  @override
  State<ProductcardList> createState() => _ProductcardListState();
}

class _ProductcardListState extends State<ProductcardList> {
  var format = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetail(
                        isDark: widget.isDark,
                        index: widget.index,
                        product: widget.product,
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

              /// PRODUCT INFO
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          isDark: widget.isDark,
                          index: widget.index,
                          product: widget.product,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

              /// ADD TO CART BUTTON
              Center(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      // thêm nhanh size SMALL
                      CartItem cartItem = CartItem(
                        productName: widget.product.name,
                        amount: 1,
                        size: SizeOption.Small,
                        idOrder: '',
                        product: Product(
                          createDate: widget.product.createDate,
                          name: widget.product.name,
                          imageUrl: widget.product.imageUrl,
                          description: widget.product.description,
                          rating: widget.product.rating,
                          reviewCount: widget.product.reviewCount,
                          price: widget.product.price,
                          type: widget.product.type,
                        ),
                      );

                      // tránh trùng ID
                      int id = 0;
                      while (GlobalData.cartItemList.any(
                        (e) =>
                            e.productName.toLowerCase() ==
                                cartItem.productName.toLowerCase() &&
                            e.size == cartItem.size &&
                            e.id == id.toString(),
                      )) {
                        id++;
                      }
                      cartItem.id = id.toString();

                      // nếu có rồi → cộng số lượng
                      var exist = GlobalData.cartItemList.where(
                        (e) =>
                            e.productName.toLowerCase() ==
                                cartItem.productName.toLowerCase() &&
                            e.size == cartItem.size,
                      );

                      if (exist.isNotEmpty) {
                        exist.first.amount++;
                        if (exist.first.amount > 10) exist.first.amount = 10;
                      } else {
                        GlobalData.cartItemList.add(cartItem);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Đã thêm ${widget.product.name}"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.orange,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
