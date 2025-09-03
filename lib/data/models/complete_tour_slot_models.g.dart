// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_tour_slot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTourSlotRequest _$CompleteTourSlotRequestFromJson(
        Map<String, dynamic> json) =>
    CompleteTourSlotRequest(
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CompleteTourSlotRequestToJson(
        CompleteTourSlotRequest instance) =>
    <String, dynamic>{
      'notes': instance.notes,
    };

CompleteTourSlotResponse _$CompleteTourSlotResponseFromJson(
        Map<String, dynamic> json) =>
    CompleteTourSlotResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : CompleteTourSlotData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompleteTourSlotResponseToJson(
        CompleteTourSlotResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CompleteTourSlotData _$CompleteTourSlotDataFromJson(
        Map<String, dynamic> json) =>
    CompleteTourSlotData(
      tourSlot: json['tourSlot'] == null
          ? null
          : CompletedTourSlotInfo.fromJson(
              json['tourSlot'] as Map<String, dynamic>),
      statistics: json['statistics'] == null
          ? null
          : CompletionStatistics.fromJson(
              json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompleteTourSlotDataToJson(
        CompleteTourSlotData instance) =>
    <String, dynamic>{
      'tourSlot': instance.tourSlot,
      'statistics': instance.statistics,
    };

CompletedTourSlotInfo _$CompletedTourSlotInfoFromJson(
        Map<String, dynamic> json) =>
    CompletedTourSlotInfo(
      id: json['id'] as String,
      tourDate: json['tourDate'] as String,
      status: json['status'] as String,
      statusName: json['statusName'] as String,
      completedAt: json['completedAt'] as String,
      completedByGuideId: json['completedByGuideId'] as String,
      completedByGuideName: json['completedByGuideName'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CompletedTourSlotInfoToJson(
        CompletedTourSlotInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourDate': instance.tourDate,
      'status': instance.status,
      'statusName': instance.statusName,
      'completedAt': instance.completedAt,
      'completedByGuideId': instance.completedByGuideId,
      'completedByGuideName': instance.completedByGuideName,
      'notes': instance.notes,
    };

CompletionStatistics _$CompletionStatisticsFromJson(
        Map<String, dynamic> json) =>
    CompletionStatistics(
      totalBookedGuests: (json['totalBookedGuests'] as num).toInt(),
      completedBookings: (json['completedBookings'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      guestsNotified: (json['guestsNotified'] as num).toInt(),
      occupancyRate: (json['occupancyRate'] as num).toDouble(),
    );

Map<String, dynamic> _$CompletionStatisticsToJson(
        CompletionStatistics instance) =>
    <String, dynamic>{
      'totalBookedGuests': instance.totalBookedGuests,
      'completedBookings': instance.completedBookings,
      'totalRevenue': instance.totalRevenue,
      'guestsNotified': instance.guestsNotified,
      'occupancyRate': instance.occupancyRate,
    };
