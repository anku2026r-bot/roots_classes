import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/network/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'controllers/auth_controller.dart';
import 'controllers/classes_controller.dart';
import 'controllers/test_series_controller.dart';
import 'services/auth_service.dart';
import 'services/classes_api_service.dart';
import 'services/session_service.dart';
import 'services/test_series_api_service.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/widgets/app_logo.dart';
import 'views/widgets/global_tap_effect.dart';

import 'controllers/home_controller.dart';
import 'services/home_api_service.dart';

import 'services/admin_service.dart';
import 'services/course_service.dart';
import 'services/payment_service.dart';
import 'services/test_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.printStartupBanner();
  AppLogger.i('🚀 Starting Roots Classes Application...', tag: 'STARTUP');

  // Initialize persistent services
  final prefs = await SharedPreferences.getInstance();
  final sessionService = SessionService(prefs);
  AppLogger.i('💾 SharedPreferences & SessionService initialized', tag: 'STARTUP');

  // Initialize API client & feature services (Non-Firebase, API-driven)
  final apiClient = ApiClient(sessionService: sessionService);
  final authService = ApiAuthService(apiClient, prefs, sessionService);
  final classesApiService = ClassesApiService(apiClient, prefs);
  final testSeriesApiService = TestSeriesApiService(apiClient, prefs);
  final homeApiService = HomeApiService(apiClient, prefs);

  // New Backend Services mapping to Backend API Guide
  final courseService = CourseService(apiClient, prefs);
  final testService = TestService(apiClient);
  final paymentService = PaymentService(apiClient);
  final adminService = AdminService(apiClient, sessionService);

  AppLogger.i('🌐 ApiClient initialized with Base URL: ${ApiConstants.baseUrl}', tag: 'NETWORK');

  // Initialize ViewModels
  final authController = AuthController(
    authService: authService,
    sessionService: sessionService,
  );
  final classesController = ClassesController(apiService: classesApiService);
  final testSeriesController = TestSeriesController(apiService: testSeriesApiService);
  final homeController = HomeController(
    homeApiService: homeApiService,
    classesApiService: classesApiService,
  );

  // Initialize session state / check auto-login
  await authController.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<SessionService>.value(value: sessionService),
        Provider<SharedPreferences>.value(value: prefs),
        Provider<AuthService>.value(value: authService),
        Provider<CourseService>.value(value: courseService),
        Provider<TestService>.value(value: testService),
        Provider<PaymentService>.value(value: paymentService),
        Provider<AdminService>.value(value: adminService),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<HomeController>.value(value: homeController),
        ChangeNotifierProvider<ClassesController>.value(value: classesController),
        ChangeNotifierProvider<TestSeriesController>.value(value: testSeriesController),
      ],
      child: const RootsClassesApp(),
    ),
  );
}

class RootsClassesApp extends StatelessWidget {
  const RootsClassesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthGate(),
      builder: (context, child) {
        return GlobalTapEffect(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// The AuthGate decides which screen to show based on real session state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(iconSize: 64),
              SizedBox(height: 24),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
