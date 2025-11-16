import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/Transition/menunavigationbar_admin.dart';
import 'package:flutter/material.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product; // null nếu là thêm mới

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late Future<void> _loadDataFuture;
  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late CategoryProduct _selectedType = CategoryProduct(
    id: '',
    createDate: '',
    name: '',
    imageUrl: '',
    displayName: '',
  );
  late List<CategoryProduct> categoryProducts = [];
  late List<Product> products = [];
  Future<void> LoadData() async {
    categoryProducts = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();
    products = await FirebaseDBManager.productService.getProducts();

    _selectedType = categoryProducts[0];
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct(bool isEdit) async {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.product != null;
      final newProduct = Product(
        createDate: isEdit
            ? widget.product!.createDate
            : DateTime.now().toIso8601String(),
        name: widget.product?.name ?? _nameController.text,
        imageUrl: _imageUrlController.text,
        description: _descriptionController.text,
        rating: widget.product?.rating ?? 0,
        reviewCount: widget.product?.reviewCount ?? 0,
        price: double.parse(_priceController.text),
        type: _selectedType.name,
      );

      if (isEdit) {
        await FirebaseDBManager.productService.updateProductByName(
          newProduct.name,
          newProduct,
        );
      } else {
        if (products
            .where(
              (element) =>
                  element.name.toLowerCase().trim() ==
                  _nameController.text.toLowerCase().trim(),
            )
            .isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tên nước uống này đã tồn tại')),
          );
          return;
        }
        await FirebaseDBManager.productService.createProduct(newProduct);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuNavigationbarAdmin()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, asyncSnapshot) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  if (!isEdit)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Không được để trống'
                          : null,
                    )
                  else
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm',
                      ),
                      enabled: false,
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Đường dẫn hình ảnh',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Không được để trống'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Giá'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Không được để trống'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CategoryProduct>(
                    value: _selectedType,
                    items: categoryProducts
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value!),
                    decoration: const InputDecoration(
                      labelText: 'Loại sản phẩm',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveProduct(isEdit),
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
