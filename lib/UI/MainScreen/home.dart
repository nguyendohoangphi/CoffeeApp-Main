import 'dart:ui';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/Entity/ads.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/productcard_categorymain.dart';
import 'package:coffeeapp/CustomCard/productcard_recommended.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Product/product_list.dart';
import 'package:lottie/lottie.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  late bool isDark;
  final ValueChanged<bool> onDarkChanged;

  Home({required this.isDark, required this.onDarkChanged, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  late List<Product> productTop10HighRatingList = [];
  late List<Product> productSearchList = [];
  late int indexCategory;
  late List<Product> productsCategory = [];
  late List<CategoryProduct> categories = [];
  late List<Product> favouriteProduct = [];
  late List<Ads> ads = [];

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    indexCategory = 0;

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _iconAnimation =
        Tween<double>(begin: -6, end: 6).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD DATA FIRESTORE
  // ------------------------------------------------------------
  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;

    categories = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();

    productTop10HighRatingList =
    await FirebaseDBManager.productService.getTop10RatedProducts();

    ads = await FirebaseDBManager.adsService.getAds();

    if (categories.isNotEmpty) {
      productsCategory = await FirebaseDBManager.productService
          .getProductsByType(categories[indexCategory].name);
    }

    List<ProductFavourite> favList = await FirebaseDBManager.favouriteService
        .getFavouritesByEmail(GlobalData.userDetail.email);

    favouriteProduct.clear();
    for (var fav in favList) {
      favouriteProduct.add(await FirebaseDBManager.productService
          .getProductByName(fav.productName));
    }
  }

  // ------------------------------------------------------------
  // UI BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        future: LoadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi tải dữ liệu:\n${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                "Không có danh mục nào!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

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
                child: _buildMainUI(context),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN UI
  // ------------------------------------------------------------
  Widget _buildMainUI(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------
          // HEADER
          // ------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                    AssetImage(GlobalData.userDetail.photoURL),
                    radius: 30,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(GlobalData.userDetail.username),
                      Text(GlobalData.userDetail.rank),
                    ],
                  ),
                ],
              ),

              Expanded(
                child: SizedBox(
                  height: 40,
                  child: SearchAnchor(
                    builder: (_, controller) {
                      return SearchBar(
                        controller: controller,
                        onTap: controller.openView,
                        onChanged: (_) => controller.openView(),
                        onSubmitted: (value) async {
                          if (value.trim().isEmpty ||
                              productSearchList.isEmpty) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductList(
                                nameProduct: value.trim(),
                                productType: "",
                                isDark: widget.isDark,
                                index: 0,
                              ),
                            ),
                          );
                        },
                        leading: const Icon(Icons.search),
                      );
                    },
                    suggestionsBuilder: (_, controller) async {
                      String q = controller.text.trim().toLowerCase();
                      productSearchList =
                      await FirebaseDBManager.productService
                          .searchProductsByName(q);

                      if (productSearchList.isEmpty) {
                        return [const ListTile(title: Text("Không tìm thấy"))];
                      }

                      return productSearchList.map((p) {
                        return ListTile(
                          title: Text(p.name),
                          onTap: () => controller.closeView(p.name),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------
          // CATEGORY
          // ------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Danh mục nước uống",
                style: TextStyle(color: Colors.orange),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductList(
                        nameProduct: "",
                        productType: categories[indexCategory].name,
                        isDark: widget.isDark,
                        index: 0,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Xem thêm",
                  style: TextStyle(color: Colors.orange),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => indexCategory = index);
                      productsCategory = await FirebaseDBManager.productService
                          .getProductsByType(categories[index].name);
                      setState(() {});
                    },
                    child: Card(
                      color: indexCategory == index
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      child: Center(
                        child: Text(
                          categories[index].displayName,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ------------------------------------------------------------
          // CATEGORY PRODUCT LIST
          // ------------------------------------------------------------
          SizedBox(
            height: 244,
            child: AnimateGradient(
              primaryColors: const [
                Color(0xFF5D4037),
                Color(0xFF8D6E63),
                Color(0xFFA1887F),
              ],
              secondaryColors: const [
                Color(0xFF4E342E),
                Color(0xFF6D4C41),
                Color(0xFF795548),
              ],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productsCategory.length,
                itemBuilder: (context, index) {
                  final product = productsCategory[index];
                  return ProductcardCategorymain(
                    product: product,
                    isDark: widget.isDark,
                    index: index,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------
          // TOP RATED PRODUCTS
          // ------------------------------------------------------------
          _buildRecommended(),

          const SizedBox(height: 20),

          // ------------------------------------------------------------
          // FAVOURITE PRODUCTS
          // ------------------------------------------------------------
          _buildFavourite(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RECOMMENDED SECTION
  // ------------------------------------------------------------
  Widget _buildRecommended() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset('assets/video/CoffeeRecommended.json'),
            ),
            const SizedBox(width: 10),
            const Text(
              "Đồ uống bán chạy",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 400,
            child: AnimateGradient(
              primaryColors: const [
                Color(0xFF5D4037),
                Color(0xFF8D6E63),
                Color(0xFFA1887F),
              ],
              secondaryColors: const [
                Color(0xFF4E342E),
                Color(0xFF6D4C41),
                Color(0xFF795548),
              ],
              child: ListView.builder(
                itemCount: productTop10HighRatingList.length,
                itemBuilder: (context, index) {
                  final p = productTop10HighRatingList[index];
                  return ProductcardRecommended(
                    product: p,
                    isDark: widget.isDark,
                    index: index,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // FAVOURITE SECTION
  // ------------------------------------------------------------
  Widget _buildFavourite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset('assets/video/CoffeeFavourite.json'),
            ),
            const SizedBox(width: 10),
            const Text(
              "Đồ uống bạn yêu thích",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.pink,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 400,
            child: AnimateGradient(
              primaryColors: const [
                Color(0xFF5D4037),
                Color(0xFF8D6E63),
                Color(0xFFA1887F),
              ],
              secondaryColors: const [
                Color(0xFF4E342E),
                Color(0xFF6D4C41),
                Color(0xFF795548),
              ],
              child: ListView.builder(
                itemCount: favouriteProduct.length,
                itemBuilder: (context, index) {
                  final p = favouriteProduct[index];
                  return ProductcardRecommended(
                    product: p,
                    isDark: widget.isDark,
                    index: index,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
