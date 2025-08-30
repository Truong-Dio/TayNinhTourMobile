// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

TimelineApiResponse _$TimelineApiResponseFromJson(Map<String, dynamic> json) =>
    TimelineApiResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : TimelineDataWrapper.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimelineApiResponseToJson(
        TimelineApiResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

TimelineDataWrapper _$TimelineDataWrapperFromJson(Map<String, dynamic> json) =>
    TimelineDataWrapper(
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$TimelineDataWrapperToJson(
        TimelineDataWrapper instance) =>
    <String, dynamic>{
      'timeline': instance.timeline,
    };
