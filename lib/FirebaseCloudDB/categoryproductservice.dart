import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class CategoryProductService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    TableInDatabase.CategoryTable,
  );

  // CREATE
  Future<void> createCategoryProduct(CategoryProduct cp) async {
    try {
      await _ref.doc(cp.id).set(cp.toJson());
    } catch (e) {
      throw Exception('Create failed: $e');
    }
  }

  // READ (Single)
  Future<CategoryProduct?> getCategoryProduct(String id) async {
    try {
      final doc = await _ref.doc(id).get();
      if (doc.exists) {
        return CategoryProduct.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Read failed: $e');
    }
  }

  // READ (one-time fetch)
  Future<List<CategoryProduct>> getCategoryProductList() async {
    final snapshot = await _ref.get();

    if (snapshot.docs.isEmpty) {
      print(
        "No category products found (collection might not exist or is empty)",
      );
      return [];
    }

    return snapshot.docs
        .map(
          (doc) => CategoryProduct.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  // READ by Partial Name (one-time fetch)
  Future<List<CategoryProduct>> getCategoryProductListByPartialName(
    String query,
  ) async {
    final snapshot = await _ref.get();

    if (snapshot.docs.isEmpty) {
      print(
        "No category products found (collection might not exist or is empty)",
      );
      return [];
    }

    return snapshot.docs
        .map(
          (doc) => CategoryProduct.fromJson(doc.data() as Map<String, dynamic>),
        )
        .where(
          (cp) => cp.displayName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // UPDATE
  Future<void> updateCategoryProduct(CategoryProduct cp) async {
    try {
      await _ref.doc(cp.id).update(cp.toJson());
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // DELETE
  Future<void> deleteCategoryProduct(String id) async {
    try {
      await _ref.doc(id).delete();
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }
}
