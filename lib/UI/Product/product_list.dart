import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/CustomCard/colorsetupbackground.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/productcard_list.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';

// ignore: must_be_immutable
class ProductList extends StatefulWidget {
  late int index;
  late bool isDark;
  final String nameProduct;
  final String productType;

  ProductList({
    required this.index,
    required this.nameProduct,
    required this.productType,
    required this.isDark,
    super.key,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  void toggleDarkMode() {
    setState(() {
      widget.isDark = !widget.isDark;
    });
  }

  late List<Product> productFiltered = [];

  @override
  void initState() {
    super.initState();
  }

  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    if (widget.nameProduct != "") {
      productFiltered = await FirebaseDBManager.productService
          .searchProductsByName(widget.nameProduct);
    }

    if (widget.productType != "") {
      productFiltered = await FirebaseDBManager.productService
          .getProductsByType(widget.productType);
    }
  }

  late List<Product> productSearchList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimateGradient(
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
          child: AppBar(
            backgroundColor: Colors.transparent,

            elevation: 4.0,
            // ignore: deprecated_member_use
            shadowColor: Colors.black.withOpacity(0.3),
            automaticallyImplyLeading: true,
            leading: IconButton(
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
              icon: Icon(Icons.arrow_back, color: Colors.white70),
            ),

            title: SizedBox(
              width: 250,
              height: 40,
              child: SearchAnchor(
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    onTap: () => controller.openView(),
                    onChanged: (_) => controller.openView(),
                    onSubmitted: (value) {
                      if (value.trim().isEmpty || productSearchList.isEmpty) {
                        return; // Do nothing if empty
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Searching for: $value")),
                      );
                      controller.closeView(value);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuNavigationBar(
                            isDark: widget.isDark,
                            selectedIndex: widget.index,
                          ),
                        ),
                      );
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductList(
                            nameProduct: value.trim(),
                            productType: "",
                            isDark: widget.isDark,
                            index: widget.index,
                          ),
                        ),
                      );
                    },
                    leading: const Icon(Icons.search),
                    trailing: <Widget>[
                      Tooltip(
                        message: widget.isDark ? 'Chế độ tối' : 'Chế độ sáng',
                        child: IconButton(
                          isSelected: widget.isDark,
                          onPressed: () => setState(toggleDarkMode),
                          icon: const Icon(Icons.wb_sunny_outlined),
                          selectedIcon: const Icon(Icons.brightness_2_outlined),
                        ),
                      ),
                    ],
                  );
                },

                suggestionsBuilder: (context, controller) async {
                  // Filter your product list by the current query
                  final query = controller.text.toLowerCase();
                  productSearchList = await FirebaseDBManager.productService
                      .searchProductsByName(query);

                  // Show a message if no match is found
                  if (productSearchList.isEmpty) {
                    return [
                      const ListTile(title: Text('Không tìm thấy kết quả')),
                    ];
                  }

                  return List<ListTile>.generate(productSearchList.length, (
                    index,
                  ) {
                    final item = productSearchList[index].name;
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          controller.closeView(
                            item,
                          ); // Optionally fill text field
                        });
                      },
                    );
                  });
                },
              ),
            ),
          ),
        ),
      ),
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
                  child: Column(
                    children: [
                      if (widget.nameProduct.isNotEmpty)
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: Text(
                              "Lọc theo tên sản phẩm: ${widget.nameProduct}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      if (widget.productType.isNotEmpty)
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: Text(
                              "Lọc theo loại sản phẩm: ${widget.productType}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      SizedBox(height: 5),

                      SizedBox(
                        height: 600,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            itemCount: productFiltered.length,
                            itemBuilder: (context, index) {
                              final product = productFiltered[index];
                              return ProductcardList(
                                product: product,
                                isDark: widget.isDark,
                                index: widget.index,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
