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
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
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
  void toggleDarkMode() {
    setState(() {
      widget.isDark = !widget.isDark;
    });

    widget.onDarkChanged(widget.isDark); // Notify parent
  }

  late List<Product> productTop10HighRatingList = [];
  late List<Product> productTop5NewestList = [];
  late List<Product> productSearchList = [];
  late int indexCategory;
  late List<Product> productsCategory = [];
  late List<CategoryProduct> categories = [];
  late List<Product> favouriteProduct = [];
  late List<Ads> ads = [];
  var logger = Logger();

  // ignore: non_constant_identifier_names
  void InitializeVideoPlayer(VideoPlayerController vpc, String pathVideo) {
    vpc = VideoPlayerController.asset(pathVideo)
      ..initialize().then((_) {
        setState(() {});
        vpc.setLooping(true);
        vpc.setVolume(0);
        vpc.play();
      });
  }

  @override
  void initState() {
    super.initState();

    indexCategory = 0;

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _iconAnimation = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getUserDetail(
      GlobalData.userDetail.email,
    ))!;

    categories = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();
    productTop10HighRatingList = await FirebaseDBManager.productService
        .getTop10RatedProducts();

    productsCategory = await FirebaseDBManager.productService.getProductsByType(
      categories[indexCategory].name,
    );
    ads = await FirebaseDBManager.adsService.getAds();

    List<ProductFavourite> favouriteList = await FirebaseDBManager
        .favouriteService
        .getFavouritesByEmail(GlobalData.userDetail.email);

    for (ProductFavourite fav in favouriteList) {
      favouriteProduct.add(
        await FirebaseDBManager.productService.getProductByName(
          fav.productName,
        ),
      );
    }
  }

  Future<void> LoadProductWithCategory() async {
    productsCategory = await FirebaseDBManager.productService.getProductsByType(
      categories[indexCategory].name,
    );
  }

  Widget _buildAnimatedTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _iconAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_iconAnimation.value, 0),
              child: child,
            );
          },
          child: const Icon(Icons.coffee, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 8),
        const Text(
          'Những nước uống yêu thích của bạn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4; // 4 items visible
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// LEFT: Avatar + Name
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                  GlobalData.userDetail.photoURL,
                                ),
                                radius: 30,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(GlobalData.userDetail.displayName),
                                  Text(GlobalData.userDetail.rank),
                                ],
                              ),
                            ],
                          ),

                          /// RIGHT: Search bar
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: SearchAnchor(
                              builder: (context, controller) {
                                return SearchBar(
                                  controller: controller,
                                  onTap: () => controller.openView(),
                                  onChanged: (_) => controller.openView(),
                                  onSubmitted: (value) async {
                                    if (value.trim().isEmpty ||
                                        productSearchList.isEmpty) {
                                      return; // Do nothing if empty
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Searching for: $value"),
                                      ),
                                    );
                                    controller.closeView(value);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductList(
                                          nameProduct: value.trim(),
                                          productType: "",
                                          isDark: widget.isDark,
                                          index: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: const Icon(Icons.search),
                                  trailing: <Widget>[
                                    Tooltip(
                                      message: widget.isDark
                                          ? 'Chế độ tối'
                                          : 'Chế độ sáng',
                                      child: IconButton(
                                        isSelected: widget.isDark,
                                        onPressed: () =>
                                            setState(toggleDarkMode),
                                        icon: const Icon(
                                          Icons.wb_sunny_outlined,
                                        ),
                                        selectedIcon: const Icon(
                                          Icons.brightness_2_outlined,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },

                              suggestionsBuilder: (context, controller) async {
                                // Filter your product list by the current query
                                final query = controller.text.toLowerCase();
                                productSearchList = await FirebaseDBManager
                                    .productService
                                    .searchProductsByName(query.trim());

                                // Show a message if no match is found
                                if (productSearchList.isEmpty) {
                                  return [
                                    const ListTile(
                                      title: Text('Không tìm thấy kết quả'),
                                    ),
                                  ];
                                }

                                return List<ListTile>.generate(
                                  productSearchList.length,
                                  (index) {
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
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// BANNER ADS
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: SizedBox(
                          height: 200, // adjust as needed
                          child: PageView.builder(
                            itemCount: ads.length,
                            onPageChanged: (index) {
                              // Optional: update current page indicator
                            },
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(ads[index].name)),
                                  );
                                },
                                child: Image.asset(
                                  ads[index].imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// HEADER CATEGORY
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Danh mục nước uống",
                              style: TextStyle(color: Colors.orange[300]),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Xem thêm")),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductList(
                                    nameProduct: "",
                                    productType: categories[indexCategory].name,
                                    isDark: widget.isDark,
                                    index: 0,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Xem Thêm",
                              style: TextStyle(color: Colors.orange[300]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// CATEGORY LIST
                      SizedBox(
                        height: 40,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: itemWidth,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      indexCategory = index;
                                      LoadProductWithCategory();
                                    });
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 8,
                                    ),
                                    color: index == indexCategory
                                        ? Colors.green.shade100
                                        : Colors.blue.shade100,
                                    child: Center(
                                      child: Text(
                                        categories[index].displayName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// PRODUCT LIST
                      SizedBox(
                        height: 244,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24), // Bo góc đẹp
                          child: AnimateGradient(
                            primaryBegin: Alignment.topLeft,
                            primaryEnd: Alignment.bottomRight,
                            secondaryBegin: Alignment.bottomRight,
                            secondaryEnd: Alignment.topLeft,
                            duration: const Duration(seconds: 6),
                            primaryColors: const [
                              Color(0xFF5D4037), // Coffee brown
                              Color(0xFF8D6E63), // Milk coffee
                              Color(0xFFA1887F), // Mocha
                            ],
                            secondaryColors: const [
                              Color(0xFF4E342E), // Espresso
                              Color(0xFF6D4C41), // Chocolate
                              Color(0xFF795548), // Cinnamon brown
                            ],
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                    },
                                  ),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productsCategory.length,
                                itemBuilder: (context, index) {
                                  final product = productsCategory[index];
                                  return ProductcardCategorymain(
                                    product: product,
                                    isDark: widget.isDark,
                                    index: 0,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// RECOMMENDED PRODUCT LIST
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom title with animated MP4 icon
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Lottie.asset(
                                    'assets/video/CoffeeRecommended.json',
                                    repeat: true,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Những nước uống khuyến nghị",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 19, 212, 19),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // AnimateGradient background container with rounded corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 400,
                              child: AnimateGradient(
                                primaryBegin: Alignment.topLeft,
                                primaryEnd: Alignment.bottomRight,
                                secondaryBegin: Alignment.bottomLeft,
                                secondaryEnd: Alignment.topRight,
                                duration: const Duration(seconds: 6),
                                primaryColors: const [
                                  Color(0xFF5D4037), // Coffee brown
                                  Color(0xFF8D6E63), // Milk coffee
                                  Color(0xFFA1887F), // Mocha
                                ],
                                secondaryColors: const [
                                  Color(0xFF4E342E), // Espresso
                                  Color(0xFF6D4C41), // Chocolate
                                  Color(0xFF795548), // Cinnamon brown
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(
                                          dragDevices: {
                                            PointerDeviceKind.touch,
                                            PointerDeviceKind.mouse,
                                          },
                                        ),
                                    child: ListView.builder(
                                      itemCount:
                                          productTop10HighRatingList.length,
                                      itemBuilder: (context, index) {
                                        final product =
                                            productTop10HighRatingList[index];
                                        return ProductcardRecommended(
                                          product: product,
                                          isDark: widget.isDark,
                                          index: index,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// Favourite PRODUCT LIST
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CUSTOM TITLE WITH LOTTIE ICON
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Lottie.asset(
                                    'assets/video/CoffeeFavourite.json',
                                    repeat: true,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                const SizedBox(width: 10),
                                const Text(
                                  "Đồ uống bạn yêu thích",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 223, 20, 64),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // PRODUCT LIST WITH ANIMATEGRADIENT BACKGROUND AND ROUNDED CONTAINER
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // <- SOFT ROUND
                            child: SizedBox(
                              height: 400,
                              child: AnimateGradient(
                                primaryBegin: Alignment.topLeft,
                                primaryEnd: Alignment.bottomRight,
                                secondaryBegin: Alignment.bottomLeft,
                                secondaryEnd: Alignment.topRight,
                                duration: const Duration(seconds: 6),
                                primaryColors: const [
                                  Color(0xFF5D4037), // Coffee brown
                                  Color(0xFF8D6E63), // Milk coffee
                                  Color(0xFFA1887F), // Mocha
                                ],
                                secondaryColors: const [
                                  Color(0xFF4E342E), // Espresso
                                  Color(0xFF6D4C41), // Chocolate
                                  Color(0xFF795548), // Cinnamon brown
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(
                                          dragDevices: {
                                            PointerDeviceKind.touch,
                                            PointerDeviceKind.mouse,
                                          },
                                        ),
                                    child: ListView.builder(
                                      itemCount: favouriteProduct.length,
                                      itemBuilder: (context, index) {
                                        final product = favouriteProduct[index];
                                        return ProductcardRecommended(
                                          product: product,
                                          isDark: widget.isDark,
                                          index: index,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
