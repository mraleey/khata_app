import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { cashIn, cashOut }

class TransactionModel {
  final String transactionId;
  final double amount;
  final TransactionType type;
  final String? remarks;
  final DateTime timestamp;
  
  // Creator metadata for chat-like ledger tracking
  final String createdByUid;
  final String createdByName;
  final String createdByEmail;

  TransactionModel({
    required this.transactionId,
    required this.amount,
    required this.type,
    this.remarks,
    required this.timestamp,
    required this.createdByUid,
    required this.createdByName,
    required this.createdByEmail,
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
      createdByUid: map['createdByUid'] as String? ?? '',
      createdByName: map['createdByName'] as String? ?? 'Unknown',
      createdByEmail: map['createdByEmail'] as String? ?? '',
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
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'createdByEmail': createdByEmail,
    };
  }
}
