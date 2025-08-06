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
  
  /// Logout
  @POST(ApiConstants.logout)
  Future<void> logout();
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
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
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
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
