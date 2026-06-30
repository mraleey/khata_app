import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/session_manager.dart';

class PhoneAuthController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final phoneFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final keepLoggedIn = true.obs;
  final resendTimer = 0.obs;

  String _verificationId = '';

  Future<void> sendOtp() async {
    if (!phoneFormKey.currentState!.validate()) return;
    isLoading.value = true;

    await _authRepo.verifyPhoneNumber(
      phoneNumber: phoneCtrl.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android — use credential directly, never null fields
        final userCredential = await _authRepo.signInWithCredential(credential);
        await _onSignInSuccess(userCredential.user!);
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        _showError(e.message ?? 'Verification failed. Check the phone number.');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        isOtpSent.value = true;
        isLoading.value = false;
        _startResendTimer();
        Get.snackbar(
          'OTP Sent',
          'A 6-digit code has been sent to ${phoneCtrl.text}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0E9F6E),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        isLoading.value = false;
      },
    );
  }

  Future<void> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final credential =
          await _authRepo.signInWithOtp(_verificationId, otpCtrl.text.trim());
      await _onSignInSuccess(credential.user!);
    } on FirebaseAuthException catch (e) {
      _showError(e.code == 'invalid-verification-code'
          ? 'Invalid OTP. Please check and try again.'
          : e.message ?? 'Verification failed.');
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _onSignInSuccess(User user) async {
    await _authRepo.createOrUpdateUserRecord(user);
    SessionManager.saveSession(
      userId: user.uid,
      keepLoggedIn: keepLoggedIn.value,
    );
    Get.offAllNamed(AppRoutes.DASHBOARD);
  }

  void _startResendTimer() {
    resendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
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

  @override
  void onClose() {
    phoneCtrl.dispose();
    otpCtrl.dispose();
    super.onClose();
  }
}
