import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomMethod/executeratingdisplay.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductDetail extends StatefulWidget {
  late int index;
  late bool isDark;
  final Product product;
  ProductDetail({
    required this.index,
    required this.isDark,
    super.key,
    required this.product,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late List<ProductFavourite> productFavouriteList = [];

  Future<void> LoadData() async {
    productFavouriteList = await FirebaseDBManager.favouriteService
        .getFavouritesByEmail(GlobalData.userDetail.email);
  }

  Future<void> AddOrRemove(Product productTarget) async {
    if (productFavouriteList
        .where((element) => element.productName == productTarget.name)
        .isEmpty) {
      await FirebaseDBManager.favouriteService.addFavourite(
        ProductFavourite(
          email: GlobalData.userDetail.email,
          productName: productTarget.name,
        ),
      );
    } else {
      await FirebaseDBManager.favouriteService.removeFavourite(
        GlobalData.userDetail.email,
        productTarget.name,
      );
    }
  }

  var format = NumberFormat("#,###", "vi_VN");
  late int indexSize = 0;
  late int amountBuy = 1;
  int max = 10;
  int min = 1;
  // ignore: non_constant_identifier_names
  double heightBtn_Bottom = 50;

  final Map<SizeOption, String> sizes = {
    SizeOption.Small: 'Nhỏ',
    SizeOption.Medium: 'Trung bình',
    SizeOption.Large: 'Lớn',
  };
  late SizeOption currentSize;
  late double basePrice;
  late double priceUpdated;
  @override
  void initState() {
    super.initState();
    currentSize = SizeOption.Small;
    basePrice = widget.product.price;
    priceUpdated = widget.product.price;
  }

  @override
  Widget build(BuildContext context) {
    switch (currentSize) {
      case SizeOption.Small:
        priceUpdated = basePrice;
        break;
      case SizeOption.Medium:
        priceUpdated = basePrice * 1.5;
      case SizeOption.Large:
        priceUpdated = basePrice * 2;
    }
    return Scaffold(
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topLeft,
        duration: const Duration(seconds: 6),
        primaryColors: widget.isDark
            ? ColorSetupBackground.primaryColorsDark
            : ColorSetupBackground.primaryColorsLight,
        secondaryColors: widget.isDark
            ? ColorSetupBackground.secondaryColorsDark
            : ColorSetupBackground.secondaryColorsLight,
        child: FutureBuilder<void>(
          future: LoadData(),
          builder: (context, asyncSnapshot) {
            return SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,

                    child: Stack(
                      children: [
                        /// Product Image (header)
                        Image.asset(
                          widget.product.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        /// Back Button on top
                        Positioned(
                          top:
                              MediaQuery.of(context).padding.top +
                              8, // Below status bar
                          left: 8,
                          child: CircleAvatar(
                            // ignore: deprecated_member_use
                            backgroundColor: Colors.black.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MenuNavigationBar(
                                      isDark: widget.isDark,
                                      selectedIndex: widget.index,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        /// Favourite button on top
                        Positioned(
                          top:
                              MediaQuery.of(context).padding.top +
                              8, // Below status bar
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                AddOrRemove(widget.product);
                                LoadData();
                              });
                            },
                            child: Icon(
                              productFavouriteList
                                      .where(
                                        (element) =>
                                            element.productName ==
                                            widget.product.name,
                                      )
                                      .isNotEmpty
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  productFavouriteList
                                      .where(
                                        (element) =>
                                            element.productName ==
                                            widget.product.name,
                                      )
                                      .isNotEmpty
                                  ? Colors.redAccent
                                  : Colors.grey,
                            ),
                          ),
                        ),

                        // Detail Product
                        Positioned(
                          top: 200,
                          left: 0,
                          right: 0,
                          child: SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.grey[800]
                                    : Colors.brown[400],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row 1: Name + Price
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${format.format(priceUpdated)} đ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Row 2: Product type
                                  Text(
                                    'Loại sản phẩm: ${widget.product.type}',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 94, 94, 94),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Row 3: Rating
                                  Executeratingdisplay(
                                    rate: widget.product.rating,
                                  ),
                                  const SizedBox(height: 12),

                                  // Row 4: Size title and options
                                  const Text(
                                    'Kích cỡ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  SizedBox(
                                    height: 28, // Give ListView some height
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: sizes.length,
                                      itemBuilder: (context, index) {
                                        final size = sizes.entries.elementAt(
                                          index,
                                        );
                                        return Container(
                                          width: 100,
                                          height: 28,
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                currentSize = size.key;
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  currentSize == size.key
                                                  ? const Color.fromARGB(
                                                      255,
                                                      241,
                                                      21,
                                                      106,
                                                    ).withOpacity(
                                                      0.6,
                                                    ) // Selected background
                                                  : const Color.fromARGB(
                                                      255,
                                                      160,
                                                      161,
                                                      161,
                                                    ).withOpacity(
                                                      0.4,
                                                    ), // Unselected background
                                              foregroundColor:
                                                  currentSize == size.key
                                                  ? const Color.fromARGB(
                                                      255,
                                                      235,
                                                      235,
                                                      235,
                                                    )
                                                  : const Color.fromARGB(
                                                      255,
                                                      128,
                                                      128,
                                                      128,
                                                    ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                side: const BorderSide(
                                                  color: Color.fromARGB(
                                                    255,
                                                    186,
                                                    82,
                                                    207,
                                                  ),
                                                ),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            child: Text(size.value),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Row 5: Description
                                  const Text(
                                    'Mô tả',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.product.description,
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        //Footer
                        Positioned(
                          bottom: 8,
                          right: 8,
                          left: 8,
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: heightBtn_Bottom,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: CircleAvatar(
                                  // ignore: deprecated_member_use
                                  backgroundColor: Colors.pink.withOpacity(0.5),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (amountBuy > min) amountBuy--;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                alignment: AlignmentDirectional.center,
                                width: 100,
                                height: heightBtn_Bottom,
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  amountBuy.toString(),
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(width: 10),
                              Container(
                                width: 50,
                                height: heightBtn_Bottom,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: CircleAvatar(
                                  // ignore: deprecated_member_use
                                  backgroundColor: Colors.pink.withOpacity(0.5),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (amountBuy < max) amountBuy++;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Spacer(flex: 1),

                              Container(
                                width: 100,
                                height: heightBtn_Bottom,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: IconButton(
                                    icon: Image.asset(
                                      'assets/video/icons8-add-shopping-cart.gif',
                                      fit: BoxFit.contain,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        Product productChosen = Product(
                                          createDate: widget.product.createDate,
                                          name: widget.product.name,
                                          imageUrl: widget.product.imageUrl,
                                          description:
                                              widget.product.description,
                                          rating: widget.product.rating,
                                          reviewCount:
                                              widget.product.reviewCount,
                                          price: priceUpdated,
                                          type: widget.product.type,
                                        );
                                        CartItem cartItem = CartItem(
                                          productName: widget.product.name,
                                          amount: amountBuy,
                                          size: currentSize,
                                          idOrder: '',
                                          product: productChosen,
                                        );

                                        int id = 0;
                                        while (GlobalData.cartItemList
                                            .where(
                                              (element) =>
                                                  element.productName
                                                          .trim()
                                                          .toLowerCase() ==
                                                      cartItem.product.name
                                                          .trim()
                                                          .toLowerCase() &&
                                                  element.size ==
                                                      cartItem.size &&
                                                  element.id == id.toString(),
                                            )
                                            .isNotEmpty) {
                                          id++;
                                        }

                                        cartItem.id = id.toString();

                                        if (GlobalData.cartItemList
                                            .where(
                                              (element) =>
                                                  element.productName
                                                          .trim()
                                                          .toLowerCase() ==
                                                      cartItem.productName
                                                          .trim()
                                                          .toLowerCase() &&
                                                  element.size == cartItem.size,
                                            )
                                            .isNotEmpty) {
                                          GlobalData.cartItemList
                                              .firstWhere(
                                                (element) =>
                                                    element.productName
                                                            .trim()
                                                            .toLowerCase() ==
                                                        cartItem.product.name
                                                            .trim()
                                                            .toLowerCase() &&
                                                    element.size ==
                                                        cartItem.size,
                                              )
                                              .amount += cartItem
                                              .amount;
                                          if (GlobalData.cartItemList
                                                  .firstWhere(
                                                    (element) =>
                                                        element.productName
                                                                .trim()
                                                                .toLowerCase() ==
                                                            cartItem
                                                                .product
                                                                .name
                                                                .trim()
                                                                .toLowerCase() &&
                                                        element.size ==
                                                            cartItem.size,
                                                  )
                                                  .amount >
                                              10) {
                                            GlobalData.cartItemList
                                                    .firstWhere(
                                                      (element) =>
                                                          element.productName
                                                                  .trim()
                                                                  .toLowerCase() ==
                                                              cartItem
                                                                  .product
                                                                  .name
                                                                  .trim()
                                                                  .toLowerCase() &&
                                                          element.size ==
                                                              cartItem.size,
                                                    )
                                                    .amount =
                                                10;
                                          }
                                        } else {
                                          GlobalData.cartItemList.add(cartItem);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),

                              Container(
                                width: 100,
                                height: heightBtn_Bottom,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: IconButton(
                                    icon: Image.asset(
                                      'assets/video/icons8-shopping-cart.gif',
                                      fit: BoxFit.contain,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        Product productChosen = Product(
                                          createDate: widget.product.createDate,
                                          name: widget.product.name,
                                          imageUrl: widget.product.imageUrl,
                                          description:
                                              widget.product.description,
                                          rating: widget.product.rating,
                                          reviewCount:
                                              widget.product.reviewCount,
                                          price: priceUpdated,
                                          type: widget.product.type,
                                        );
                                        CartItem cartItem = CartItem(
                                          productName: widget.product.name,
                                          amount: amountBuy,
                                          size: currentSize,
                                          idOrder: '',
                                          product: productChosen,
                                        );

                                        int id = 0;
                                        while (GlobalData.cartItemList
                                            .where(
                                              (element) =>
                                                  element.productName
                                                          .trim()
                                                          .toLowerCase() ==
                                                      cartItem.product.name
                                                          .trim()
                                                          .toLowerCase() &&
                                                  element.size ==
                                                      cartItem.size &&
                                                  element.id == id.toString(),
                                            )
                                            .isNotEmpty) {
                                          id++;
                                        }

                                        cartItem.id = id.toString();

                                        if (GlobalData.cartItemList
                                            .where(
                                              (element) =>
                                                  element.productName
                                                          .trim()
                                                          .toLowerCase() ==
                                                      cartItem.product.name
                                                          .trim()
                                                          .toLowerCase() &&
                                                  element.size == cartItem.size,
                                            )
                                            .isNotEmpty) {
                                          GlobalData.cartItemList
                                              .firstWhere(
                                                (element) =>
                                                    element.productName
                                                            .trim()
                                                            .toLowerCase() ==
                                                        cartItem.product.name
                                                            .trim()
                                                            .toLowerCase() &&
                                                    element.size ==
                                                        cartItem.size,
                                              )
                                              .amount += cartItem
                                              .amount;
                                          if (GlobalData.cartItemList
                                                  .firstWhere(
                                                    (element) =>
                                                        element.productName
                                                                .trim()
                                                                .toLowerCase() ==
                                                            cartItem
                                                                .product
                                                                .name
                                                                .trim()
                                                                .toLowerCase() &&
                                                        element.size ==
                                                            cartItem.size,
                                                  )
                                                  .amount >
                                              10) {
                                            GlobalData.cartItemList
                                                    .firstWhere(
                                                      (element) =>
                                                          element.productName
                                                                  .trim()
                                                                  .toLowerCase() ==
                                                              cartItem
                                                                  .product
                                                                  .name
                                                                  .trim()
                                                                  .toLowerCase() &&
                                                          element.size ==
                                                              cartItem.size,
                                                    )
                                                    .amount =
                                                10;
                                          }
                                        } else {
                                          GlobalData.cartItemList.add(cartItem);
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Cart(
                                              isDark: widget.isDark,
                                              index: widget.index,
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
