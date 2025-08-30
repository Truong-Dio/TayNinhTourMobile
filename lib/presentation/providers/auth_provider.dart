import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

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
        try {
          final map = json.decode(userDataJson) as Map<String, dynamic>;
          _user = User(
            id: (map['id'] ?? '').toString(),
            email: (map['email'] ?? '').toString(),
            name: (map['name'] ?? '').toString(),
            phoneNumber: map['phoneNumber']?.toString(),
            role: (map['role'] ?? AppConstants.tourGuideRole).toString(),
            isActive: (map['isActive'] ?? true) as bool,
            createdAt: null,
          );
        } catch (e) {
          _logger.w('Failed to parse stored user, clearing. Error: $e');
          await _storage.delete(key: AppConstants.userDataKey);
          _user = null;
        }
        _isAuthenticated = true;
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

      if (response.success && response.accessToken != null) {
        // Save tokens
        await _storage.write(key: AppConstants.accessTokenKey, value: response.accessToken);
        if (response.refreshToken != null) {
          await _storage.write(key: AppConstants.refreshTokenKey, value: response.refreshToken);
        }

        // Build minimal user when missing
        final userModel = response.user ?? User(
          id: '',
          email: email,
          name: email.split('@').first,
          role: AppConstants.userRole, // Default to User role
          isActive: true,
        );

        // Persist user as JSON
        final userMap = {
          'id': (userModel is User) ? userModel.id : (userModel as dynamic).id,
          'email': (userModel is User) ? userModel.email : (userModel as dynamic).email,
          'name': (userModel is User) ? userModel.name : (userModel as dynamic).name,
          'phoneNumber': (userModel is User) ? userModel.phoneNumber : (userModel as dynamic).phoneNumber,
          'role': (userModel is User) ? userModel.role : (userModel as dynamic).role,
          'isActive': (userModel is User) ? userModel.isActive : (userModel as dynamic).isActive,
        };
        await _storage.write(key: AppConstants.userDataKey, value: json.encode(userMap));

        _isAuthenticated = true;
        _user = (userModel is User) ? userModel : (userModel as dynamic) as User;

        _logger.i('Login successful for user: ${user?.email}');
        notifyListeners();
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

      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);

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

  /// Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      final request = ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword);
      final response = await _authApiService.changePassword(request);

      if (response.success) {
        _logger.i('Password changed successfully');
        return true;
      } else {
        _setError(response.message ?? 'Failed to change password');
        return false;
      }
    } catch (e) {
      _logger.e('Change password error: $e');
      _setError('An error occurred while changing password.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Edit profile
  Future<bool> editProfile(String name, String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();

      final request = EditProfileRequest(name: name, phoneNumber: phoneNumber);
      final response = await _authApiService.editProfile(request);

      if (response.success) {
        _logger.i('Profile updated successfully');
        // Update local user data
        if (_user != null) {
          _user = User(
            id: _user!.id,
            email: _user!.email,
            name: name,
            phoneNumber: phoneNumber,
            role: _user!.role,
            isActive: _user!.isActive,
            createdAt: _user!.createdAt,
          );
          // Persist updated user data
          final userMap = {
            'id': _user!.id,
            'email': _user!.email,
            'name': _user!.name,
            'phoneNumber': _user!.phoneNumber,
            'role': _user!.role,
            'isActive': _user!.isActive,
          };
          await _storage.write(key: AppConstants.userDataKey, value: json.encode(userMap));
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _logger.e('Edit profile error: $e');
      _setError('An error occurred while updating profile.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP for password reset
  Future<bool> sendOtpResetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final request = SendOtpRequest(email: email);
      final response = await _authApiService.sendOtpResetPassword(request);

      if (response.success) {
        _logger.i('OTP sent successfully to $email');
        return true;
      } else {
        _setError(response.message ?? 'Failed to send OTP');
        return false;
      }
    } catch (e) {
      _logger.e('Send OTP error: $e');
      _setError('An error occurred while sending OTP.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      final request = ResetPasswordRequest(email: email, otp: otp, newPassword: newPassword);
      final response = await _authApiService.resetPassword(request);

      if (response.success) {
        _logger.i('Password reset successfully for $email');
        return true;
      } else {
        _setError(response.message ?? 'Failed to reset password');
        return false;
      }
    } catch (e) {
      _logger.e('Reset password error: $e');
      _setError('An error occurred while resetting password.');
      return false;
    } finally {
      _setLoading(false);
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
