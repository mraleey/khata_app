import 'package:get/get.dart';

import '../../presentation/auth/login/login_controller.dart';
import '../../presentation/auth/login/login_view.dart';
import '../../presentation/auth/phone_auth/phone_auth_controller.dart';
import '../../presentation/auth/phone_auth/phone_auth_view.dart';
import '../../presentation/dashboard/dashboard_controller.dart';
import '../../presentation/dashboard/dashboard_view.dart';
import '../../presentation/customers/add_customer/add_customer_controller.dart';
import '../../presentation/customers/add_customer/add_customer_view.dart';
import '../../presentation/customers/customer_detail/customer_detail_controller.dart';
import '../../presentation/customers/customer_detail/customer_detail_view.dart';
import '../../presentation/transactions/add_transaction/add_transaction_controller.dart';
import '../../presentation/transactions/add_transaction/add_transaction_view.dart';

import 'app_routes.dart';

abstract class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: AppRoutes.PHONE_AUTH,
      page: () => const PhoneAuthView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PhoneAuthController())),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DashboardController())),
    ),
    GetPage(
      name: AppRoutes.ADD_CUSTOMER,
      page: () => const AddCustomerView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddCustomerController())),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_DETAIL,
      page: () => const CustomerDetailView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CustomerDetailController())),
    ),
    GetPage(
      name: AppRoutes.ADD_TRANSACTION,
      page: () => const AddTransactionView(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AddTransactionController())),
    ),
  ];
}
