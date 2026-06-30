import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { cashIn, cashOut }

class TransactionModel {
  final String transactionId;
  final double amount;
  final TransactionType type;
  final String? remarks;
  final DateTime timestamp;

  TransactionModel({
    required this.transactionId,
    required this.amount,
    required this.type,
    this.remarks,
    required this.timestamp,
  });

  bool get isCashIn => type == TransactionType.cashIn;

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: id,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'in'
          ? TransactionType.cashIn
          : TransactionType.cashOut,
      remarks: map['remarks'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  factory TransactionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type == TransactionType.cashIn ? 'in' : 'out',
      'remarks': remarks,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
