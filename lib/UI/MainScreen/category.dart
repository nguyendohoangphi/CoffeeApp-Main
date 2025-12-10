import 'dart:ui';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/constants/app_colors.dart'; 
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/UI/Product/product_list.dart';

class Category extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  const Category({required this.isDark, required this.onDarkChanged, super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  late List<CategoryProduct> categories = [];
  late List<CategoryProduct> categoriesSearch = [];
  
  // Màu sắc lấy từ AppColors
  Color get backgroundColor => widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadData() async {
    categories = await FirebaseDBManager.categoryProductService.getCategoryProductList();
  }

  void toggleDarkMode() {
    widget.onDarkChanged(!widget.isDark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<void>(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting && categories.isEmpty) {
             return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Thực đơn",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        // Nút chuyển chế độ sáng tối
                        Container(
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppColors.cardDark : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                            ]
                          ),
                          child: IconButton(
                            icon: Icon(
                              widget.isDark ? Icons.nights_stay : Icons.wb_sunny,
                              color: AppColors.primary,
                            ),
                            onPressed: toggleDarkMode,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SEARCH BAR (Đã đồng bộ Logic cũ) ---
                    SearchAnchor(
                      builder: (context, controller) {
                        return Container(
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: SearchBar(
                            controller: controller,
                            hintText: "Tìm danh mục...",
                            hintStyle: MaterialStateProperty.all(TextStyle(color: Colors.grey[400])),
                            textStyle: MaterialStateProperty.all(TextStyle(color: textColor)),
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                            shadowColor: MaterialStateProperty.all(Colors.transparent),
                            elevation: MaterialStateProperty.all(0),
                            leading: const Icon(Icons.search, color: AppColors.primary),
                            onTap: () => controller.openView(),
                            onChanged: (_) => controller.openView(),
                            
                            // ===============================================
                            // LOGIC SEARCH CŨ CỦA BẠN (Đã đồng bộ)
                            // ===============================================
                            onSubmitted: (value) async {
                              if (value.trim().isEmpty || categoriesSearch.isEmpty) {
                                return; // Do nothing if empty
                              }
                              String typeSearch = '';
                              if (categoriesSearch
                                  .where(
                                    (element) =>
                                        element.displayName.toLowerCase().trim() ==
                                        value.trim().toLowerCase(),
                                  )
                                  .isNotEmpty) {
                                typeSearch = categoriesSearch
                                    .firstWhere(
                                      (element) =>
                                          element.displayName.toLowerCase().trim() ==
                                          value.trim().toLowerCase(),
                                    )
                                    .name;
                              } else {
                                typeSearch = categoriesSearch[0].name;
                              }

                              controller.closeView(value);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductList(
                                    nameProduct: "",
                                    productType: typeSearch,
                                    isDark: widget.isDark,
                                    index: 1,
                                  ),
                                ),
                              );
                            },
                            // ===============================================
                          ),
                        );
                      },
                      suggestionsBuilder: (context, controller) {
                        final query = controller.text.toLowerCase();
                        categoriesSearch = categories
                            .where((e) => e.displayName.toLowerCase().contains(query.trim()))
                            .toList();

                        if (categoriesSearch.isEmpty) {
                          return [ListTile(title: Text('Không tìm thấy kết quả', style: TextStyle(color: textColor)))];
                        }
                        return List<ListTile>.generate(categoriesSearch.length, (index) {
                          final entry = categoriesSearch[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(entry.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                            ),
                            title: Text(entry.displayName, style: TextStyle(color: textColor)),
                            onTap: () {
                              // Logic cũ: Chỉ đóng view và điền text
                              setState(() {
                                controller.closeView(entry.displayName);
                              });
                            },
                          );
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- GRID DANH MỤC ---
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85, 
                        ),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return GestureDetector(
                            onTap: () async {
                              // ===============================================
                              // LOGIC CHUYỂN TRANG CŨ CỦA BẠN (Đã đồng bộ)
                              // ===============================================
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductList(
                                    nameProduct: "",
                                    // Logic tìm productType chính xác từ list gốc
                                    productType: categories
                                        .firstWhere(
                                          (e) =>
                                              e.displayName.toLowerCase() ==
                                              categories.elementAt(index).displayName.trim().toLowerCase(),
                                        )
                                        .name,
                                    isDark: widget.isDark,
                                    index: 1,
                                  ),
                                ),
                              );
                              // ===============================================
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 1. Ảnh nền
                                    Image.asset(
                                      cat.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    // 2. Lớp phủ đen mờ (Gradient) giúp chữ nổi bật
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          stops: const [0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                    // 3. Tên danh mục
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          cat.displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}