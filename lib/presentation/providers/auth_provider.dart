import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../data/datasources/auth_api_service.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _authApiService;
  final FlutterSecureStorage _storage;
  final Logger _logger;
  
  AuthProvider({
    required AuthApiService authApiService,
    required FlutterSecureStorage storage,
    required Logger logger,
  }) : _authApiService = authApiService,
       _storage = storage,
       _logger = logger;
  
  // State
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _user;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  
  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);
      
      final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
      final userDataJson = await _storage.read(key: AppConstants.userDataKey);
      
      if (accessToken != null && userDataJson != null) {
        // TODO: Validate token with server
        // For now, assume token is valid if it exists
        _isAuthenticated = true;
        // TODO: Parse user data from JSON
        _logger.i('User is authenticated');
      } else {
        _isAuthenticated = false;
        _user = null;
        _logger.i('User is not authenticated');
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      _isAuthenticated = false;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final request = LoginRequest(email: email, password: password);
      final response = await _authApiService.login(request);
      
      if (response.success && response.accessToken != null && response.user != null) {
        // Check if user has Tour Guide role
        if (response.user!.role != AppConstants.tourGuideRole) {
          _setError('Ứng dụng này chỉ dành cho Hướng dẫn viên');
          return false;
        }
        
        // Save tokens
        await _storage.write(key: AppConstants.accessTokenKey, value: response.accessToken);
        if (response.refreshToken != null) {
          await _storage.write(key: AppConstants.refreshTokenKey, value: response.refreshToken);
        }
        
        // Save user data
        // TODO: Save user data as JSON
        
        _isAuthenticated = true;
        _user = response.user!.toEntity();
        
        _logger.i('Login successful for user: ${_user!.email}');
        return true;
      } else {
        _setError(response.message ?? 'Đăng nhập thất bại');
        return false;
      }
    } catch (e) {
      _logger.e('Login error: $e');
      if (e is AuthFailure) {
        _setError(e.message);
      } else {
        _setError('Có lỗi xảy ra khi đăng nhập. Vui lòng thử lại.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      
      // Call logout API
      try {
        await _authApiService.logout();
      } catch (e) {
        _logger.w('Logout API call failed: $e');
        // Continue with local logout even if API call fails
      }
      
      // Clear local storage
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);
      
      // Clear state
      _isAuthenticated = false;
      _user = null;
      _clearError();
      
      _logger.i('User logged out');
    } catch (e) {
      _logger.e('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        await logout();
        return false;
      }
      
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _authApiService.refreshToken(request);
      
      if (response.success && response.accessToken != null) {
        await _storage.write(key: AppConstants.accessTokenKey, value: response.accessToken);
        if (response.refreshToken != null) {
          await _storage.write(key: AppConstants.refreshTokenKey, value: response.refreshToken);
        }
        
        _logger.i('Token refreshed successfully');
        return true;
      } else {
        _logger.w('Token refresh failed');
        await logout();
        return false;
      }
    } catch (e) {
      _logger.e('Token refresh error: $e');
      await logout();
      return false;
    }
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
