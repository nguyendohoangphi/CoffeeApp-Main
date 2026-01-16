// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:ui';
// import 'package:animate_gradient/animate_gradient.dart';
import 'package:coffeeapp/models/ads.dart';
import 'package:coffeeapp/models/categoryproduct.dart';
import 'package:coffeeapp/models/productfavourite.dart';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/widgets/productcard_categorymain.dart';
import 'package:coffeeapp/widgets/productcard_recommended.dart';
import 'package:coffeeapp/models/product.dart';
import 'package:coffeeapp/models/global_data.dart';
import 'package:coffeeapp/screens/Product/product_list.dart';
import 'package:lottie/lottie.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:coffeeapp/constants/app_colors.dart'; 

class Home extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  const Home({required this.isDark, required this.onDarkChanged, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // late Animation<double> _iconAnimation;

  late List<Product> productTop10HighRatingList = [];
  late List<Product> productSearchList = [];
  late int indexCategory;
  late List<Product> productsCategory = [];
  late List<CategoryProduct> categories = [];
  late List<Product> favouriteProduct = [];
  late List<Ads> ads = [];

  // Ads variables
  int _currentBanner = 0;
  late Future<void> _loadDataFuture;

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    indexCategory = 0;

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Ads load firestore 1 lan duy nhat
    _loadDataFuture = LoadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD DATA FIRESTORE
  // ------------------------------------------------------------
  Future<void> _refreshFavourites() async {
    logger.i("Refreshing favourites...");
    List<ProductFavourite> favList = await FirebaseDBManager.favouriteService.getFavouritesByEmail(GlobalData.userDetail.email);
    logger.i("Found ${favList.length} favourites in database.");

    favouriteProduct.clear();
    for (var fav in favList) {
      favouriteProduct.add(await FirebaseDBManager.productService
          .getProductByName(fav.productName));
    }
    logger.i("Updated local favouriteProduct list. Count: ${favouriteProduct.length}");
    if (mounted) {
      setState(() {});
      logger.i("setState called on Home screen.");
    }
  }

  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getProfile())!;

    categories = await FirebaseDBManager.categoryProductService.getCategoryProductList();

    productTop10HighRatingList = await FirebaseDBManager.productService.getTop10RatedProducts();

    ads = await FirebaseDBManager.adsService.getAds();

    if (categories.isNotEmpty) {
      productsCategory = await FirebaseDBManager.productService
          .getProductsByType(categories[indexCategory].name);
    }
    // Call the refresh function to load favourites
    await _refreshFavourites();
  }

  // ------------------------------------------------------------
  // UI BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi tải dữ liệu:\n${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
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

  // MAIN UI - NEW MODERN DESIGN
  // ------------------------------------------------------------
  Widget _buildMainUI(BuildContext context) {
    // Xác định màu chữ dựa trên theme
    final Color textColor = widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final Color subTextColor = widget.isDark ? AppColors.textSubDark : AppColors.textSubLight;
    final Color cardColor = widget.isDark ? const Color(0xFF252A32) : Colors.white;
    final Color subtleBorderColor = widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Xin chào,",
                    style: TextStyle(fontSize: 14, color: subTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    GlobalData.userDetail.username.isNotEmpty
                        ? GlobalData.userDetail.username
                        : "Bạn mới",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      GlobalData.userDetail.rank,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(GlobalData.userDetail.photoURL),
                ),
              )
            ],
          ),
        ),



    

        // 2. SEARCH BAR 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  hintText: "Tìm kiếm đồ uống...",
                  hintStyle: MaterialStateProperty.all(TextStyle(color: Colors.grey[400])),
                  textStyle: MaterialStateProperty.all(TextStyle(color: widget.isDark ? Colors.white : Colors.black87)),
                  surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  elevation: MaterialStateProperty.all(0),
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                  leading: const Icon(Icons.search, color: AppColors.primary),
                  onTap: () => controller.openView(),
                  onChanged: (_) => controller.openView(),
                  
                  // KHI BẤM ENTER (SUBMIT)
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;
                    controller.closeView(value);
                    _navigateToProductList(context, value.trim());
                  },
                );
              },
              
              suggestionsBuilder: (context, controller) async {
              final keyword = controller.text.trim();

                productSearchList =
                    await FirebaseDBManager.productService.searchProductsByName(keyword);

                
                if (productSearchList.isEmpty) {
                  return [
                    const ListTile(
                      leading: Icon(Icons.search_off, color: Colors.grey),
                      title: Text("Không tìm thấy món nào"),
                    ),
                  ];
                }

                return productSearchList.map((product) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),

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

                      // ==== TITLE ====
                      title: Text(
                        product.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ==== SUBTITLE ====
                      subtitle: Text(
                        "${product.price} đ",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ==== CLICK ====
                      onTap: () {
                        controller.closeView(product.name);
                        _navigateToProductList(context, product.name);
                      },
                  );
                }).toList();
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 3. ADS BANNER (Carousel)
        if (ads.isNotEmpty)
          Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentBanner = index;
                    });
                  },
                ),
                items: ads.map((ad) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildSmartImage(ad.imageUrl),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Indicators (Dấu chấm tròn)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ads.asMap().entries.map((entry) {
                  bool active = _currentBanner == entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: active ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

        const SizedBox(height: 20),

        // 4. DANH MỤC (Categories)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Danh mục",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
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
                  "Xem tất cả",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        
        // List  (Pills style)
        SizedBox(
          height: 45,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              bool isSelected = indexCategory == index;
              return GestureDetector(
                onTap: () async {
                  setState(() => indexCategory = index);
                  productsCategory = await FirebaseDBManager.productService
                      .getProductsByType(categories[index].name);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : cardColor,
                    borderRadius: BorderRadius.circular(25),
                    border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
                    boxShadow: isSelected 
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] 
                      : [],
                  ),
                  child: Center(
                    child: Text(
                      categories[index].displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // 5. LIST product THEO category
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: SizedBox(
            height: 260, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productsCategory.length,
              itemBuilder: (context, index) {
                final product = productsCategory[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: ProductcardCategorymain(
                    product: product,
                    isDark: widget.isDark,
                    index: index,
                    onFavoriteChanged: _refreshFavourites,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 25),

        // 6. TOP RATED PRODUCTS 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSectionHeader("Đồ uống bán chạy", 'assets/video/CoffeeRecommended.json', textColor),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true, 
            itemCount: productTop10HighRatingList.length,
            itemBuilder: (context, index) {
              final p = productTop10HighRatingList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ProductcardRecommended(
                  product: p,
                  isDark: widget.isDark,
                  index: index,
                  onFavoriteChanged: _refreshFavourites,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // 7. FAVOURITE PRODUCTS 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSectionHeader("Đồ uống yêu thích", 'assets/video/CoffeeFavourite.json', textColor),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: favouriteProduct.length,
            itemBuilder: (context, index) {
              final p = favouriteProduct[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ProductcardRecommended(
                  product: p,
                  isDark: widget.isDark,
                  index: index,
                  onFavoriteChanged: _refreshFavourites,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 80), 
      ],
    );
  }

  // Widget sp title Section
  Widget _buildSectionHeader(String title, String lottieAsset, Color textColor) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Lottie.asset(lottieAsset),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // --- HELPER ---

  void _navigateToProductList(BuildContext context, String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductList(
          nameProduct: keyword,
          productType: "",
          isDark: widget.isDark,
          index: 0,
        ),
      ),
    );
  }

  
  Widget _buildSmartImage(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          logger.e("Lỗi tải ảnh MẠNG: $url", error: error, stackTrace: stackTrace);
          return Container(color: Colors.grey, child: const Icon(Icons.error_outline));
        },
      );
    } else {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          logger.e("Lỗi tải ảnh ASSET: $url", error: error, stackTrace: stackTrace);
          return Container(color: Colors.grey, child: const Icon(Icons.error_outline));
        },
      );
    }
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 40, height: 40, fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[200], width: 40, height: 40, child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey)),
      );
    } else {
      return Image.asset(
        url,
        width: 40, height: 40, fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[200], width: 40, height: 40, child: const Icon(Icons.image, size: 20, color: Colors.grey)),
      );
    }
  }
}
