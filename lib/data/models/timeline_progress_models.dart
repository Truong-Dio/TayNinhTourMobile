import 'package:json_annotation/json_annotation.dart';
import 'specialty_shop_model.dart';

part 'timeline_progress_models.g.dart';

/// Timeline item with progress information
@JsonSerializable()
class TimelineWithProgressDto {
  final String id;
  final String tourSlotId;
  final String? progressId;
  final String activity;
  final String checkInTime;
  final int sortOrder;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completionNotes;
  final bool canComplete;
  final SpecialtyShopModel? specialtyShop;
  final String? completedByName;
  final int? completionDurationMinutes;
  final String statusText;
  final bool isNext;
  final int position;
  final int totalItems;

  TimelineWithProgressDto({
    required this.id,
    required this.tourSlotId,
    this.progressId,
    required this.activity,
    required this.checkInTime,
    required this.sortOrder,
    required this.isCompleted,
    this.completedAt,
    this.completionNotes,
    required this.canComplete,
    this.specialtyShop,
    this.completedByName,
    this.completionDurationMinutes,
    required this.statusText,
    required this.isNext,
    required this.position,
    required this.totalItems,
  });

  factory TimelineWithProgressDto.fromJson(Map<String, dynamic> json) =>
      _$TimelineWithProgressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineWithProgressDtoToJson(this);

  /// Get progress percentage (0 or 100)
  int get progressPercentage => isCompleted ? 100 : 0;

  /// Get CSS class for status styling
  String get statusClass => isCompleted ? 'completed' : canComplete ? 'active' : 'pending';

  /// Get icon name for status display
  String get statusIcon => isCompleted ? 'check-circle' : canComplete ? 'play-circle' : 'clock-circle';

  /// Check if this item is overdue
  bool isOverdue() {
    if (isCompleted) return false;
    final now = DateTime.now();
    final checkInDateTime = DateTime.parse('${now.toIso8601String().split('T')[0]}T$checkInTime:00');
    return checkInDateTime.isBefore(now);
  }
}

/// Progress summary for timeline
@JsonSerializable()
class TimelineProgressSummaryDto {
  final String tourSlotId;
  final int totalItems;
  final int completedItems;
  final TimelineWithProgressDto? nextItem;
  final TimelineWithProgressDto? lastCompletedItem;
  final DateTime? estimatedCompletionTime;

  TimelineProgressSummaryDto({
    required this.tourSlotId,
    required this.totalItems,
    required this.completedItems,
    this.nextItem,
    this.lastCompletedItem,
    this.estimatedCompletionTime,
  });

  factory TimelineProgressSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TimelineProgressSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineProgressSummaryDtoToJson(this);

  /// Number of pending items
  int get pendingItems => totalItems - completedItems;

  /// Overall progress percentage
  int get progressPercentage => totalItems > 0 ? (completedItems * 100) ~/ totalItems : 0;

  /// Whether all timeline items are completed
  bool get isFullyCompleted => completedItems == totalItems && totalItems > 0;

  /// Status text for overall progress
  String get statusText => isFullyCompleted ? 'Hoàn thành' : '$completedItems/$totalItems hoàn thành';
}

/// Timeline progress response
@JsonSerializable()
class TimelineProgressResponse {
  final List<TimelineWithProgressDto> timeline;
  final TimelineProgressSummaryDto summary;
  final TourSlotInfoDto tourSlot;
  final TourDetailsInfoDto tourDetails;
  final bool canModifyProgress;
  final DateTime lastUpdated;

  TimelineProgressResponse({
    required this.timeline,
    required this.summary,
    required this.tourSlot,
    required this.tourDetails,
    required this.canModifyProgress,
    required this.lastUpdated,
  });

  factory TimelineProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$TimelineProgressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineProgressResponseToJson(this);
}

/// Tour slot information
@JsonSerializable()
class TourSlotInfoDto {
  final String id;
  final String tourDate;
  final int currentBookings;
  final int maxGuests;
  final String status;

