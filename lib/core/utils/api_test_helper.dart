import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';

/// Helper class for testing API connectivity and endpoints
class ApiTestHelper {
  static final Logger _logger = Logger();
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: ApiConstants.defaultHeaders,
  ));

  /// Test basic connectivity to the server
  static Future<bool> testConnectivity() async {
    try {
      _logger.i('Testing connectivity to: ${ApiConstants.baseUrl}');
      
      final response = await _dio.get('/health');
      
      if (response.statusCode == 200) {
        _logger.i('✅ Server is reachable');
        return true;
      } else {
        _logger.w('⚠️ Server responded with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Connection failed: $e');
      return false;
    }
  }

  /// Test login endpoint with sample credentials
  static Future<bool> testLogin({
    String email = 'tourguide@example.com',
    String password = 'password123',
  }) async {
    try {
      _logger.i('Testing login with: $email');
      
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        _logger.i('✅ Login successful');
        _logger.d('Response: ${response.data}');
        return true;
      } else {
        _logger.w('⚠️ Login failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Login error: $e');
      if (e is DioException) {
        _logger.e('Response data: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }
      return false;
    }
  }

  /// Test all endpoints availability
  static Future<Map<String, bool>> testAllEndpoints() async {
    final results = <String, bool>{};
    
    // Test basic connectivity first
    results['connectivity'] = await testConnectivity();
    
    // Test login
    results['login'] = await testLogin();
    
    // Test other endpoints (without authentication for now)
    final endpoints = [
      '/TourGuide/my-active-tours',
      '/TourGuide/tour/test/bookings',
      '/TourGuide/tour/test/timeline',
    ];
    
    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(endpoint);
        results[endpoint] = response.statusCode == 200 || response.statusCode == 401; // 401 is expected without auth
        _logger.i('Endpoint $endpoint: ${results[endpoint] ? "✅" : "❌"}');
      } catch (e) {
        results[endpoint] = false;
        _logger.e('Endpoint $endpoint failed: $e');
      }
    }
    
    return results;
  }

  /// Print detailed server information
  static Future<void> printServerInfo() async {
    _logger.i('=== TayNinh Tour API Server Info ===');
    _logger.i('Base URL: ${ApiConstants.baseUrl}');
    _logger.i('Connect Timeout: ${ApiConstants.connectTimeout}ms');
    _logger.i('Receive Timeout: ${ApiConstants.receiveTimeout}ms');
    _logger.i('Send Timeout: ${ApiConstants.sendTimeout}ms');
    _logger.i('=====================================');
    
    final results = await testAllEndpoints();
    
    _logger.i('=== Endpoint Test Results ===');
    results.forEach((endpoint, success) {
      _logger.i('$endpoint: ${success ? "✅ OK" : "❌ FAIL"}');
    });
    _logger.i('=============================');
  }
}
