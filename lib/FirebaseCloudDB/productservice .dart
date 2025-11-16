import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';
import 'package:flutter/material.dart';

class ProductService {
  final CollectionReference _productRef = FirebaseFirestore.instance.collection(
    TableInDatabase.ProductsTable,
  );

  // CREATE
  Future<void> createProduct(Product product) async {
    try {
      await _productRef.add(product.toJson());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // READ - Single Product (optional)
  Future<Product> getProductByName(String name) async {
    try {
      final querySnapshot = await _productRef
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Product with name "$name" not found');
      }

      final data = querySnapshot.docs.first.data();
      return Product.fromJson(data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      debugPrint('Error getting product by name: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow; // or throw Exception('Failed to get product by name: $e');
    }
  }

  // READ - All Products CATEGORY
  Future<List<Product>> getProductsByType(String type) async {
    final snapshot = await _productRef.where('type', isEqualTo: type).get();

    if (snapshot.docs.isEmpty) {
      print("No products found for type: ${enumToString(type)}");
      return [];
    }

    return snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> getTop10RatedProducts() async {
    final snapshot = await _productRef
        .orderBy('rating', descending: true)
        .limit(10)
        .get();

    if (snapshot.docs.isEmpty) {
      print("No products found for top 10 ratings");
      return [];
    }

    return snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> get5NewestProducts() async {
    final snapshot = await _productRef
        .orderBy('createDate', descending: true)
        .limit(5)
        .get();

    if (snapshot.docs.isEmpty) {
      print("No recently created products found");
      return [];
    }

    return snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // READ - All Products NAME
  Future<List<Product>> searchProductsByName(String query) async {
    final snapshot = await _productRef.get();

    if (snapshot.docs.isEmpty) {
      print("No products found in collection for searching name");
      return [];
    }

    return snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .where(
          (product) => product.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // READ - All Products
  Future<List<Product>> getProducts() async {
    final snapshot = await _productRef.get();

    if (snapshot.docs.isEmpty) {
      print("No products found in collection");
      return [];
    }

    return snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // UPDATE
  Future<void> updateProductByName(String name, Product product) async {
    try {
      final snapshot = await _productRef
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docRef = snapshot.docs.first.reference;
        await docRef.update(product.toJson());
      } else {
        throw Exception('Product with name "$name" not found.');
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // DELETE
  Future<void> deleteProductByName(String name) async {
    try {
      final snapshot = await _productRef.where('name', isEqualTo: name).get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete product(s) with name "$name": $e');
    }
  }
}
