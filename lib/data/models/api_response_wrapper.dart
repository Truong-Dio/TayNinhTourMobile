import 'package:json_annotation/json_annotation.dart';

part 'api_response_wrapper.g.dart';

/// Generic API response wrapper
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T? data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// Check if the response is successful
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Get data or throw exception if not successful
  T get dataOrThrow {
    if (!isSuccess) {
      throw Exception('API Error: $message (Status: $statusCode)');
    }
    if (data == null) {
      throw Exception('API Error: No data returned');
    }
    return data!;
  }
}

/// Timeline-specific response wrapper
@JsonSerializable()
class TimelineApiResponse {
  final int statusCode;
  final String message;
  final TimelineDataWrapper? data;

  TimelineApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory TimelineApiResponse.fromJson(Map<String, dynamic> json) =>
      _$TimelineApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineApiResponseToJson(this);
}

/// Timeline data wrapper to match API structure
@JsonSerializable()
class TimelineDataWrapper {
  final List<Map<String, dynamic>> timeline;

  TimelineDataWrapper({
    required this.timeline,
  });

  factory TimelineDataWrapper.fromJson(Map<String, dynamic> json) =>
      _$TimelineDataWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineDataWrapperToJson(this);
}
