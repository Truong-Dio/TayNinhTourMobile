import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/auth_api_service.dart';
import 'data/datasources/tour_guide_api_service.dart';
import 'data/datasources/user_api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/tour_guide_provider.dart';
import 'presentation/providers/user_provider.dart';

import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/user/user_main_page.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final storage = const FlutterSecureStorage();
  final logger = Logger();
  final dioClient = DioClient(storage: storage, logger: logger);
  
  // Initialize API services
  final authApiService = AuthApiService(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );
  final tourGuideApiService = TourGuideApiService(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );
  final userApiService = UserApiService(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );
  
  runApp(TayNinhTourApp(
    storage: storage,
    logger: logger,
    authApiService: authApiService,
    tourGuideApiService: tourGuideApiService,
    userApiService: userApiService,
  ));
}

class TayNinhTourApp extends StatelessWidget {
  final FlutterSecureStorage storage;
  final Logger logger;
  final AuthApiService authApiService;
  final TourGuideApiService tourGuideApiService;
  final UserApiService userApiService;
  
  const TayNinhTourApp({
    super.key,
    required this.storage,
    required this.logger,
    required this.authApiService,
    required this.tourGuideApiService,
    required this.userApiService,
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
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            userApiService: userApiService,
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
          // Check user role and route to appropriate dashboard
          if (authProvider.user!.role == AppConstants.tourGuideRole) {
            return const DashboardPage();
          } else if (authProvider.user!.role == AppConstants.userRole) {
            return const UserMainPage();
          } else {
            // User doesn't have supported role
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
                      'Vai trò người dùng không được hỗ trợ',
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
