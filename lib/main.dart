import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/auth_api_service.dart';
import 'data/datasources/tour_guide_api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/tour_guide_provider.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final storage = const FlutterSecureStorage();
  final logger = Logger();
  final dioClient = DioClient(storage: storage, logger: logger);
  
  // Initialize API services
  final authApiService = AuthApiService(dioClient.dio);
  final tourGuideApiService = TourGuideApiService(dioClient.dio);
  
  runApp(TayNinhTourApp(
    storage: storage,
    logger: logger,
    authApiService: authApiService,
    tourGuideApiService: tourGuideApiService,
  ));
}

class TayNinhTourApp extends StatelessWidget {
  final FlutterSecureStorage storage;
  final Logger logger;
  final AuthApiService authApiService;
  final TourGuideApiService tourGuideApiService;
  
  const TayNinhTourApp({
    super.key,
    required this.storage,
    required this.logger,
    required this.authApiService,
    required this.tourGuideApiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authApiService: authApiService,
            storage: storage,
            logger: logger,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TourGuideProvider(
            tourGuideApiService: tourGuideApiService,
            logger: logger,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (authProvider.isAuthenticated && authProvider.user != null) {
          // Check if user has Tour Guide role
          if (authProvider.user!.role == AppConstants.tourGuideRole) {
            return const DashboardPage();
          } else {
            // User doesn't have Tour Guide role
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quyền truy cập bị từ chối',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ứng dụng này chỉ dành cho Hướng dẫn viên',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => authProvider.logout(),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        
        return const LoginPage();
      },
    );
  }
}
