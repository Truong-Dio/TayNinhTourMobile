import 'package:json_annotation/json_annotation.dart';
import 'tour_booking_model.dart';

part 'tour_guide_slot_models.g.dart';

/// Model for TourSlot in tour guide context
@JsonSerializable()
class TourGuideSlotModel {
  final String id;
  final String tourDate;
  final String status;
  @JsonKey(name: 'tourDetails')
  final TourDetailsInfo tourDetails;
  @JsonKey(name: 'bookingStats')
  final BookingStatsModel bookingStats;

  const TourGuideSlotModel({
    required this.id,
    required this.tourDate,
    required this.status,
    required this.tourDetails,
    required this.bookingStats,
  });

  factory TourGuideSlotModel.fromJson(Map<String, dynamic> json) => _$TourGuideSlotModelFromJson(json);
  Map<String, dynamic> toJson() => _$TourGuideSlotModelToJson(this);
}

/// Model for TourDetails info in TourSlot
@JsonSerializable()
class TourDetailsInfo {
  final String id;
  final String title;
  final String? description;
  final String? startLocation;
  final String? endLocation;

  const TourDetailsInfo({
    required this.id,
    required this.title,
    this.description,
    this.startLocation,
    this.endLocation,
  });

  factory TourDetailsInfo.fromJson(Map<String, dynamic> json) => _$TourDetailsInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TourDetailsInfoToJson(this);
}

/// Model for booking statistics
@JsonSerializable()
class BookingStatsModel {
  final int totalBookings;
  final int checkedInCount;
  final int totalGuests;

  const BookingStatsModel({
    required this.totalBookings,
    required this.checkedInCount,
    required this.totalGuests,
  });

  factory BookingStatsModel.fromJson(Map<String, dynamic> json) => _$BookingStatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookingStatsModelToJson(this);
}

/// Response model for tour slot bookings API
@JsonSerializable()
class TourSlotBookingsResponse {
  @JsonKey(name: 'tourSlot')
  final TourSlotInfo tourSlot;
  final List<TourBookingModel> bookings;
  final BookingStatistics statistics;

  const TourSlotBookingsResponse({
    required this.tourSlot,
    required this.bookings,
    required this.statistics,
  });

  factory TourSlotBookingsResponse.fromJson(Map<String, dynamic> json) => _$TourSlotBookingsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourSlotBookingsResponseToJson(this);
}

/// Model for TourSlot info in bookings response
@JsonSerializable()
class TourSlotInfo {
  final String id;
  final String tourDate;
  final String status;
  final String tourTitle;

  const TourSlotInfo({
    required this.id,
    required this.tourDate,
    required this.status,
    required this.tourTitle,
  });

  factory TourSlotInfo.fromJson(Map<String, dynamic> json) => _$TourSlotInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TourSlotInfoToJson(this);
}

/// Model for booking statistics in bookings response
@JsonSerializable()
class BookingStatistics {
  final int totalBookings;
  final int checkedInCount;
  final int pendingCount;
  final int totalGuests;

  const BookingStatistics({
    required this.totalBookings,
    required this.checkedInCount,
    required this.pendingCount,
    required this.totalGuests,
  });

  factory BookingStatistics.fromJson(Map<String, dynamic> json) => _$BookingStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$BookingStatisticsToJson(this);
}
