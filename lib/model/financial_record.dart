import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum RecordType { income, expense, asset }

class FinancialRecord extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String note;
  final RecordType type;
  final String category;
  final String? assetSymbol; // For assets like BTC, Gold, Stocks
  final double? assetQuantity;

  const FinancialRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
    required this.category,
    this.assetSymbol,
    this.assetQuantity,
  });

  @override
  List<Object?> get props => [id, userId, amount, date, note, type, category, assetSymbol, assetQuantity];

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'type': type.name,
      'category': category,
      'assetSymbol': assetSymbol,
      'assetQuantity': assetQuantity,
    };
  }

  factory FinancialRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialRecord(
      id: doc.id,
      userId: data['userId'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'],
      type: RecordType.values.firstWhere((e) => e.name == data['type']),
      category: data['category'],
      assetSymbol: data['assetSymbol'],
      assetQuantity: (data['assetQuantity'] as num?)?.toDouble(),
    );
  }
}
