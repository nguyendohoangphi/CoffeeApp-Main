// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/UI/Product/product_list.dart';
import 'package:lottie/lottie.dart';

class Category extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  const Category({required this.isDark, required this.onDarkChanged, super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  late Future<void> _loadDataFuture;
  late List<CategoryProduct> categories = [];
  late List<CategoryProduct> categoriesSearch = [];

  // Theme Colors
  Color get backgroundColor => widget.isDark ? const Color(0xFF1A1D1F) : const Color(0xFFF7F8FA);
  Color get cardColor => widget.isDark ? const Color(0xFF252A32) : Colors.white;
  Color get textColor => widget.isDark ? AppColors.textMainDark : AppColors.textMainLight;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = loadData();
  }

  Future<void> loadData() async {
    if (categories.isEmpty) {
      categories = await FirebaseDBManager.categoryProductService.getCategoryProductList();
    }
  }

  void toggleDarkMode() {
    widget.onDarkChanged(!widget.isDark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Lottie.asset('assets/background/loading.json', width: 150, height: 150));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải danh mục", style: TextStyle(color: textColor)));
          }

          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchBar(context),
                    const SizedBox(height: 20),
                    _buildCategoryGrid(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Thực đơn",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
        ),
        InkWell(
          onTap: toggleDarkMode,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: Icon(
              widget.isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SearchAnchor(
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
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
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              String typeSearch = categoriesSearch.isNotEmpty ? categoriesSearch[0].name : '';
              if (typeSearch.isEmpty) return;

              controller.closeView(value);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductList(nameProduct: "", productType: typeSearch, isDark: widget.isDark, index: 1)),
              );
            },
          ),
        );
      },
      suggestionsBuilder: (context, controller) {
        final query = controller.text.toLowerCase().trim();
        categoriesSearch = categories.where((e) => e.displayName.toLowerCase().contains(query)).toList();

        if (categoriesSearch.isEmpty) {
          return [ListTile(title: Text('Không tìm thấy', style: TextStyle(color: textColor)))];
        }
        return List.generate(categoriesSearch.length, (index) {
          final entry = categoriesSearch[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(entry.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
            ),
            title: Text(entry.displayName, style: TextStyle(color: textColor)),
            onTap: () {
              controller.closeView(entry.displayName);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductList(nameProduct: "", productType: entry.name, isDark: widget.isDark, index: 1)),
              );
            },
          );
        });
      },
    );
  }

  Widget _buildCategoryGrid() {
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (index * 80)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _CategoryCard(category: cat, isDark: widget.isDark),
          );
        },
      ),
    );
  }
}

// Helper widget for the category card to keep build method clean
class _CategoryCard extends StatelessWidget {
  final CategoryProduct category;
  final bool isDark;

  const _CategoryCard({required this.category, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(nameProduct: "", productType: category.name, isDark: isDark, index: 1),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(category.imageUrl, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    category.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.5,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)]
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
  }
}