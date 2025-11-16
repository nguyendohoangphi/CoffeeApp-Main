import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class CartService {
  final CollectionReference _cartRef = FirebaseFirestore.instance.collection(
    TableInDatabase.CartItemTable,
  );

  // CREATE
  Future<void> addCartItem(CartItem item) async {
    try {
      await _cartRef.add(item.toJson(item.idOrder));
    } catch (e) {
      throw Exception('Failed to add cart item: $e');
    }
  }

  // READ - All Items by Order ID
  Future<List<CartItem>> getCartItemsByOrder(String idOrder) async {
    final snapshot = await _cartRef.where('idOrder', isEqualTo: idOrder).get();

    if (snapshot.docs.isEmpty) {
      print("No cart items found for order ID: $idOrder");
      return [];
    }

    return snapshot.docs
        .map((doc) => CartItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // UPDATE - Quantity
  Future<void> updateCartItemAmount(String docId, int newAmount) async {
    try {
      await _cartRef.doc(docId).update({'amount': newAmount});
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // DELETE
  Future<void> deleteCartItem(String docId) async {
    try {
      await _cartRef.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete cart item: $e');
    }
  }
}
