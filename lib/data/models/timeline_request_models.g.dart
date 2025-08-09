// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTimelineRequest _$CompleteTimelineRequestFromJson(
        Map<String, dynamic> json) =>
    CompleteTimelineRequest(
      notes: json['notes'] as String?,
      completionTime: json['completionTime'] == null
          ? null
          : DateTime.parse(json['completionTime'] as String),
    );

Map<String, dynamic> _$CompleteTimelineRequestToJson(
        CompleteTimelineRequest instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'completionTime': instance.completionTime?.toIso8601String(),
    };

BulkCompleteTimelineRequest _$BulkCompleteTimelineRequestFromJson(
        Map<String, dynamic> json) =>
    BulkCompleteTimelineRequest(
      timelineItemIds: (json['timelineItemIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tourSlotId: json['tourSlotId'] as String,
      notes: json['notes'] as String?,
      respectSequentialOrder: json['respectSequentialOrder'] as bool? ?? true,
    );

Map<String, dynamic> _$BulkCompleteTimelineRequestToJson(
        BulkCompleteTimelineRequest instance) =>
    <String, dynamic>{
      'timelineItemIds': instance.timelineItemIds,
      'tourSlotId': instance.tourSlotId,
      'notes': instance.notes,
      'respectSequentialOrder': instance.respectSequentialOrder,
    };

ResetTimelineRequest _$ResetTimelineRequestFromJson(
        Map<String, dynamic> json) =>
    ResetTimelineRequest(
      reason: json['reason'] as String,
      resetSubsequentItems: json['resetSubsequentItems'] as bool? ?? true,
    );

Map<String, dynamic> _$ResetTimelineRequestToJson(
        ResetTimelineRequest instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'resetSubsequentItems': instance.resetSubsequentItems,
    };

GetTimelineProgressRequest _$GetTimelineProgressRequestFromJson(
        Map<String, dynamic> json) =>
    GetTimelineProgressRequest(
      tourSlotId: json['tourSlotId'] as String,
      includeInactive: json['includeInactive'] as bool? ?? false,
      includeShopInfo: json['includeShopInfo'] as bool? ?? true,
      includeStatistics: json['includeStatistics'] as bool? ?? true,
      completionFilter: json['completionFilter'] as bool?,
    );

Map<String, dynamic> _$GetTimelineProgressRequestToJson(
        GetTimelineProgressRequest instance) =>
    <String, dynamic>{
      'tourSlotId': instance.tourSlotId,
      'includeInactive': instance.includeInactive,
      'includeShopInfo': instance.includeShopInfo,
      'includeStatistics': instance.includeStatistics,
      'completionFilter': instance.completionFilter,
    };
