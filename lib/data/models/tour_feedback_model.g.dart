// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTourFeedbackRequest _$CreateTourFeedbackRequestFromJson(
        Map<String, dynamic> json) =>
    CreateTourFeedbackRequest(
      bookingId: json['bookingId'] as String,
      tourRating: (json['tourRating'] as num?)?.toInt(),
      tourComment: json['tourComment'] as String?,
      guideRating: (json['guideRating'] as num?)?.toInt(),
      guideComment: json['guideComment'] as String?,
    );

Map<String, dynamic> _$CreateTourFeedbackRequestToJson(
        CreateTourFeedbackRequest instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'tourRating': instance.tourRating,
      'tourComment': instance.tourComment,
      'guideRating': instance.guideRating,
      'guideComment': instance.guideComment,
    };

UpdateTourFeedbackRequest _$UpdateTourFeedbackRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateTourFeedbackRequest(
      tourRating: (json['tourRating'] as num?)?.toInt(),
      tourComment: json['tourComment'] as String?,
      guideRating: (json['guideRating'] as num?)?.toInt(),
      guideComment: json['guideComment'] as String?,
    );

Map<String, dynamic> _$UpdateTourFeedbackRequestToJson(
        UpdateTourFeedbackRequest instance) =>
    <String, dynamic>{
      'tourRating': instance.tourRating,
      'tourComment': instance.tourComment,
      'guideRating': instance.guideRating,
      'guideComment': instance.guideComment,
    };

TourFeedbackModel _$TourFeedbackModelFromJson(Map<String, dynamic> json) =>
    TourFeedbackModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      slotId: json['slotId'] as String,
      userId: json['userId'] as String,
      tourRating: (json['tourRating'] as num).toInt(),
      tourComment: json['tourComment'] as String?,
      guideRating: (json['guideRating'] as num?)?.toInt(),
      guideComment: json['guideComment'] as String?,
      tourGuideId: json['tourGuideId'] as String?,
      tourGuideName: json['tourGuideName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TourFeedbackModelToJson(TourFeedbackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'slotId': instance.slotId,
      'userId': instance.userId,
      'tourRating': instance.tourRating,
      'tourComment': instance.tourComment,
      'guideRating': instance.guideRating,
      'guideComment': instance.guideComment,
      'tourGuideId': instance.tourGuideId,
      'tourGuideName': instance.tourGuideName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

TourFeedbackResponse _$TourFeedbackResponseFromJson(
        Map<String, dynamic> json) =>
    TourFeedbackResponse(
      feedbacks: (json['feedbacks'] as List<dynamic>)
          .map((e) => TourFeedbackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      pageIndex: (json['pageIndex'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
      stats: json['stats'] == null
          ? null
          : TourFeedbackStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourFeedbackResponseToJson(
        TourFeedbackResponse instance) =>
    <String, dynamic>{
      'feedbacks': instance.feedbacks,
      'totalCount': instance.totalCount,
      'pageIndex': instance.pageIndex,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
      'stats': instance.stats,
    };

TourFeedbackStats _$TourFeedbackStatsFromJson(Map<String, dynamic> json) =>
    TourFeedbackStats(
      averageTourRating: (json['averageTourRating'] as num).toDouble(),
      averageGuideRating: (json['averageGuideRating'] as num).toDouble(),
      totalFeedbacks: (json['totalFeedbacks'] as num).toInt(),
      tourRatingDistribution:
          (json['tourRatingDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      guideRatingDistribution:
          (json['guideRatingDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$TourFeedbackStatsToJson(TourFeedbackStats instance) =>
    <String, dynamic>{
      'averageTourRating': instance.averageTourRating,
      'averageGuideRating': instance.averageGuideRating,
      'totalFeedbacks': instance.totalFeedbacks,
      'tourRatingDistribution': instance.tourRatingDistribution
          .map((k, e) => MapEntry(k.toString(), e)),
      'guideRatingDistribution': instance.guideRatingDistribution
          .map((k, e) => MapEntry(k.toString(), e)),
    };
