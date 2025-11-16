import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/coupon.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class CouponService {
  final CollectionReference _couponRef = FirebaseFirestore.instance.collection(
    TableInDatabase.CouponTable,
  );

  // Add
  Future<void> addSingleCouponCode(String email, String newCode) async {
    final docRef = _couponRef.doc(email);

    await docRef.update({newCode: newCode}).catchError((e) async {
      // Nếu document chưa tồn tại, tạo mới
      await docRef.set({newCode: newCode});
    });
  }

  Future<Coupon> getCoupon(String email) async {
    final doc = await _couponRef.doc(email).get();

    if (doc.exists) {
      return Coupon.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('No such document');
    }
  }

  // Delete a coupon code (field) for a user
  Future<void> deleteCouponCode(String email, String codeToDelete) async {
    final docRef = _couponRef.doc(email);

    await docRef.update({codeToDelete: FieldValue.delete()});
  }
}
