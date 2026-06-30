import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';
import '../services/firebase_service.dart';

class CustomerRepository {
  Stream<List<CustomerModel>> watchCustomers(String uid) {
    return FirebaseService.customersCol(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromSnapshot(doc))
            .toList());
  }

  Stream<List<CustomerModel>> watchSharedCustomers(String email) {
    if (email.trim().isEmpty) return Stream.value([]);
    return FirebaseService.firestore
        .collectionGroup('customers')
        .where('email', isEqualTo: email.trim())
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromSnapshot(doc))
            .toList());
  }

  Future<void> addCustomer({
    required String uid,
    required String name,
    required String shopkeeperName,
    String? phone,
    String? email,
    double initialBalance = 0,
  }) async {
    final colRef = FirebaseService.customersCol(uid);
    final now = DateTime.now();

    // If there's an initial balance, create both the customer and
    // a matching opening transaction atomically.
    final batch = FirebaseService.firestore.batch();

    final customerRef = colRef.doc();
    batch.set(customerRef, {
      'name': name.trim(),
      'phone': phone?.trim(),
      'email': email?.trim(),
      'shopkeeperUid': uid,
      'shopkeeperName': shopkeeperName,
      'netBalance': initialBalance,
      'updatedAt': Timestamp.fromDate(now),
    });

    if (initialBalance != 0) {
      final txRef = FirebaseService.transactionsCol(uid, customerRef.id).doc();
      batch.set(txRef, {
        'amount': initialBalance.abs(),
        'type': initialBalance > 0 ? 'in' : 'out',
        'remarks': 'Opening balance',
        'timestamp': Timestamp.fromDate(now),
      });
    }

    await batch.commit();
  }

  Future<void> deleteCustomer(String uid, String customerId) async {
    // Delete all transactions first, then the customer document.
    final txSnapshot = await FirebaseService.transactionsCol(uid, customerId).get();
    final batch = FirebaseService.firestore.batch();
    for (final doc in txSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(FirebaseService.customerDoc(uid, customerId));
    await batch.commit();
  }

  /// Called after every transaction to keep netBalance in sync.
  Future<void> updateNetBalance({
    required String uid,
    required String customerId,
    required double delta, // positive for cash-in, negative for cash-out
  }) async {
    await FirebaseService.customerDoc(uid, customerId).update({
      'netBalance': FieldValue.increment(delta),
      'updatedAt': Timestamp.now(),
    });
  }
}
