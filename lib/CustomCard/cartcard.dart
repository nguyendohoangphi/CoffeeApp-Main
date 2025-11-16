import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class Cartcard extends StatefulWidget {
  late CartItem cartItem;
  Cartcard({super.key, required this.cartItem});

  @override
  State<Cartcard> createState() => _CartcardState();
}

class _CartcardState extends State<Cartcard> {
  var format = NumberFormat("#,###", "vi_VN");
  int max = 10;
  int min = 0;
  // ignore: non_constant_identifier_names
  String GetSizeString(SizeOption size) {
    switch (size) {
      case SizeOption.Small:
        return "Nhỏ";
      case SizeOption.Medium:
        return "Vừa";
      case SizeOption.Large:
        return "Lớn";
    }
  }

  @override
  Widget build(BuildContext context) {
    Product productInfo =
        FirebaseDBManager.productService.getProductByName(
              widget.cartItem.productName,
            )
            as Product;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Image.asset(
            productInfo.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),

          const SizedBox(width: 12),

          // Name, Size, Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GetSizeString(widget.cartItem.size),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  productInfo.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${format.format(productInfo.price)} đ',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (widget.cartItem.amount > 1) {
                      widget.cartItem.amount--;
                    }
                  });
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.redAccent,
                iconSize: 24,
              ),
              Text(
                '${widget.cartItem.amount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (widget.cartItem.amount < max) widget.cartItem.amount++;
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.green,
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
