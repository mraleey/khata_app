import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';
import '../services/firebase_service.dart';

class TransactionRepository {
  /// Stream for real-time transactions - works identically for both shopkeeper and customer
  /// Both users listen to the SAME path under shopkeeper's UID
  Stream<List<TransactionModel>> watchTransactions({
    required String shopkeeperUid,
    required String customerId,
  }) {
    return FirebaseService.transactionsCol(shopkeeperUid, customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromSnapshot(doc))
            .toList());
  }

  /// Adds a transaction to the SHARED ledger under shopkeeper's path
  /// BOTH shopkeeper and customer call this, but always pass shopkeeperUid
  ///
  /// Key insight: The creator's own UID is tracked separately in metadata
  /// so we know WHO added the transaction, but it's stored under shopkeeper's root
  Future<void> addTransaction({
    required String shopkeeperUid,
    required String customerId,
    required double amount,
    required TransactionType type,
    String? remarks,
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();
    final delta = type == TransactionType.cashIn ? amount : -amount;

    // Get current user info for creator metadata
    final currentUser = FirebaseService.auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final batch = FirebaseService.firestore.batch();

    // Create transaction document with creator metadata
    final txRef = FirebaseService.transactionsCol(shopkeeperUid, customerId).doc();
    batch.set(txRef, {
      'amount': amount,
      'type': type == TransactionType.cashIn ? 'in' : 'out',
      'remarks': remarks?.trim(),
      'timestamp': Timestamp.fromDate(now),
      // ✨ Creator metadata for chat-like ledger behavior
      'createdByUid': currentUser.uid,
      'createdByName': currentUser.displayName ?? 'Unknown User',
      'createdByEmail': currentUser.email ?? '',
    });

    // Update customer balance atomically
    batch.set(
      FirebaseService.customerDoc(shopkeeperUid, customerId),
      {
        'netBalance': FieldValue.increment(delta),
        'updatedAt': Timestamp.fromDate(now),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Removes a transaction and reverses the balance impact
  /// Both users can delete, but only if their email/uid matches the creator
  /// (enforced via Firestore rules)
  Future<void> deleteTransaction({
    required String shopkeeperUid,
    required String customerId,
    required TransactionModel transaction,
  }) async {
    final reverseDelta =
        transaction.isCashIn ? -transaction.amount : transaction.amount;

    final batch = FirebaseService.firestore.batch();

    // Remove transaction
    batch.delete(FirebaseService.transactionsCol(shopkeeperUid, customerId)
        .doc(transaction.transactionId));

    // Rollback balance
    batch.set(
      FirebaseService.customerDoc(shopkeeperUid, customerId),
      {
        'netBalance': FieldValue.increment(reverseDelta),
        'updatedAt': Timestamp.now(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
