import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';
import '../services/firebase_service.dart';
import 'customer_repository.dart';

class TransactionRepository {
  final CustomerRepository _customerRepo;

  TransactionRepository(this._customerRepo);

  Stream<List<TransactionModel>> watchTransactions(
      String uid, String customerId) {
    return FirebaseService.transactionsCol(uid, customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromSnapshot(doc))
            .toList());
  }

  Future<void> addTransaction({
    required String uid,
    required String customerId,
    required double amount,
    required TransactionType type,
    String? remarks,
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();
    final delta = type == TransactionType.cashIn ? amount : -amount;

    final batch = FirebaseService.firestore.batch();

    // Add transaction document
    final txRef =
        FirebaseService.transactionsCol(uid, customerId).doc();
    batch.set(txRef, {
      'amount': amount,
      'type': type == TransactionType.cashIn ? 'in' : 'out',
      'remarks': remarks?.trim(),
      'timestamp': Timestamp.fromDate(now),
    });

    // Update customer's netBalance and updatedAt
    batch.update(FirebaseService.customerDoc(uid, customerId), {
      'netBalance': FieldValue.increment(delta),
      'updatedAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  Future<void> deleteTransaction({
    required String uid,
    required String customerId,
    required TransactionModel transaction,
  }) async {
    // Reverse the balance effect
    final reverseDelta =
        transaction.isCashIn ? -transaction.amount : transaction.amount;

    final batch = FirebaseService.firestore.batch();

    batch.delete(FirebaseService.transactionsCol(uid, customerId)
        .doc(transaction.transactionId));

    batch.update(FirebaseService.customerDoc(uid, customerId), {
      'netBalance': FieldValue.increment(reverseDelta),
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();
  }
}
