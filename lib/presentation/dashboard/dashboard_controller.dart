import 'dart:async';
import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../app/routes/app_routes.dart';
import '../../core/utils/session_manager.dart';

class DashboardController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();

  final customers = <CustomerModel>[].obs;
  final filteredCustomers = <CustomerModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  StreamSubscription<List<CustomerModel>>? _customerSub;

  String get uid => _authRepo.currentUid ?? '';

  double get totalCashIn => customers.fold(
      0, (sum, c) => c.netBalance > 0 ? sum + c.netBalance : sum);

  double get totalCashOut => customers.fold(
      0, (sum, c) => c.netBalance < 0 ? sum + c.netBalance.abs() : sum);

  double get netTotal => totalCashIn - totalCashOut;

  @override
  void onInit() {
    super.onInit();
    _listenToCustomers();
    debounce(searchQuery, (_) => _filterCustomers(),
        time: const Duration(milliseconds: 300));
    ever(customers, (_) => _filterCustomers());
  }

  void _listenToCustomers() {
    _customerSub = _customerRepo.watchCustomers(uid).listen(
      (list) {
        customers.assignAll(list);
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );
  }

  void _filterCustomers() {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      filteredCustomers.assignAll(customers);
      return;
    }
    filteredCustomers.assignAll(customers.where((c) {
      return c.name.toLowerCase().contains(query) ||
          (c.phone?.contains(query) ?? false);
    }));
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  void goToAddCustomer() => Get.toNamed(AppRoutes.ADD_CUSTOMER);

  void goToCustomerDetail(CustomerModel customer) =>
      Get.toNamed(AppRoutes.CUSTOMER_DETAIL, arguments: customer);

  Future<void> signOut() async {
    await _authRepo.signOut();
    SessionManager.clearSession();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    _customerSub?.cancel();
    super.onClose();
  }
}
