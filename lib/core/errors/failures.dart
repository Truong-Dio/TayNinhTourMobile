import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  
  const Failure({
    required this.message,
    this.statusCode,
  });
  
  @override
  List<Object?> get props => [message, statusCode];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.statusCode,
  });
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.statusCode,
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });
}

/// QR Code failure
class QRCodeFailure extends Failure {
  const QRCodeFailure({
    required super.message,
    super.statusCode,
  });
}

/// Image upload failure
class ImageUploadFailure extends Failure {
  const ImageUploadFailure({
    required super.message,
    super.statusCode,
  });
}
