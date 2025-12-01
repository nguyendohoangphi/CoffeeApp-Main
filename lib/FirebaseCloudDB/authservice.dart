import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Entity/userdetail.dart';
import '../FirebaseCloudDB/tableindatabase.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _users =
  FirebaseFirestore.instance.collection(TableInDatabase.UserDetailTable);

  /// -------------------- REGISTER --------------------
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // save data user vào Firestore
      await _users.doc(uid).set({
        "uid": uid,
        "username": username,
        "email": email,
        "photoURL": "assets/images/drink/user.png",
        "rank": "Hạng đồng",
        "point": 0,
        "role": "user",
      });

      return "OK";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }


  /// -------------------- LOGIN --------------------
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return "OK";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// -------------------- GET PROFILE --------------------
  Future<UserDetail?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return null;

    return UserDetail.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// -------------------- LOGOUT --------------------
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// -------------------- GET ALL --------------------
  Future<List<UserDetail>> getAllUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs
        .map((d) => UserDetail.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  /// -------------------- UPDATE POINT + RANK --------------------
  Future<void> updateUserPointAndRank(
      String uid, int point, String rank) async {
    await _users.doc(uid).update({
      "point": point,
      "rank": rank,
    });
  }

  /// -------------------- UPDATE PASSWORD (Firebase Auth) --------------------
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser!.updatePassword(newPassword);
  }

  /// -------------------- DELETE USER (Firestore only) --------------------
  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  /// -------------------- FORGOT PASS --------------------
  Future<String> sendResetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Email khôi phục đã được gửi!";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Lỗi không xác định";
    }
  }

}
