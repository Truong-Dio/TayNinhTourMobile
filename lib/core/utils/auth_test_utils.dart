import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Utility class for testing authentication scenarios
class AuthTestUtils {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Clear all authentication tokens to simulate logout/token expiry
  static Future<void> clearAllTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userDataKey);
  }

  /// Check if user has valid tokens
  static Future<bool> hasValidTokens() async {
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    final userData = await _storage.read(key: AppConstants.userDataKey);
    return accessToken != null && userData != null;
  }

  /// Get current access token
  static Future<String?> getCurrentToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }
}
