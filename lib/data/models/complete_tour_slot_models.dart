import 'package:json_annotation/json_annotation.dart';

part 'complete_tour_slot_models.g.dart';

/// Request model for completing a tour slot
@JsonSerializable()
class CompleteTourSlotRequest {
  @JsonKey(name: 'notes')
  final String? notes;

  const CompleteTourSlotRequest({
    this.notes,
  });

  factory CompleteTourSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteTourSlotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTourSlotRequestToJson(this);
}

/// Response model for completing a tour slot
@JsonSerializable()
class CompleteTourSlotResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final CompleteTourSlotData? data;

  const CompleteTourSlotResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CompleteTourSlotResponse.fromJson(Map<String, dynamic> json) =>
      _$CompleteTourSlotResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTourSlotResponseToJson(this);
}

/// Data model for completed tour slot response
@JsonSerializable()
class CompleteTourSlotData {
  @JsonKey(name: 'tourSlot')
  final CompletedTourSlotInfo? tourSlot;

  @JsonKey(name: 'statistics')
  final CompletionStatistics? statistics;

  const CompleteTourSlotData({
    this.tourSlot,
    this.statistics,
  });

  factory CompleteTourSlotData.fromJson(Map<String, dynamic> json) =>
      _$CompleteTourSlotDataFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTourSlotDataToJson(this);
}

/// Model for completed tour slot information
@JsonSerializable()
class CompletedTourSlotInfo {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'tourDate')
  final String tourDate;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'statusName')
  final String statusName;

  @JsonKey(name: 'completedAt')
  final String completedAt;

  @JsonKey(name: 'completedByGuideId')
  final String completedByGuideId;

  @JsonKey(name: 'completedByGuideName')
  final String completedByGuideName;

  @JsonKey(name: 'notes')
  final String? notes;

  const CompletedTourSlotInfo({
    required this.id,
    required this.tourDate,
    required this.status,
    required this.statusName,
    required this.completedAt,
    required this.completedByGuideId,
    required this.completedByGuideName,
    this.notes,
  });

  factory CompletedTourSlotInfo.fromJson(Map<String, dynamic> json) =>
      _$CompletedTourSlotInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CompletedTourSlotInfoToJson(this);
}

/// Model for completion statistics
@JsonSerializable()
class CompletionStatistics {
  @JsonKey(name: 'totalBookedGuests')
  final int totalBookedGuests;

  @JsonKey(name: 'completedBookings')
  final int completedBookings;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  @JsonKey(name: 'guestsNotified')
  final int guestsNotified;

  @JsonKey(name: 'occupancyRate')
  final double occupancyRate;

  const CompletionStatistics({
    required this.totalBookedGuests,
    required this.completedBookings,
    required this.totalRevenue,
    required this.guestsNotified,
    required this.occupancyRate,
  });

  factory CompletionStatistics.fromJson(Map<String, dynamic> json) =>
      _$CompletionStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionStatisticsToJson(this);
}
