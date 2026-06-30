import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/session_manager.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final keepLoggedIn = true.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleKeepLoggedIn(bool? value) =>
      keepLoggedIn.value = value ?? keepLoggedIn.value;

  Future<void> signInWithEmail() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final credential = await _authRepo.signInWithEmail(
        emailCtrl.text,
        passwordCtrl.text,
      );
      final user = credential.user!;
      await _authRepo.createOrUpdateUserRecord(user);
      SessionManager.saveSession(
        userId: user.uid,
        keepLoggedIn: keepLoggedIn.value,
      );
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      _showError(_authErrorMessage(e.code));
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final credential = await _authRepo.registerWithEmail(
        emailCtrl.text,
        passwordCtrl.text,
      );
      final user = credential.user!;
      await _authRepo.createOrUpdateUserRecord(user);
      SessionManager.saveSession(
        userId: user.uid,
        keepLoggedIn: keepLoggedIn.value,
      );
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      _showError(_authErrorMessage(e.code));
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void goToPhoneAuth() => Get.toNamed(AppRoutes.PHONE_AUTH);

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final credential = await _authRepo.signInWithGoogle();
      if (credential != null && credential.user != null) {
        final user = credential.user!;
        await _authRepo.createOrUpdateUserRecord(user);
        SessionManager.saveSession(
          userId: user.uid,
          keepLoggedIn: keepLoggedIn.value,
        );
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);

      _showError(_authErrorMessage(e.code));
    } catch (e) {
      print(e.toString());
      _showError('Google sign in failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE02424),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
