import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // ── FIX: Added the webClientId from your google-services.json ────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '311937685864-3bbeo6fpnopphsu9dugko139ij9o4d5r.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password ───────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    return _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // ── Phone / OTP ────────────────────────────────────────────────────────────

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Sign in using a PhoneAuthCredential directly (used by auto-verification on Android).
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return _auth.signInWithCredential(credential);
  }

  /// Sign in using a verificationId + SMS code (used by manual OTP entry).
  Future<UserCredential> signInWithOtp(
      String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  // ── Firestore user record ──────────────────────────────────────────────────

  Future<void> createOrUpdateUserRecord(User user) async {
    final docRef = FirebaseService.userDoc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await docRef.set(newUser.toMap());
    } else {
      await docRef.update({'lastLogin': Timestamp.now()});
    }
  }

  Future<void> signOut() async {
    // ── Update: Also disconnect from Google so user can switch accounts on next sign-in ──
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}