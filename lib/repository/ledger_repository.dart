import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/financial_record.dart';

class LedgerRepository {
  final FirebaseFirestore _firestore;

  LedgerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _recordsCollection => _firestore.collection('records');

  Future<void> addRecord(FinancialRecord record) async {
    await _recordsCollection.add(record.toDocument());
  }

  Stream<List<FinancialRecord>> getRecords(String userId) {
    return _recordsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FinancialRecord.fromDocument(doc)).toList();
    });
  }

  Future<void> deleteRecord(String recordId) async {
    await _recordsCollection.doc(recordId).delete();
  }

  Future<void> updateRecord(FinancialRecord record) async {
    await _recordsCollection.doc(record.id).update(record.toDocument());
  }
}
