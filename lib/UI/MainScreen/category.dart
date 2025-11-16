import 'dart:ui';

import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/UI/Product/product_list.dart';

// ignore: must_be_immutable
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

  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    categories = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();
  }

  void toggleDarkMode() {
    setState(() {
      widget.isDark = !widget.isDark;
    });

    widget.onDarkChanged(widget.isDark); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final itemWidth = screenWidth / 4; // 4 items visible
    return Scaffold(
      //backgroundColor: widget.isDark ? Colors.grey[800] : Colors.brown[400],
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
                    children: [
                      // Search Category
                      SearchAnchor(
                        builder: (context, controller) {
                          return SearchBar(
                            controller: controller,
                            onTap: () => controller.openView(),
                            onChanged: (_) => controller.openView(),
                            onSubmitted: (value) async {
                              // Filter map by label (value.split(";")[1])

                              if (value.trim().isEmpty ||
                                  categoriesSearch.isEmpty) {
                                return; // Do nothing if empty
                              }
                              String typeSearch = '';
                              if (categoriesSearch
                                  .where(
                                    (element) =>
                                        element.displayName
                                            .toLowerCase()
                                            .trim() ==
                                        value.trim().toLowerCase(),
                                  )
                                  .isNotEmpty) {
                                typeSearch = categoriesSearch
                                    .firstWhere(
                                      (element) =>
                                          element.displayName
                                              .toLowerCase()
                                              .trim() ==
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
                            leading: const Icon(Icons.search),
                            trailing: <Widget>[
                              Tooltip(
                                message: widget.isDark
                                    ? 'Chế độ tối'
                                    : 'Chế độ sáng',
                                child: IconButton(
                                  isSelected: widget.isDark,
                                  onPressed: () => setState(toggleDarkMode),
                                  icon: const Icon(Icons.wb_sunny_outlined),
                                  selectedIcon: const Icon(
                                    Icons.brightness_2_outlined,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },

                        suggestionsBuilder: (context, controller) {
                          final query = controller.text.toLowerCase();

                          categoriesSearch = categories
                              .where(
                                (element) => element.displayName
                                    .toLowerCase()
                                    .contains(query.trim()),
                              )
                              .toList();

                          if (categoriesSearch.isEmpty) {
                            return [
                              const ListTile(
                                title: Text('Không tìm thấy kết quả'),
                              ),
                            ];
                          }
                          return List<ListTile>.generate(
                            categoriesSearch.length,
                            (index) {
                              final entry = categoriesSearch[index];
                              final label = entry.displayName;

                              return ListTile(
                                leading: Image.asset(
                                  entry.imageUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(label),
                                onTap: () {
                                  setState(() {
                                    controller.closeView(
                                      label,
                                    ); // Close view and optionally fill field
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      // Category List
                      Container(
                        padding: EdgeInsets.only(bottom: 100),
                        child: SizedBox(
                          height: screenHeight,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                              itemCount: categories.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 2 cột
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1.2,
                                  ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductList(
                                          nameProduct: "",
                                          productType: categories
                                              .firstWhere(
                                                (e) =>
                                                    e.displayName
                                                        .toLowerCase() ==
                                                    categories
                                                        .elementAt(index)
                                                        .displayName
                                                        .trim()
                                                        .toLowerCase(),
                                              )
                                              .name,
                                          isDark: widget.isDark,
                                          index: 1,
                                        ),
                                      ),
                                    );
                                  },

                                  child: SizedBox(
                                    width: itemWidth,
                                    height: 150,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            categories
                                                .elementAt(index)
                                                .imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 8,
                                              ),
                                              color: Colors.black54,
                                              child: Text(
                                                categories
                                                    .elementAt(index)
                                                    .displayName,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
    );
  }
}
