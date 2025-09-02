import 'package:dio/dio.dart';

/// Base API service class that provides common functionality for all API services
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  /// Get the Dio instance for making HTTP requests
  Dio get dio => _dio;

  /// Base URL for the API
  String get baseUrl => _dio.options.baseUrl;

  /// Common headers for all requests
  Map<String, dynamic> get commonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Make a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Make a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Make a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Make a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Make a PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Upload a file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (data != null) ...data,
    });

    return await _dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// Download a file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Handle common API errors
  String handleApiError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối bị timeout. Vui lòng thử lại.';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu bị timeout. Vui lòng thử lại.';
      case DioExceptionType.receiveTimeout:
        return 'Nhận dữ liệu bị timeout. Vui lòng thử lại.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Yêu cầu không hợp lệ.';
          case 401:
            return 'Bạn cần đăng nhập để tiếp tục.';
          case 403:
            return 'Bạn không có quyền truy cập.';
          case 404:
            return 'Không tìm thấy dữ liệu.';
          case 500:
            return 'Lỗi máy chủ. Vui lòng thử lại sau.';
          default:
            return 'Có lỗi xảy ra. Vui lòng thử lại.';
        }
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
      case DioExceptionType.badCertificate:
        return 'Chứng chỉ bảo mật không hợp lệ.';
      case DioExceptionType.unknown:
      default:
        return 'Có lỗi không xác định xảy ra. Vui lòng thử lại.';
    }
  }

  /// Check if the response is successful
  bool isSuccessResponse(Response response) {
    return response.statusCode != null && 
           response.statusCode! >= 200 && 
           response.statusCode! < 300;
  }

  /// Extract error message from response
  String extractErrorMessage(Response? response) {
    if (response?.data != null && response!.data is Map) {
      final data = response.data as Map<String, dynamic>;
      
      // Try different common error message fields
      if (data.containsKey('message') && data['message'] != null) {
        return data['message'].toString();
      }
      if (data.containsKey('Message') && data['Message'] != null) {
        return data['Message'].toString();
      }
      if (data.containsKey('error') && data['error'] != null) {
        return data['error'].toString();
      }
      if (data.containsKey('Error') && data['Error'] != null) {
        return data['Error'].toString();
      }
    }
    
    return 'Có lỗi xảy ra từ máy chủ.';
  }

  /// Add authorization header to options
  Options addAuthHeader(String token, {Options? options}) {
    final headers = <String, dynamic>{
      'Authorization': 'Bearer $token',
      ...?options?.headers,
    };
    
    return (options ?? Options()).copyWith(headers: headers);
  }

  /// Create options with common headers
  Options createOptions({
    Map<String, dynamic>? headers,
    String? contentType,
    ResponseType? responseType,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) {
    return Options(
      headers: {
        ...commonHeaders,
        ...?headers,
      },
      contentType: contentType,
      responseType: responseType,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }
}
