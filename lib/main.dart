import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'providers/provider_job_provider.dart';
import 'views/customer/customer_home_screen.dart';
import 'views/provider/provider_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safely initialize Firebase helper
  await FirebaseService.initializeFirebase();

  runApp(const FixNearApp());
}

class FixNearApp extends StatelessWidget {
  const FixNearApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate core services
    final apiService = ApiService();
    final notificationService = NotificationService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<RequestProvider>(
          create: (_) => RequestProvider(
            apiService: apiService,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider<ProviderJobProvider>(
          create: (_) => ProviderJobProvider(
            apiService: apiService,
            notificationService: notificationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'FixNear — Local Service Request App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainRoleSwitchWrapper(),
      ),
    );
  }
}

class MainRoleSwitchWrapper extends StatelessWidget {
  const MainRoleSwitchWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Switch dynamically based on user role (Customer vs Provider)
    if (authProvider.isCustomer) {
      return const CustomerHomeScreen();
    } else {
      return const ProviderHomeScreen();
    }
  }
}
