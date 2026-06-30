import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';

class AddCustomerController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final balanceCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final balanceType = 'cashIn'.obs; // 'cashIn' or 'cashOut'

  String get uid => _authRepo.currentUid ?? '';

  void setBalanceType(String type) => balanceType.value = type;

  Future<void> addCustomer() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    double initialBalance = 0;
    final balanceText = balanceCtrl.text.trim();
    if (balanceText.isNotEmpty) {
      final amount = double.tryParse(balanceText) ?? 0;
      initialBalance = balanceType.value == 'cashIn' ? amount : -amount;
    }

    try {
      await _customerRepo.addCustomer(
        uid: uid,
        name: nameCtrl.text,
        phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
        initialBalance: initialBalance,
      );
      Get.back();
      Get.snackbar(
        'Customer Added',
        '${nameCtrl.text} has been added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0E9F6E),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add customer. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE02424),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    balanceCtrl.dispose();
    super.onClose();
  }
}
