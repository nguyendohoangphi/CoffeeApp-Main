import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/ads.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class AdsService {
  final CollectionReference _adsRef = FirebaseFirestore.instance.collection(
    TableInDatabase.AdsTable,
  );

  // CREATE
  Future<void> createAd(Ads ad) async {
    try {
      await _adsRef.doc(ad.id).set(ad.toJson());
    } catch (e) {
      throw Exception('Failed to create ad: $e');
    }
  }

  // READ - Single Ad
  Future<Ads?> getAdById(String id) async {
    try {
      final doc = await _adsRef.doc(id).get();
      if (doc.exists) {
        return Ads.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch ad: $e');
    }
  }

  // READ - All Ads (one-time fetch)
  Future<List<Ads>> getAds() async {
    final snapshot = await _adsRef.get();

    if (snapshot.docs.isEmpty) {
      print("No ads found (collection might not exist or is empty)");
      return [];
    }

    return snapshot.docs
        .map((doc) => Ads.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // READ - All Ads by Partial Name (one-time fetch)
  Future<List<Ads>> getAdsByPartialName(String query) async {
    final snapshot = await _adsRef.get();

    if (snapshot.docs.isEmpty) {
      print(
        "No ads found for query: $query (collection might not exist or is empty)",
      );
      return [];
    }

    return snapshot.docs
        .map((doc) => Ads.fromJson(doc.data() as Map<String, dynamic>))
        .where((ad) => ad.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // UPDATE
  Future<void> updateAd(Ads ad) async {
    try {
      await _adsRef.doc(ad.id).update(ad.toJson());
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  // DELETE
  Future<void> deleteAd(String id) async {
    try {
      await _adsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }
}
