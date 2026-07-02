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

  // 💡 RENAME CLARIFICATION:
  // Changed 'uid' to 'shopkeeperUid' because even if a Customer creates an entry,
  // they must point to the Shopkeeper's root collection node for it to sync like a chat.

  static CollectionReference<Map<String, dynamic>> customersCol(String shopkeeperUid) =>
      userDoc(shopkeeperUid).collection('customers');

  static DocumentReference<Map<String, dynamic>> customerDoc(
      String shopkeeperUid, String customerId) =>
      customersCol(shopkeeperUid).doc(customerId);

  static CollectionReference<Map<String, dynamic>> transactionsCol(
      String shopkeeperUid, String customerId) =>
      customerDoc(shopkeeperUid, customerId).collection('transactions');

  // Entries collection (replaces transactions with collaboration features)
  static CollectionReference<Map<String, dynamic>> entriesCol(
      String shopkeeperUid, String customerId) =>
      customerDoc(shopkeeperUid, customerId).collection('entries');

  static DocumentReference<Map<String, dynamic>> entryDoc(
      String shopkeeperUid, String customerId, String entryId) =>
      entriesCol(shopkeeperUid, customerId).doc(entryId);

  // Comments sub-collection under entries
  static CollectionReference<Map<String, dynamic>> commentsCol(
      String shopkeeperUid, String customerId, String entryId) =>
      entryDoc(shopkeeperUid, customerId, entryId).collection('comments');

  static DocumentReference<Map<String, dynamic>> commentDoc(
      String shopkeeperUid,
      String customerId,
      String entryId,
      String commentId,
      ) =>
      commentsCol(shopkeeperUid, customerId, entryId).doc(commentId);
}