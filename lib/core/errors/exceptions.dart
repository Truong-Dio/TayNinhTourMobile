/// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;
  
  const AppException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'AppException: $message';
}

/// Server exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'ServerException: $message';
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'AuthException: $message';
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'PermissionException: $message';
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'CacheException: $message';
}

/// QR Code exception
class QRCodeException extends AppException {
  const QRCodeException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'QRCodeException: $message';
}

/// Image upload exception
class ImageUploadException extends AppException {
  const ImageUploadException({
    required super.message,
    super.statusCode,
  });
  
  @override
  String toString() => 'ImageUploadException: $message';
}
