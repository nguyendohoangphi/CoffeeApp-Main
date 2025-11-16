import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class FavouriteService {
  final CollectionReference _favRef = FirebaseFirestore.instance.collection(
    TableInDatabase.ProductFavouriteTable,
  );

  // Composite doc ID: email_productName
  String _docId(String email, String productName) => '${email}_$productName';

  // Add to favourites
  Future<void> addFavourite(ProductFavourite fav) async {
    try {
      await _favRef.doc(_docId(fav.email, fav.productName)).set(fav.toJson());
    } catch (e) {
      throw Exception('Failed to add to favourites: $e');
    }
  }

  // Remove from favourites
  Future<void> removeFavourite(String email, String productName) async {
    try {
      await _favRef.doc(_docId(email, productName)).delete();
    } catch (e) {
      throw Exception('Failed to remove from favourites: $e');
    }
  }

  // Check if a product is favourited
  Future<bool> isFavourite(String email, String productName) async {
    final doc = await _favRef.doc(_docId(email, productName)).get();
    return doc.exists;
  }

  // Get all favourites for a user
  Future<List<ProductFavourite>> getFavouritesByEmail(String email) async {
    final snapshot = await _favRef.where('email', isEqualTo: email).get();

    if (snapshot.docs.isEmpty) {
      print("No favourites found for email: $email");
      return [];
    }

    return snapshot.docs
        .map(
          (doc) =>
              ProductFavourite.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
