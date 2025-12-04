
import 'dart:ui';
//mport 'package:animate_gradient/animate_gradient.dart';
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
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
class Home extends StatefulWidget {
  late bool isDark;
  final ValueChanged<bool> onDarkChanged;

  Home({required this.isDark, required this.onDarkChanged, super.key});

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

   //ads
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

    // _iconAnimation =
    //     Tween<double>(begin: -6, end: 6).animate(CurvedAnimation(
    //       parent: _controller,
    //       curve: Curves.easeInOut,
    //     ));

    //ads load firestore 1 lan duy nhat
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
  // backgroundColor: const Color(0xFF25262C),
   body: FutureBuilder(
        future: _loadDataFuture,
        //future: LoadData(),
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
                physics: const BouncingScrollPhysics(),        child: _buildMainUI(context),
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
 // final screenWidth = MediaQuery.of(context).size.width;
  

  return Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
          // ------------------------------------------------------------
          // HEADER
          // ------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(GlobalData.userDetail.photoURL),
                      radius: 24, // Giảm kích thước avatar
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào, ${GlobalData.userDetail.username.split(' ').last}!", // Chào hỏi thân thiện hơn
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          GlobalData.userDetail.rank,
                          style: TextStyle(
                            color: Color(0xFFFF8A00), // Màu cam nhấn
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Search Bar
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    height: 48, // Tăng chiều cao Search Bar
                    child: SearchAnchor(
                      builder: (BuildContext context, SearchController controller) {
                        return SearchBar(
                          controller: controller,
                          hintText: "Search",
                                  textStyle: MaterialStateProperty.all(const TextStyle(color: Color.fromARGB(246, 136, 136, 136))),
                                  surfaceTintColor: MaterialStateProperty.all(Colors.white), // Nền trắng
                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Bo tròn tối đa
                          )),
                          onTap: controller.openView,
                          onChanged: (_) => controller.openView(),

                          // LOGIC TÌM KIẾM
                          onSubmitted: (value) async {
                            if (value.trim().isEmpty || productSearchList.isEmpty) return;

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
                          // ===========================================

                          leading: const Icon(Icons.search, color: Color(0xFFFF8A00)), // Icon Cam
                        );
                      },
                      
                      
                      suggestionsBuilder: (context, controller) async {
                        String q = controller.text.trim().toLowerCase();
                        productSearchList = await FirebaseDBManager.productService
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
                      // ==============================================================
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

// ------------------------------------------------------------
// ADS BANNER 
// ------------------------------------------------------------
if (ads.isNotEmpty)
  Column(
    children: [
      CarouselSlider(
        options: CarouselOptions(
          height: 180,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          viewportFraction: 0.9,
          onPageChanged: (index, reason) {
            setState(() {
              _currentBanner = index;
            });
          },
        ), // <--- CÓ DẤU PHẨY Ở ĐÂY
        items: ads.map((ad) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // IMAGE
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ad.imageUrl.startsWith("assets/")
                          ? AssetImage(ad.imageUrl)
                          : NetworkImage(ad.imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // GRADIENT OVERLAY 
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.4), // Màu cũ: Tối nhẹ
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                  left: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   ad.title,
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      const SizedBox(height: 5), // Thêm khoảng cách
                      // ElevatedButton(
                      //   onPressed: () {
                      //     // Thêm logic chuyển trang ADS ở đây
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: const Color(0xFFFF8A00), 
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(10)),
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 15, vertical: 8),
                      //   ),
                      //   child: const Text("Đặt hàng ngay", style:TextStyle(color: Colors.white, fontSize: 13)),
                      // )
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 8),

      // INDICATOR
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
              color: active ? Colors.white : Colors.grey.shade400, // Đã quay về màu cũ
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }).toList(),
      ),
    ],
  ),

const SizedBox(height: 20),

    
    // ------------------------------------------------------------
    // CATEGORY 
    // ------------------------------------------------------------
    Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16.0),
     child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       const Text(
        "Danh mục nước uống",
        style: TextStyle(
         fontSize: 18,
         fontWeight: FontWeight.bold,
         color: Colors.white, // Chữ trắng trên nền tối
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
         "Xem thêm",
         style: TextStyle(color: Color(0xFFFF8A00), fontWeight: FontWeight.bold),
        ),
       )
      ],
     ),
    ),
    
    const SizedBox(height: 8),

    // Danh sách Category Buttons
    SizedBox(
     height: 40,
     child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
       return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
         onTap: () async {
                      setState(() => indexCategory = index);
                      productsCategory = await FirebaseDBManager.productService
                          .getProductsByType(categories[index].name);
                      setState(() {});
         },
         child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
           color: indexCategory == index
             ? const Color(0xFFFF8A00) // Màu Cam nhấn khi active
             : const Color(0xFF3B3D45), // Màu xám nhẹ khi inactive
           borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
           child: Text(
            categories[index].displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
             color: indexCategory == index ? Colors.white : Colors.white70,
             fontWeight: FontWeight.w600,
            ),
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
    Padding(
     padding: const EdgeInsets.only(left: 16.0),
     child: SizedBox(
      height: 250, // Điều chỉnh lại chiều cao
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
    Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16.0),
     child: _buildRecommended(),
    ),

    const SizedBox(height: 20),

    // ------------------------------------------------------------
    // FAVOURITE PRODUCTS 
    // ------------------------------------------------------------
    Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16.0),
     child: _buildFavourite(),
    ),
   ],
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
       width: 40, // Giảm kích thước Lottie
       height: 40,
       child: Lottie.asset('assets/video/CoffeeRecommended.json'),
      ),
      const SizedBox(width: 10),
      const Text(
       "Đồ uống bán chạy",
       style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white, // Chữ trắng cho nền tối
       ),
      ),
     ],
    ),
    const SizedBox(height: 10),
    SizedBox(
     height: 400, // Chiều cao cố định cho danh sách cuộn
     child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(), 
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
       width: 40, // Giảm kích thước Lottie
       height: 40,
       child: Lottie.asset('assets/video/CoffeeFavourite.json'),
      ),
      const SizedBox(width: 10),
      const Text(
       "Đồ uống bạn yêu thích",
       style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white, // Chữ trắng cho nền tối
       ),
      ),
     ],
    ),
    const SizedBox(height: 10),
    SizedBox(
     height: 400, // Chiều cao cố định cho danh sách cuộn
     child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
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
   ],
  );
 }}