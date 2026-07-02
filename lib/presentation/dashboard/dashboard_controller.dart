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

  final myCustomers = <CustomerModel>[].obs;
  final sharedCustomers = <CustomerModel>[].obs;
  final filteredCustomers = <CustomerModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  StreamSubscription<List<CustomerModel>>? _customerSub;
  StreamSubscription<List<CustomerModel>>? _sharedCustomerSub;

  List<CustomerModel> get customers {
    final list = [...myCustomers, ...sharedCustomers];
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  String get uid => _authRepo.currentUid ?? '';

  double get totalCashIn => customers.fold(0, (sum, c) {
        final isOwner = c.shopkeeperUid == uid;
        final effectiveBalance = isOwner ? c.netBalance : -c.netBalance;
        return effectiveBalance > 0 ? sum + effectiveBalance : sum;
      });

  double get totalCashOut => customers.fold(0, (sum, c) {
        final isOwner = c.shopkeeperUid == uid;
        final effectiveBalance = isOwner ? c.netBalance : -c.netBalance;
        return effectiveBalance < 0 ? sum + effectiveBalance.abs() : sum;
      });

  double get netTotal => totalCashIn - totalCashOut;

  @override
  void onInit() {
    super.onInit();
    _listenToCustomers();
    debounce(searchQuery, (_) => _filterCustomers(),
        time: const Duration(milliseconds: 300));
    ever(myCustomers, (_) => _filterCustomers());
    ever(sharedCustomers, (_) => _filterCustomers());
  }

  void _listenToCustomers() {
    _customerSub = _customerRepo.watchCustomersAsShopkeeper(uid).listen(
      (list) {
        myCustomers.assignAll(list);
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );

    final email = _authRepo.currentUser?.email ?? '';
    if (email.isNotEmpty) {
      _sharedCustomerSub = _customerRepo.watchCustomersAsCustomer(email).listen(
        (list) {
          sharedCustomers.assignAll(list);
        },
      );
    }
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
    _sharedCustomerSub?.cancel();
    super.onClose();
  }
}
