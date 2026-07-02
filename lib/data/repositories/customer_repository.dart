import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../services/firebase_service.dart';

class CustomerRepository {

  /// Stream for Shopkeeper App: Watches all local customer items
  Stream<List<CustomerModel>> watchCustomersAsShopkeeper(String uid) {
    return FirebaseService.customersCol(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CustomerModel.fromSnapshot(doc))
        .toList());
  }

  /// Stream for Customer App: Searches globally across all customer documents for matching email
  Stream<List<CustomerModel>> watchCustomersAsCustomer(String email) {
    final sanitizedEmail = email.trim().toLowerCase();
    if (sanitizedEmail.isEmpty) return Stream.value([]);

    return FirebaseService.firestore
        .collectionGroup('customers')
        .where('email', isEqualTo: sanitizedEmail)
        .snapshots()
        .map((snapshot) {
      final customers = snapshot.docs
          .map((doc) => CustomerModel.fromSnapshot(doc))
          .toList();

      // In-memory sorting avoids requiring complex Cloud Firestore multi-field indexes
      customers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return customers;
    });
  }

  /// Atomically creates a customer and logs an opening balance transaction
  Future<void> addCustomer({
    required String uid,
    required String name,
    required String shopkeeperName,
    String? phone,
    String? email,
    double initialBalance = 0,
  }) async {
    final now = DateTime.now();
    final batch = FirebaseService.firestore.batch();
    final customerRef = FirebaseService.customersCol(uid).doc();

    batch.set(customerRef, {
      'name': name.trim(),
      'phone': phone?.trim(),
      'email': email?.trim().toLowerCase(),
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

  /// Cleans out all nested transactions before stripping the main customer document
  Future<void> deleteCustomer(String shopkeeperUid, String customerId) async {
    final txSnapshot = await FirebaseService.transactionsCol(shopkeeperUid, customerId).get();
    final batch = FirebaseService.firestore.batch();

    for (final doc in txSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(FirebaseService.customerDoc(shopkeeperUid, customerId));
    await batch.commit();
  }
}