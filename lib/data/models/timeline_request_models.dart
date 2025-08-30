import 'package:json_annotation/json_annotation.dart';

part 'timeline_request_models.g.dart';

/// Request for completing a timeline item
@JsonSerializable()
class CompleteTimelineRequest {
  final String? notes;
  final DateTime? completionTime;

  CompleteTimelineRequest({
    this.notes,
    this.completionTime,
  });

  factory CompleteTimelineRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteTimelineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTimelineRequestToJson(this);

  /// Validate the request
  List<String> validate() {
    final errors = <String>[];

    if (notes != null && notes!.length > 500) {
      errors.add('Ghi chú không được vượt quá 500 ký tự');
    }

    if (completionTime != null && completionTime!.isAfter(DateTime.now())) {
      errors.add('Thời gian hoàn thành không được trong tương lai');
    }

    return errors;
  }

  /// Get the effective completion time (provided time or current time)
  DateTime getEffectiveCompletionTime() {
    return completionTime ?? DateTime.now();
  }
}

/// Request for bulk completing multiple timeline items
@JsonSerializable()
class BulkCompleteTimelineRequest {
  final List<String> timelineItemIds;
  final String tourSlotId;
  final String? notes;
  final bool respectSequentialOrder;

  BulkCompleteTimelineRequest({
    required this.timelineItemIds,
    required this.tourSlotId,
    this.notes,
    this.respectSequentialOrder = true,
  });

  factory BulkCompleteTimelineRequest.fromJson(Map<String, dynamic> json) =>
      _$BulkCompleteTimelineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkCompleteTimelineRequestToJson(this);

  /// Validate the request
  List<String> validate() {
    final errors = <String>[];

    if (timelineItemIds.isEmpty) {
      errors.add('Danh sách timeline items là bắt buộc');
    }

    if (tourSlotId.isEmpty) {
      errors.add('Tour slot ID là bắt buộc');
    }

    if (notes != null && notes!.length > 500) {
      errors.add('Ghi chú không được vượt quá 500 ký tự');
    }

    // Check for duplicate IDs
    if (timelineItemIds.toSet().length != timelineItemIds.length) {
      errors.add('Danh sách timeline items chứa ID trùng lặp');
    }

    return errors;
  }
}

/// Request for resetting timeline item completion
@JsonSerializable()
class ResetTimelineRequest {
  final String reason;
  final bool resetSubsequentItems;

  ResetTimelineRequest({
    required this.reason,
    this.resetSubsequentItems = true,
  });

  factory ResetTimelineRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetTimelineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetTimelineRequestToJson(this);

  /// Validate the request
  List<String> validate() {
    final errors = <String>[];

    if (reason.trim().isEmpty) {
      errors.add('Lý do reset là bắt buộc');
    }

    if (reason.length > 500) {
      errors.add('Lý do không được vượt quá 500 ký tự');
    }

    return errors;
  }
}

/// Request for getting timeline with progress
@JsonSerializable()
class GetTimelineProgressRequest {
  final String tourSlotId;
  final bool includeInactive;
  final bool includeShopInfo;
  final bool includeStatistics;
  final bool? completionFilter;

  GetTimelineProgressRequest({
    required this.tourSlotId,
    this.includeInactive = false,
    this.includeShopInfo = true,
    this.includeStatistics = true,
    this.completionFilter,
  });

  factory GetTimelineProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$GetTimelineProgressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetTimelineProgressRequestToJson(this);

  /// Validate the request
  List<String> validate() {
    final errors = <String>[];

    if (tourSlotId.trim().isEmpty) {
      errors.add('Tour slot ID là bắt buộc');
    }

    return errors;
  }
}

/// Helper class for timeline completion dialog
class TimelineCompletionDialog {
  final String timelineItemId;
  final String activity;
  final String checkInTime;
  final bool canComplete;
  final String? notes;

  TimelineCompletionDialog({
    required this.timelineItemId,
    required this.activity,
    required this.checkInTime,
    required this.canComplete,
    this.notes,
  });

  /// Create completion request from dialog data
  CompleteTimelineRequest toCompletionRequest() {
    return CompleteTimelineRequest(
      notes: notes,
      completionTime: DateTime.now(),
    );
  }
}

/// Helper class for bulk completion
class BulkCompletionHelper {
  final String tourSlotId;
  final List<String> selectedItemIds;
  final String? commonNotes;
  final bool respectOrder;

  BulkCompletionHelper({
    required this.tourSlotId,
    required this.selectedItemIds,
    this.commonNotes,
    this.respectOrder = true,
  });

  /// Create bulk completion request
  BulkCompleteTimelineRequest toBulkRequest() {
    return BulkCompleteTimelineRequest(
      timelineItemIds: selectedItemIds,
      tourSlotId: tourSlotId,
      notes: commonNotes,
      respectSequentialOrder: respectOrder,
    );
  }

  /// Validate selection
  List<String> validateSelection() {
    final errors = <String>[];

    if (selectedItemIds.isEmpty) {
      errors.add('Vui lòng chọn ít nhất 1 timeline item');
    }

    if (selectedItemIds.length > 10) {
      errors.add('Không thể chọn quá 10 timeline items cùng lúc');
    }

    return errors;
  }
}

/// Helper class for reset confirmation
class ResetConfirmationDialog {
  final String timelineItemId;
  final String activity;
  final DateTime? completedAt;
  final String? reason;
  final bool resetSubsequent;

  ResetConfirmationDialog({
    required this.timelineItemId,
    required this.activity,
    this.completedAt,
    this.reason,
    this.resetSubsequent = true,
  });

  /// Create reset request from dialog data
  ResetTimelineRequest toResetRequest() {
    return ResetTimelineRequest(
      reason: reason ?? 'Reset từ mobile app',
      resetSubsequentItems: resetSubsequent,
    );
  }

  /// Get confirmation message
  String getConfirmationMessage() {
    final baseMessage = 'Bạn có chắc muốn reset timeline item "$activity"?';
    if (resetSubsequent) {
      return '$baseMessage\n\nTất cả timeline items sau đó cũng sẽ bị reset.';
    }
    return baseMessage;
  }
}
