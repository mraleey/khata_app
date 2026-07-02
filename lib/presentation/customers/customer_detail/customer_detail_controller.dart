import 'dart:async';
import 'package:get/get.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../app/routes/app_routes.dart';

class CustomerDetailController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final TransactionRepository _txRepo = Get.find<TransactionRepository>();

  late final CustomerModel customer;

  final transactions = <TransactionModel>[].obs;
  final isLoading = true.obs;
  final isDeletingTransaction = false.obs;

  StreamSubscription<List<TransactionModel>>? _txSub;
  StreamSubscription<List<CustomerModel>>? _customerSub;

  final currentBalance = 0.0.obs;

  String get uid => _authRepo.currentUid ?? '';

  @override
  void onInit() {
    super.onInit();
    customer = Get.arguments as CustomerModel;
    currentBalance.value = customer.netBalance;
    _listenToTransactions();
    _listenToCustomerBalance();
  }

  void _listenToTransactions() {
    _txSub =
        _txRepo.watchTransactions(
          shopkeeperUid: customer.shopkeeperUid,
          customerId: customer.customerId,
        ).listen((list) {
      transactions.assignAll(list);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
  }

  void _listenToCustomerBalance() {
    final stream = customer.shopkeeperUid == uid 
      ? _customerRepo.watchCustomersAsShopkeeper(uid) 
      : _customerRepo.watchCustomersAsCustomer(_authRepo.currentUser?.email ?? '');

    _customerSub = stream.listen((list) {
      final updated =
          list.where((c) => c.customerId == customer.customerId).firstOrNull;
      if (updated != null) currentBalance.value = updated.netBalance;
    });
  }

  void goToAddTransaction(TransactionType type) =>
      Get.toNamed(AppRoutes.ADD_TRANSACTION,
          arguments: {'customer': customer, 'type': type});

  Future<void> deleteTransaction(TransactionModel tx) async {
    isDeletingTransaction.value = true;
    try {
      await _txRepo.deleteTransaction(
        shopkeeperUid: customer.shopkeeperUid,
        customerId: customer.customerId,
        transaction: tx,
      );
    } finally {
      isDeletingTransaction.value = false;
    }
  }

  @override
  void onClose() {
    _txSub?.cancel();
    _customerSub?.cancel();
    super.onClose();
  }
}
