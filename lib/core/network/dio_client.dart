import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Dio HTTP client configuration
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  final Logger _logger;
  
  DioClient({
    FlutterSecureStorage? storage,
    Logger? logger,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _logger = logger ?? Logger() {
    _dio = Dio();
    _configureDio();
  }
  
  Dio get dio => _dio;
  
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
      headers: ApiConstants.defaultHeaders,
    );
    
    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _logger),
      _LoggingInterceptor(_logger),
      _ResponseUnwrapInterceptor(_logger),
      _ErrorInterceptor(_logger),
    ]);
  }
  
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(
            message: 'Kết nối mạng bị timeout. Vui lòng thử lại.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 
                          'Có lỗi xảy ra từ server';
          
          if (statusCode == 401) {
            return AuthException(
              message: message,
              statusCode: statusCode,
            );
          } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
            return ValidationException(
              message: message,
              statusCode: statusCode,
            );
          } else {
            return ServerException(
              message: message,
              statusCode: statusCode,
            );
          }
        case DioExceptionType.cancel:
          return const NetworkException(
            message: 'Yêu cầu đã bị hủy',
          );
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
        default:
          return const NetworkException(
            message: 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
          );
      }
    }
    
    return NetworkException(
      message: error.toString(),
    );
  }
}

/// Auth interceptor to add JWT token
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Logger _logger;
  
  _AuthInterceptor(this._storage, this._logger);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // If the request has the 'No-Auth' header, don't add the token.
    if (options.headers['No-Auth'] == 'true') {
      options.headers.remove('No-Auth'); // Clean up the header
      return handler.next(options);
    }

    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      _logger.e('Error adding auth token: $e');
    }

    return handler.next(options);
  }
}

/// Logging interceptor
class _LoggingInterceptor extends Interceptor {
  final Logger _logger;
  
  _LoggingInterceptor(this._logger);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('REQUEST: ${options.method} ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    _logger.d('Data: ${response.data}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('ERROR: ${err.message}');
    _logger.e('Response: ${err.response?.data}');
    handler.next(err);
  }
}

/// Response unwrapping interceptor for envelope { isSuccess, statusCode, message, data }
class _ResponseUnwrapInterceptor extends Interceptor {
  final Logger _logger;
  _ResponseUnwrapInterceptor(this._logger);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final body = response.data;
      if (body is Map<String, dynamic> && body.containsKey('isSuccess') && body.containsKey('statusCode')) {
        // Unwrap to inner data (can be list, object or null)
        response.data = body['data'];
        _logger.d('UNWRAPPED DATA: ${response.data}');
      }
    } catch (e) {
      _logger.w('Failed to unwrap response: $e');
    }
    handler.next(response);
  }
}

/// Error interceptor
class _ErrorInterceptor extends Interceptor {
  final Logger _logger;
  
  _ErrorInterceptor(this._logger);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('API Error: ${err.message}');
    
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic
      _logger.w('Token expired, should refresh token');
    }
    
    handler.next(err);
  }
}