  TourSlotInfoDto({
    required this.id,
    required this.tourDate,
    required this.currentBookings,
    required this.maxGuests,
    required this.status,
  });

  factory TourSlotInfoDto.fromJson(Map<String, dynamic> json) =>
      _$TourSlotInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TourSlotInfoDtoToJson(this);
}

/// Tour details information
@JsonSerializable()
class TourDetailsInfoDto {
  final String id;
  final String title;
  final String description;
  final String status;
  final List<String> imageUrls;

  TourDetailsInfoDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.imageUrls,
  });

  factory TourDetailsInfoDto.fromJson(Map<String, dynamic> json) =>
      _$TourDetailsInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TourDetailsInfoDtoToJson(this);
}

/// Complete timeline response
@JsonSerializable()
class CompleteTimelineResponse {
  final bool success;
  final String message;
  final TimelineWithProgressDto? completedItem;
  final TimelineProgressSummaryDto? summary;
  final TimelineWithProgressDto? nextItem;
  final bool isTimelineCompleted;
  final DateTime completedAt;
  final List<String> warnings;

  CompleteTimelineResponse({
    required this.success,
    required this.message,
    this.completedItem,
    this.summary,
    this.nextItem,
    required this.isTimelineCompleted,
    required this.completedAt,
    required this.warnings,
  });

  factory CompleteTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$CompleteTimelineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTimelineResponseToJson(this);
}

/// Bulk timeline response
@JsonSerializable()
class BulkTimelineResponse {
  final int successCount;
  final int failureCount;
  final int totalCount;
  final List<String> successfulItems;
  final List<BulkOperationError> failedItems;
  final TimelineProgressSummaryDto? summary;
  final String message;

  BulkTimelineResponse({
    required this.successCount,
    required this.failureCount,
    required this.totalCount,
    required this.successfulItems,
    required this.failedItems,
    this.summary,
    required this.message,
  });

  factory BulkTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$BulkTimelineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BulkTimelineResponseToJson(this);

  /// Whether the operation was completely successful
  bool get isFullySuccessful => failureCount == 0;

  /// Whether the operation was partially successful
  bool get isPartiallySuccessful => successCount > 0 && failureCount > 0;
}

/// Bulk operation error
@JsonSerializable()
class BulkOperationError {
  final String itemId;
  final String errorMessage;
  final String errorCode;

  BulkOperationError({
    required this.itemId,
    required this.errorMessage,
    required this.errorCode,
  });

  factory BulkOperationError.fromJson(Map<String, dynamic> json) =>
      _$BulkOperationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$BulkOperationErrorToJson(this);
}

/// Timeline statistics response
@JsonSerializable()
class TimelineStatisticsResponse {
  final String tourSlotId;
  final double averageCompletionTimeMinutes;
  final double totalTimeMinutes;
  final double completionRate;
  final int onTimeCompletions;
  final int overdueCompletions;
  final TimelineWithProgressDto? slowestItem;
  final TimelineWithProgressDto? fastestItem;
  final List<CompletionTrendPoint> completionTrend;

  TimelineStatisticsResponse({
    required this.tourSlotId,
    required this.averageCompletionTimeMinutes,
    required this.totalTimeMinutes,
    required this.completionRate,
    required this.onTimeCompletions,
    required this.overdueCompletions,
    this.slowestItem,
    this.fastestItem,
    required this.completionTrend,
  });

  factory TimelineStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$TimelineStatisticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineStatisticsResponseToJson(this);
}

/// Completion trend point
@JsonSerializable()
class CompletionTrendPoint {
  final DateTime time;
  final double completionPercentage;
  final int itemsCompleted;

  CompletionTrendPoint({
    required this.time,
    required this.completionPercentage,
    required this.itemsCompleted,
  });

  factory CompletionTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$CompletionTrendPointFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionTrendPointToJson(this);
}
