// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_progress_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineWithProgressDto _$TimelineWithProgressDtoFromJson(
        Map<String, dynamic> json) =>
    TimelineWithProgressDto(
      id: json['id'] as String,
      tourSlotId: json['tourSlotId'] as String,
      progressId: json['progressId'] as String?,
      activity: json['activity'] as String,
      checkInTime: json['checkInTime'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completionNotes: json['completionNotes'] as String?,
      canComplete: json['canComplete'] as bool,
      specialtyShop: json['specialtyShop'] == null
          ? null
          : SpecialtyShopModel.fromJson(
              json['specialtyShop'] as Map<String, dynamic>),
      completedByName: json['completedByName'] as String?,
      completionDurationMinutes:
          (json['completionDurationMinutes'] as num?)?.toInt(),
      statusText: json['statusText'] as String,
      isNext: json['isNext'] as bool,
      position: (json['position'] as num).toInt(),
      totalItems: (json['totalItems'] as num).toInt(),
    );

Map<String, dynamic> _$TimelineWithProgressDtoToJson(
        TimelineWithProgressDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourSlotId': instance.tourSlotId,
      'progressId': instance.progressId,
      'activity': instance.activity,
      'checkInTime': instance.checkInTime,
      'sortOrder': instance.sortOrder,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'completionNotes': instance.completionNotes,
      'canComplete': instance.canComplete,
      'specialtyShop': instance.specialtyShop?.toJson(),
      'completedByName': instance.completedByName,
      'completionDurationMinutes': instance.completionDurationMinutes,
      'statusText': instance.statusText,
      'isNext': instance.isNext,
      'position': instance.position,
      'totalItems': instance.totalItems,
    };

TimelineProgressSummaryDto _$TimelineProgressSummaryDtoFromJson(
        Map<String, dynamic> json) =>
    TimelineProgressSummaryDto(
      tourSlotId: json['tourSlotId'] as String,
      totalItems: (json['totalItems'] as num).toInt(),
      completedItems: (json['completedItems'] as num).toInt(),
      nextItem: json['nextItem'] == null
          ? null
          : TimelineWithProgressDto.fromJson(
              json['nextItem'] as Map<String, dynamic>),
      lastCompletedItem: json['lastCompletedItem'] == null
          ? null
          : TimelineWithProgressDto.fromJson(
              json['lastCompletedItem'] as Map<String, dynamic>),
      estimatedCompletionTime: json['estimatedCompletionTime'] == null
          ? null
          : DateTime.parse(json['estimatedCompletionTime'] as String),
    );

Map<String, dynamic> _$TimelineProgressSummaryDtoToJson(
        TimelineProgressSummaryDto instance) =>
    <String, dynamic>{
      'tourSlotId': instance.tourSlotId,
      'totalItems': instance.totalItems,
      'completedItems': instance.completedItems,
      'nextItem': instance.nextItem?.toJson(),
      'lastCompletedItem': instance.lastCompletedItem?.toJson(),
      'estimatedCompletionTime':
          instance.estimatedCompletionTime?.toIso8601String(),
    };

TimelineProgressResponse _$TimelineProgressResponseFromJson(
        Map<String, dynamic> json) =>
    TimelineProgressResponse(
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) =>
              TimelineWithProgressDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: TimelineProgressSummaryDto.fromJson(
          json['summary'] as Map<String, dynamic>),
      tourSlot:
          TourSlotInfoDto.fromJson(json['tourSlot'] as Map<String, dynamic>),
      tourDetails: TourDetailsInfoDto.fromJson(
          json['tourDetails'] as Map<String, dynamic>),
      canModifyProgress: json['canModifyProgress'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$TimelineProgressResponseToJson(
        TimelineProgressResponse instance) =>
    <String, dynamic>{
      'timeline': instance.timeline.map((e) => e.toJson()).toList(),
      'summary': instance.summary.toJson(),
      'tourSlot': instance.tourSlot.toJson(),
      'tourDetails': instance.tourDetails.toJson(),
      'canModifyProgress': instance.canModifyProgress,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

TourSlotInfoDto _$TourSlotInfoDtoFromJson(Map<String, dynamic> json) =>
    TourSlotInfoDto(
      id: json['id'] as String,
      tourDate: json['tourDate'] as String,
      currentBookings: (json['currentBookings'] as num).toInt(),
      maxGuests: (json['maxGuests'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$TourSlotInfoDtoToJson(TourSlotInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourDate': instance.tourDate,
      'currentBookings': instance.currentBookings,
      'maxGuests': instance.maxGuests,
      'status': instance.status,
    };

TourDetailsInfoDto _$TourDetailsInfoDtoFromJson(Map<String, dynamic> json) =>
    TourDetailsInfoDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TourDetailsInfoDtoToJson(TourDetailsInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'imageUrls': instance.imageUrls,
    };

CompleteTimelineResponse _$CompleteTimelineResponseFromJson(
        Map<String, dynamic> json) =>
    CompleteTimelineResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      completedItem: json['completedItem'] == null
          ? null
          : TimelineWithProgressDto.fromJson(
              json['completedItem'] as Map<String, dynamic>),
      summary: json['summary'] == null
          ? null
          : TimelineProgressSummaryDto.fromJson(
              json['summary'] as Map<String, dynamic>),
      nextItem: json['nextItem'] == null
          ? null
          : TimelineWithProgressDto.fromJson(
              json['nextItem'] as Map<String, dynamic>),
      isTimelineCompleted: json['isTimelineCompleted'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      warnings:
          (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CompleteTimelineResponseToJson(
        CompleteTimelineResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'completedItem': instance.completedItem?.toJson(),
      'summary': instance.summary?.toJson(),
      'nextItem': instance.nextItem?.toJson(),
      'isTimelineCompleted': instance.isTimelineCompleted,
      'completedAt': instance.completedAt.toIso8601String(),
      'warnings': instance.warnings,
    };

BulkTimelineResponse _$BulkTimelineResponseFromJson(
        Map<String, dynamic> json) =>
    BulkTimelineResponse(
      successCount: (json['successCount'] as num).toInt(),
      failureCount: (json['failureCount'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      successfulItems: (json['successfulItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      failedItems: (json['failedItems'] as List<dynamic>)
          .map((e) => BulkOperationError.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] == null
          ? null
          : TimelineProgressSummaryDto.fromJson(
              json['summary'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$BulkTimelineResponseToJson(
        BulkTimelineResponse instance) =>
    <String, dynamic>{
      'successCount': instance.successCount,
      'failureCount': instance.failureCount,
      'totalCount': instance.totalCount,
      'successfulItems': instance.successfulItems,
      'failedItems': instance.failedItems,
      'summary': instance.summary,
      'message': instance.message,
    };

BulkOperationError _$BulkOperationErrorFromJson(Map<String, dynamic> json) =>
    BulkOperationError(
      itemId: json['itemId'] as String,
      errorMessage: json['errorMessage'] as String,
      errorCode: json['errorCode'] as String,
    );

Map<String, dynamic> _$BulkOperationErrorToJson(BulkOperationError instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'errorMessage': instance.errorMessage,
      'errorCode': instance.errorCode,
    };

TimelineStatisticsResponse _$TimelineStatisticsResponseFromJson(
        Map<String, dynamic> json) =>
    TimelineStatisticsResponse(
      tourSlotId: json['tourSlotId'] as String,
      averageCompletionTimeMinutes:
          (json['averageCompletionTimeMinutes'] as num).toDouble(),
      totalTimeMinutes: (json['totalTimeMinutes'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
      onTimeCompletions: (json['onTimeCompletions'] as num).toInt(),
      overdueCompletions: (json['overdueCompletions'] as num).toInt(),
      slowestItem: json['slowestItem'] == null
          ? null
          : TimelineWithProgressDto.fromJson(
              json['slowestItem'] as Map<String, dynamic>),
      fastestItem: json['fastestItem'] == null
          ? null
          : TimelineWithProgressDto.fromJson(
              json['fastestItem'] as Map<String, dynamic>),
      completionTrend: (json['completionTrend'] as List<dynamic>)
          .map((e) => CompletionTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TimelineStatisticsResponseToJson(
        TimelineStatisticsResponse instance) =>
    <String, dynamic>{
      'tourSlotId': instance.tourSlotId,
      'averageCompletionTimeMinutes': instance.averageCompletionTimeMinutes,
      'totalTimeMinutes': instance.totalTimeMinutes,
      'completionRate': instance.completionRate,
      'onTimeCompletions': instance.onTimeCompletions,
      'overdueCompletions': instance.overdueCompletions,
      'slowestItem': instance.slowestItem,
      'fastestItem': instance.fastestItem,
      'completionTrend': instance.completionTrend,
    };

CompletionTrendPoint _$CompletionTrendPointFromJson(
        Map<String, dynamic> json) =>
    CompletionTrendPoint(
      time: DateTime.parse(json['time'] as String),
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      itemsCompleted: (json['itemsCompleted'] as num).toInt(),
    );

Map<String, dynamic> _$CompletionTrendPointToJson(
        CompletionTrendPoint instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'completionPercentage': instance.completionPercentage,
      'itemsCompleted': instance.itemsCompleted,
    };
