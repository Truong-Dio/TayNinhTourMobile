import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tour_feedback.dart';

part 'tour_feedback_model.g.dart';

@JsonSerializable()
class CreateTourFeedbackRequest {
  final String bookingId;
  final int? tourRating;
  final String? tourComment;
  final int? guideRating;
  final String? guideComment;

  const CreateTourFeedbackRequest({
    required this.bookingId,
    this.tourRating,
    this.tourComment,
    this.guideRating,
    this.guideComment,
  });

  factory CreateTourFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTourFeedbackRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTourFeedbackRequestToJson(this);
}

@JsonSerializable()
class UpdateTourFeedbackRequest {
  final int? tourRating;
  final String? tourComment;
  final int? guideRating;
  final String? guideComment;

  const UpdateTourFeedbackRequest({
    this.tourRating,
    this.tourComment,
    this.guideRating,
    this.guideComment,
  });

  factory UpdateTourFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTourFeedbackRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTourFeedbackRequestToJson(this);
}

@JsonSerializable()
class TourFeedbackModel extends TourFeedback {
  const TourFeedbackModel({
    required super.id,
    required super.bookingId,
    required super.slotId,
    required super.userId,
    required super.tourRating,
    super.tourComment,
    super.guideRating,
    super.guideComment,
    super.tourGuideId,
    super.tourGuideName,
    required super.createdAt,
  });

  factory TourFeedbackModel.fromJson(Map<String, dynamic> json) => 
      _$TourFeedbackModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourFeedbackModelToJson(this);

  factory TourFeedbackModel.fromEntity(TourFeedback feedback) {
    return TourFeedbackModel(
      id: feedback.id,
      bookingId: feedback.bookingId,
      slotId: feedback.slotId,
      userId: feedback.userId,
      tourRating: feedback.tourRating,
      tourComment: feedback.tourComment,
      guideRating: feedback.guideRating,
      guideComment: feedback.guideComment,
      tourGuideId: feedback.tourGuideId,
      tourGuideName: feedback.tourGuideName,
      createdAt: feedback.createdAt,
    );
  }

  TourFeedback toEntity() {
    return TourFeedback(
      id: id,
      bookingId: bookingId,
      slotId: slotId,
      userId: userId,
      tourRating: tourRating,
      tourComment: tourComment,
      guideRating: guideRating,
      guideComment: guideComment,
      tourGuideId: tourGuideId,
      tourGuideName: tourGuideName,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class TourFeedbackResponse {
  final List<TourFeedbackModel> feedbacks;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final TourFeedbackStats? stats;

  const TourFeedbackResponse({
    required this.feedbacks,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.stats,
  });

  factory TourFeedbackResponse.fromJson(Map<String, dynamic> json) => 
      _$TourFeedbackResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TourFeedbackResponseToJson(this);
}

@JsonSerializable()
class TourFeedbackStats {
  final double averageTourRating;
  final double averageGuideRating;
  final int totalFeedbacks;
  final Map<int, int> tourRatingDistribution;
  final Map<int, int> guideRatingDistribution;

  const TourFeedbackStats({
    required this.averageTourRating,
    required this.averageGuideRating,
    required this.totalFeedbacks,
    required this.tourRatingDistribution,
    required this.guideRatingDistribution,
  });

  factory TourFeedbackStats.fromJson(Map<String, dynamic> json) =>
      _$TourFeedbackStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TourFeedbackStatsToJson(this);
}

// My Feedbacks Response Model (different structure)
@JsonSerializable()
class MyFeedbacksResponse {
  final int statusCode;
  final String message;
  final bool success;
  final List<TourFeedbackModel>? data;
  final int totalPages;
  final int totalRecord;
  final int totalCount;
  final int pageIndex;
  final int pageSize;

  const MyFeedbacksResponse({
    required this.statusCode,
    required this.message,
    required this.success,
    this.data,
    required this.totalPages,
    required this.totalRecord,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
  });

  factory MyFeedbacksResponse.fromJson(Map<String, dynamic> json) =>
      _$MyFeedbacksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyFeedbacksResponseToJson(this);

  // Convert to TourFeedbackResponse for compatibility
  TourFeedbackResponse toTourFeedbackResponse() {
    return TourFeedbackResponse(
      feedbacks: data ?? [],
      totalCount: totalCount,
      pageIndex: pageIndex,
      pageSize: pageSize,
      totalPages: totalPages,
      hasPreviousPage: pageIndex > 1,
      hasNextPage: pageIndex < totalPages,
      stats: null,
    );
  }
}


