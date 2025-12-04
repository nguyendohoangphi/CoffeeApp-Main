import 'dart:ui';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/UI/Product/product_list.dart';

class Category extends StatefulWidget {
  late bool isDark;
  final ValueChanged<bool> onDarkChanged;

  Category({required this.isDark, required this.onDarkChanged, super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  late List<CategoryProduct> categories = [];
  late List<CategoryProduct> categoriesSearch = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> LoadData() async {
    categories = await FirebaseDBManager.categoryProductService.getCategoryProductList();
  }

  void toggleDarkMode() {
    setState(() {
      widget.isDark = !widget.isDark;
    });
    widget.onDarkChanged(widget.isDark);
  }

  @override
  Widget build(BuildContext context) {
    // Layout Calculation
    final double itemHeight = 160; 
    final double itemWidth = (MediaQuery.of(context).size.width - 48) / 2; 

    return Scaffold(
      backgroundColor: Colors.transparent, // Để lộ nền Gradient của MenuNavigationBar
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (categories.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8A00)));
          }
          
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER TITLE GIỐNG HOME ---
                    const Text(
                      "Tìm kiếm món ngon",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- SEARCH BAR (STYLE TỪ HOME) ---
                    SearchAnchor(
                      builder: (context, controller) {
                        return SearchBar(
                          controller: controller,
                          hintText: "Tìm danh mục...",
                          // Style đồng bộ với Home
                          textStyle: MaterialStateProperty.all(const TextStyle(color: Color.fromARGB(246, 136, 136, 136))),
                          surfaceTintColor: MaterialStateProperty.all(Colors.white),
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          )),
                          onTap: () => controller.openView(),
                          onChanged: (_) => controller.openView(),
                          onSubmitted: (value) {
                             // Logic search giữ nguyên của bạn
                             if (value.trim().isEmpty || categoriesSearch.isEmpty) return;
                             // ... (Giữ nguyên logic chuyển trang của bạn)
                          },
                          leading: const Icon(Icons.search, color: Color(0xFFFF8A00)), // Icon Cam
                          trailing: <Widget>[
                            Tooltip(
                              message: widget.isDark ? 'Chế độ tối' : 'Chế độ sáng',
                              child: IconButton(
                                isSelected: widget.isDark,
                                onPressed: () => setState(toggleDarkMode),
                                icon: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                                selectedIcon: const Icon(Icons.brightness_2_outlined, color: Colors.blue),
                              ),
                            ),
                          ],
                        );
                      },
                      suggestionsBuilder: (context, controller) {
                         // Logic suggestion giữ nguyên
                         final query = controller.text.toLowerCase();
                          categoriesSearch = categories
                              .where((element) => element.displayName.toLowerCase().contains(query.trim()))
                              .toList();
                          
                          if (categoriesSearch.isEmpty) {
                            return [const ListTile(title: Text('Không tìm thấy kết quả'))];
                          }
                          return List<ListTile>.generate(categoriesSearch.length, (index) {
                              final entry = categoriesSearch[index];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(entry.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                                ),
                                title: Text(entry.displayName),
                                onTap: () {
                                  controller.closeView(entry.displayName);
                                },
                              );
                          });
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- CATEGORY GRID ---
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100), // Tránh bị che bởi BottomBar
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85, // Điều chỉnh tỷ lệ để hình đẹp hơn
                        ),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductList(
                                    nameProduct: "",
                                    productType: cat.name,
                                    isDark: widget.isDark,
                                    index: 1,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Image
                                    Image.asset(
                                      cat.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    // Gradient Overlay (Để chữ dễ đọc hơn)
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.8),
                                          ],
                                          stops: const [0.6, 1.0],
                                        ),
                                      ),
                                    ),
                                    // Text
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          cat.displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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