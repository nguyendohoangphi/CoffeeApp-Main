import 'dart:ui';

import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/admin/addeditproductpage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late List<Product> mockProducts;
  late List<Product> productSearchList = [];

  late Future<void> _loadDataFuture;

  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    mockProducts = await FirebaseDBManager.productService.getProducts();
    productSearchList = mockProducts;
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditProductPage()),
    );

    if (result == true) {
      setState(() {
        _loadDataFuture = LoadData();
      });
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(product: product),
      ),
    );

    if (result == true) {
      setState(() {
        _loadDataFuture = LoadData();
      });
    }
  }

  Future<void> _deleteProduct(Product product) async {
    setState(() => mockProducts.remove(product));
    await FirebaseDBManager.productService.deleteProductByName(product.name);
    setState(() {
      _loadDataFuture = LoadData();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset(
              'assets/background/loading.json', // Thay bằng đường dẫn đúng tới file Lottie của bạn
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          );
        } else if (asyncSnapshot.hasError) {
          return Center(child: Text('Lỗi: ${asyncSnapshot.error}'));
        } else {
          return Scaffold(
            backgroundColor: Colors.transparent,
            // Trên Web Dashboard chúng ta đã có Header riêng, nhưng giữ lại AppBar để chứa thanh tìm kiếm
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Nếu muốn ẩn tiêu đề trên web vì đã có ở dashboard cha:
              title: const Text('Quản lý sản phẩm'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: SizedBox(
                  width: 250,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm sản phẩm...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        productSearchList = mockProducts
                            .where(
                              (element) => element.name
                                  .toLowerCase()
                                  .trim()
                                  .contains(value.toLowerCase().trim()),
                            )
                            .toList();
                      });
                    },
                  ),
                ),
              ),
            ),
            body: ScrollConfiguration(
              // Cấu hình cho phép kéo chuột trên Web
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: ListView.builder(
                itemCount: productSearchList.length,
                itemBuilder: (context, index) {
                  final product = productSearchList[index];
                  return Dismissible(
                    key: Key(product.name + product.createDate),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    // Thêm confirmDismiss để tránh xóa nhầm trên web
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Xác nhận xóa"),
                            content: Text("Bạn có chắc muốn xóa sản phẩm ${product.name}?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (_) => _deleteProduct(product),
                    child: ListTile(
                      leading: Image.asset(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Text('${product.price.toStringAsFixed(0)} đ'),
                      onTap: () => _editProduct(product),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _addProduct,
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
