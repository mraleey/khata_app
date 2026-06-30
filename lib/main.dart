import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize GetStorage for local session management
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Determine initial route:
  // Require BOTH a valid local session AND an authenticated Firebase user.
  // This prevents an empty UID reaching the dashboard if Firebase token
  // has been invalidated (e.g. password reset, account deletion).



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final hasValidSession = SessionManager.isSessionValid() && firebaseUser != null;
  final initialRoute = hasValidSession ? AppRoutes.DASHBOARD : AppRoutes.LOGIN;
  if (hasValidSession) {
    // Refresh sliding window so 30-day timer resets on each app open
    SessionManager.refreshSession();
  } else if (firebaseUser == null) {
    // No Firebase user — clear any stale local session
    SessionManager.clearSession();
  }
    return GetMaterialApp(
      title: 'Digital Khata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
