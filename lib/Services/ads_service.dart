// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/models/ads.dart';
import 'package:coffeeapp/services/table_in_database.dart';

class AdsService {
  final CollectionReference _adsRef =
      FirebaseFirestore.instance.collection(TableInDatabase.AdsTable);

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
        return Ads.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch ad: $e');
    }
  }

  // READ - All Ads (one-time fetch)
  Future<List<Ads>> getAds() async {
    try {
      final snapshot = await _adsRef.get();

      if (snapshot.docs.isEmpty) {
        print("No ads found (collection might not exist or is empty)");
        return [];
      }

      return snapshot.docs
          .map((doc) => Ads.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception("Failed to load ads: $e");
    }
  }

  // READ - All Ads by Partial Name
  Future<List<Ads>> getAdsByPartialName(String query) async {
    try {
      final snapshot = await _adsRef.get();

      if (snapshot.docs.isEmpty) {
        print("No ads found for query: $query");
        return [];
      }

      return snapshot.docs
          .map((doc) => Ads.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((ad) =>
              ad.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception("Failed to search ads: $e");
    }
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
