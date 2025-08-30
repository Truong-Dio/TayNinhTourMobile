import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  /// Login
  @POST(ApiConstants.login)
  Future<LoginResponse> login(@Body() LoginRequest request);

  /// Refresh token
  @POST(ApiConstants.refreshToken)
  Future<RefreshTokenResponse> refreshToken(@Body() RefreshTokenRequest request);

  /// Change password
  @PUT(ApiConstants.changePassword)
  Future<BaseResponse> changePassword(@Body() ChangePasswordRequest request);

  /// Edit profile
  @PUT(ApiConstants.editProfile)
  Future<BaseResponse> editProfile(@Body() EditProfileRequest request);

  /// Send OTP to reset password
  @POST(ApiConstants.sendOtpResetPassword)
  Future<BaseResponse> sendOtpResetPassword(@Body() SendOtpRequest request);

  /// Reset password with OTP
  @POST(ApiConstants.resetPassword)
  Future<BaseResponse> resetPassword(@Body() ResetPasswordRequest request);
}

/// Login request
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

/// Login response
class LoginResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  LoginResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Server spec ResponseAuthenticationDto: isSuccess, token, refreshToken, userId, email, name, ...
    final bool isSuccess = (json['isSuccess'] ?? json['success'] ?? false) as bool;
    final String? token = (json['token'] ?? json['accessToken']) as String?;
    final String? rToken = (json['refreshToken']) as String?;

    // Build user if fields available (no role in spec)
    UserModel? user;
    if (json.containsKey('user')) {
      try {
        user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
      } catch (_) {
        user = null;
      }
    } else if (json['userId'] != null || json['email'] != null || json['name'] != null) {
      // Create minimal user model from flat fields
      user = UserModel(
        id: (json['userId'] ?? json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        phoneNumber: json['phoneNumber']?.toString(),
        role: (json['role'] ?? 'User').toString(), // Use role from response
        isActive: true,
        createdAt: null,
      );
    }

    return LoginResponse(
      success: isSuccess,
      message: json['message'] as String?,
      accessToken: token,
      refreshToken: rToken,
      user: user,
    );
  }
}

/// Refresh token request
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}

/// Refresh token response
class RefreshTokenResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;

  RefreshTokenResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: (json['isSuccess'] ?? json['success'] ?? false) as bool,
      message: json['message'] as String?,
      accessToken: (json['token'] ?? json['accessToken']) as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}


/// Base response for simple API calls
class BaseResponse {
  final bool success;
  final String? message;

  BaseResponse({required this.success, this.message});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: (json['isSuccess'] ?? json['success'] ?? false) as bool,
      message: json['message'] as String?,
    );
  }
}

/// Change password request
class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'oldPassword': oldPassword,
    'newPassword': newPassword,
  };
}

/// Edit profile request
class EditProfileRequest {
  final String name;
  final String phoneNumber;

  EditProfileRequest({
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber,
  };
}

/// Send OTP request
class SendOtpRequest {
  final String email;

  SendOtpRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

/// Reset password request
class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'newPassword': newPassword,
  };
}
