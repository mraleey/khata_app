import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Central service that provides configured Firebase instances
/// and enables Firestore offline persistence.
class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> init() async {
    // Enable Firestore offline persistence
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ── Collection references ──────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> usersCol() =>
      firestore.collection('users');

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersCol().doc(uid);

  static CollectionReference<Map<String, dynamic>> customersCol(String uid) =>
      userDoc(uid).collection('customers');

  static DocumentReference<Map<String, dynamic>> customerDoc(
          String uid, String customerId) =>
      customersCol(uid).doc(customerId);

  static CollectionReference<Map<String, dynamic>> transactionsCol(
          String uid, String customerId) =>
      customerDoc(uid, customerId).collection('transactions');
}
