// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_guide_slot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourGuideSlotModel _$TourGuideSlotModelFromJson(Map<String, dynamic> json) =>
    TourGuideSlotModel(
      id: json['id'] as String,
      tourDate: json['tourDate'] as String,
      status: json['status'] as String,
      tourDetails:
          TourDetailsInfo.fromJson(json['tourDetails'] as Map<String, dynamic>),
      bookingStats: BookingStatsModel.fromJson(
          json['bookingStats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourGuideSlotModelToJson(TourGuideSlotModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourDate': instance.tourDate,
      'status': instance.status,
      'tourDetails': instance.tourDetails,
      'bookingStats': instance.bookingStats,
    };

TourDetailsInfo _$TourDetailsInfoFromJson(Map<String, dynamic> json) =>
    TourDetailsInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startLocation: json['startLocation'] as String?,
      endLocation: json['endLocation'] as String?,
    );

Map<String, dynamic> _$TourDetailsInfoToJson(TourDetailsInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
    };

BookingStatsModel _$BookingStatsModelFromJson(Map<String, dynamic> json) =>
    BookingStatsModel(
      totalBookings: (json['totalBookings'] as num).toInt(),
      checkedInCount: (json['checkedInCount'] as num).toInt(),
      totalGuests: (json['totalGuests'] as num).toInt(),
    );

Map<String, dynamic> _$BookingStatsModelToJson(BookingStatsModel instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'checkedInCount': instance.checkedInCount,
      'totalGuests': instance.totalGuests,
    };

TourSlotBookingsResponse _$TourSlotBookingsResponseFromJson(
        Map<String, dynamic> json) =>
    TourSlotBookingsResponse(
      tourSlot: TourSlotInfo.fromJson(json['tourSlot'] as Map<String, dynamic>),
      bookings: (json['bookings'] as List<dynamic>)
          .map((e) => TourBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      statistics: BookingStatistics.fromJson(
          json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourSlotBookingsResponseToJson(
        TourSlotBookingsResponse instance) =>
    <String, dynamic>{
      'tourSlot': instance.tourSlot,
      'bookings': instance.bookings,
      'statistics': instance.statistics,
    };

TourSlotInfo _$TourSlotInfoFromJson(Map<String, dynamic> json) => TourSlotInfo(
      id: json['id'] as String,
      tourDate: json['tourDate'] as String,
      status: json['status'] as String,
      tourTitle: json['tourTitle'] as String,
    );

Map<String, dynamic> _$TourSlotInfoToJson(TourSlotInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourDate': instance.tourDate,
      'status': instance.status,
      'tourTitle': instance.tourTitle,
    };

BookingStatistics _$BookingStatisticsFromJson(Map<String, dynamic> json) =>
    BookingStatistics(
      totalBookings: (json['totalBookings'] as num).toInt(),
      checkedInCount: (json['checkedInCount'] as num).toInt(),
      pendingCount: (json['pendingCount'] as num).toInt(),
      totalGuests: (json['totalGuests'] as num).toInt(),
    );

Map<String, dynamic> _$BookingStatisticsToJson(BookingStatistics instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'checkedInCount': instance.checkedInCount,
      'pendingCount': instance.pendingCount,
      'totalGuests': instance.totalGuests,
    };
