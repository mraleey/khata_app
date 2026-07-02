import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/services/firebase_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Firebase service init
    FirebaseService.init();

    // Repositories – permanent singletons
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<CustomerRepository>(CustomerRepository(), permanent: true);
    Get.put<TransactionRepository>(
      TransactionRepository(),
      permanent: true,
    );
  }
}
