import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/FirebaseCloudDB/tableindatabase.dart';

class TableStatusService {
  final CollectionReference _tableRef = FirebaseFirestore.instance.collection(
    TableInDatabase.TableStatusTable,
  );

  // Create new table status
  Future<void> createTable(TableStatus table) async {
    try {
      await _tableRef.doc(table.id).set(table.toJson());
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String id, bool isBooked) async {
    try {
      await _tableRef.doc(id).update({'isBooked': isBooked});
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Get all tables
  Future<List<TableStatus>> getTableStatusList() async {
    final snapshot = await _tableRef.get();

    if (snapshot.docs.isEmpty) {
      print("No table statuses found (collection empty)");
      return [];
    }

    return snapshot.docs
        .map((doc) => TableStatus.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Get only available or booked tables
  Future<List<TableStatus>> getTablesByBookingStatus(bool isBooked) async {
    final snapshot = await _tableRef
        .where('isBooked', isEqualTo: isBooked)
        .get();

    if (snapshot.docs.isEmpty) {
      print("No tables found with isBooked = $isBooked");
      return [];
    }

    return snapshot.docs
        .map((doc) => TableStatus.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Delete table
  Future<void> deleteTable(String id) async {
    try {
      await _tableRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }
}
