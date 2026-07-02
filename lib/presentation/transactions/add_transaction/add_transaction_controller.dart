import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class AddTransactionController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final TransactionRepository _txRepo = Get.find<TransactionRepository>();

  final amountCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late final CustomerModel customer;
  final selectedType = TransactionType.cashIn.obs;
  final selectedDate = DateTime.now().obs;
  final isLoading = false.obs;

  String get uid => _authRepo.currentUid ?? '';
  bool get isCashIn => selectedType.value == TransactionType.cashIn;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    customer = args['customer'] as CustomerModel;
    selectedType.value = args['type'] as TransactionType;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A56DB)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final now = DateTime.now();
      selectedDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
      );
    }
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final amount = double.parse(amountCtrl.text.trim());
      await _txRepo.addTransaction(
        uid: uid,
        customerId: customer.customerId,
        amount: amount,
        type: selectedType.value,
        remarks: remarksCtrl.text.isEmpty ? null : remarksCtrl.text,
        timestamp: selectedDate.value,
      );
      Get.back();
      Get.snackbar(
        'Transaction Saved',
        '${isCashIn ? "Cash In" : "Cash Out"} of RS ${amount.toStringAsFixed(0)} recorded.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            isCashIn ? const Color(0xFF0E9F6E) : const Color(0xFFE02424),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save transaction. Please try again.',
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
    amountCtrl.dispose();
    remarksCtrl.dispose();
    super.onClose();
  }
}
