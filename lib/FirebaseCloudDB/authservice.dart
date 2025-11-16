import 'package:coffeeapp/Entity/userdetail.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference _userRef = FirebaseFirestore.instance.collection(
    TableInDatabase.UserDetailTable,
  );

  Future<List<UserDetail>> getAllUsers() async {
    final snapshot = await _userRef.get();

    if (snapshot.docs.isEmpty) {
      print("No users found (collection might not exist or is empty)");
      return [];
    }

    return snapshot.docs
        .map((doc) => UserDetail.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUserByEmail(String email) async {
    await _userRef.doc(email).delete();
  }

  Future<void> updateUserPointAndRank(
    String email,
    int newPoint,
    String? newRank,
  ) async {
    final Map<String, dynamic> updates = {'point': newPoint};
    if (newRank != null) {
      updates['rank'] = newRank;
    }

    await _userRef.doc(email).update(updates);
  }

  Future<void> updateUserPasswordInFirestore(
    String email,
    String newPassword,
  ) async {
    final querySnapshot = await _userRef.where('email', isEqualTo: email).get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'password': newPassword});
    }
  }

  // Sign up user
  Future<void> registerWithEmail({required UserDetail user}) async {
    await _userRef.doc(user.email).set(user.toJson());
  }

  // Get user profile from Firestore
  Future<UserDetail?> getUserDetail(String email) async {
    final doc = await _userRef.doc(email).get();
    if (doc.exists) {
      return UserDetail.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
