// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import 'package:tayninh_tour_mobile/main.dart';
import 'package:tayninh_tour_mobile/core/network/dio_client.dart';
import 'package:tayninh_tour_mobile/data/datasources/auth_api_service.dart';
import 'package:tayninh_tour_mobile/data/datasources/tour_guide_api_service.dart';
import 'package:tayninh_tour_mobile/data/datasources/user_api_service.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Initialize dependencies for testing
    final storage = const FlutterSecureStorage();
    final logger = Logger();
    final dioClient = DioClient(storage: storage, logger: logger);
    final authApiService = AuthApiService(dioClient.dio);
    final tourGuideApiService = TourGuideApiService(dioClient.dio);
    final userApiService = UserApiService(dioClient.dio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(TayNinhTourApp(
      storage: storage,
      logger: logger,
      authApiService: authApiService,
      tourGuideApiService: tourGuideApiService,
      userApiService: userApiService,
    ));

    // Verify that login page loads
    expect(find.text('TayNinh Tour HDV'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
  });
}
