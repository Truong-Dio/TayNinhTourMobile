import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import 'dio_client.dart'; // Assuming interceptors are in this file

class DioClientProvider {
  final GetIt sl;

  DioClientProvider(this.sl);

  Dio get dio => _createDio();
  Dio get publicDio => _createDio(isPublic: true);

  Dio _createDio({bool isPublic = false}) {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
      headers: ApiConstants.defaultHeaders,
    );

    // Add interceptors
    dio.interceptors.addAll([
      if (!isPublic) _AuthInterceptor(sl<FlutterSecureStorage>(), sl<Logger>()),
      _LoggingInterceptor(sl<Logger>()),
      _ResponseUnwrapInterceptor(sl<Logger>()),
      _ErrorInterceptor(sl<Logger>()),
    ]);

    return dio;
  }
}

