import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/timeline_progress_models.dart';
import '../models/user_tour_booking_model.dart';
import '../models/tour_feedback_model.dart';
import '../../core/constants/api_constants.dart';

part 'user_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl}) = _UserApiService;

  /// Get user's tour bookings with pagination
  @GET('/UserTourBooking/my-bookings')
  Future<UserBookingsResponse> getMyBookings({
    @Query('pageIndex') int pageIndex = 1,
    @Query('pageSize') int pageSize = 10,
  });

  /// Get detailed booking information
  @GET('/UserTourBooking/booking-details/{bookingId}')
  Future<UserTourBookingDetailResponse> getBookingDetails(
    @Path('bookingId') String bookingId,
  );

  /// Get tour timeline for user (read-only view)
  @GET('/TourDetails/{tourDetailsId}/timeline')
  Future<TourTimelineResponse> getTourTimeline(
    @Path('tourDetailsId') String tourDetailsId, {
    @Query('includeInactive') bool includeInactive = false,
    @Query('includeShopInfo') bool includeShopInfo = true,
  });

  /// Submit tour feedback
  @POST('/TourBooking/Feedback-Tour')
  Future<TourFeedbackModel> submitTourFeedback(
    @Body() CreateTourFeedbackRequest request,
  );

  /// Get feedback for a tour slot
  @GET('/TourBooking/Feedback-by-slot/{slotId}')
  Future<TourFeedbackResponse> getFeedbackBySlot(
    @Path('slotId') String slotId, {
    @Query('pageIndex') int pageIndex = 1,
    @Query('pageSize') int pageSize = 10,
    @Query('minTourRating') int? minTourRating,
    @Query('maxTourRating') int? maxTourRating,
    @Query('onlyWithGuideRating') bool? onlyWithGuideRating,
  });

  /// Cancel booking (if allowed)
  @POST('/UserTourBooking/cancel-booking/{bookingId}')
  Future<void> cancelBooking(
    @Path('bookingId') String bookingId,
  );

  /// Resend QR ticket
  @POST('/UserTourBooking/resend-qr-ticket/{bookingId}')
  Future<ResendQRTicketResultModel> resendQRTicket(
    @Path('bookingId') String bookingId,
  );

  /// Get user dashboard summary
  @GET('/UserTourBooking/dashboard-summary')
  Future<UserDashboardResponse> getDashboardSummary();

  /// Get tour progress for ongoing tour


  /// Get user's own feedbacks
  @GET('/TourBooking/my-feedbacks')
  Future<MyFeedbacksResponse> getMyFeedbacks({
    @Query('pageIndex') int pageIndex = 1,
    @Query('pageSize') int pageSize = 10,
  });

  /// Update user's feedback
  @PUT('/TourBooking/feedback/{feedbackId}')
  Future<void> updateFeedback(
    @Path('feedbackId') String feedbackId,
    @Body() UpdateTourFeedbackRequest request,
  );

  /// Delete user's feedback
  @DELETE('/TourBooking/feedback/{feedbackId}')
  Future<void> deleteFeedback(
    @Path('feedbackId') String feedbackId,
  );

  /// Report incident from user perspective
  @POST('/TourGuide/incident/report')
  Future<void> reportIncident(
    @Body() UserIncidentReportRequest request,
  );


  @GET('/UserTourBooking/tour-slot/{tourSlotId}/timeline')
  @Headers({'No-Auth': 'true'}) // Public endpoint
  Future<Map<String, dynamic>> getUserTourSlotTimelineRaw(
    @Path('tourSlotId') String tourSlotId,
  );

  /// Create support ticket (alternative for user incident reporting)
  @POST('/SupportTickets')
  @MultiPart()
  Future<bool> createSupportTicket({
    @Part(name: 'Title') required String title,
    @Part(name: 'Content') required String content,
  });
}

// Response wrapper classes
@JsonSerializable()
class UserTourBookingDetailResponse {
  final bool success;
  final String message;
  final UserTourBookingModel data;

  const UserTourBookingDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserTourBookingDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$UserTourBookingDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserTourBookingDetailResponseToJson(this);
}

@JsonSerializable()
class TourTimelineResponse {
  final TourTimelineData data;
  final int statusCode;
  final String message;
  final bool success;
  final List<String> validationErrors;
  final Map<String, List<String>> fieldErrors;

  const TourTimelineResponse({
    required this.data,
    required this.statusCode,
    required this.message,
    required this.success,
    required this.validationErrors,
    required this.fieldErrors,
  });

  factory TourTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$TourTimelineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TourTimelineResponseToJson(this);
}

@JsonSerializable()
class TourTimelineData {
  final String tourTemplateId;
  final String tourTemplateTitle;
  final int duration;
  final String startLocation;
  final String endLocation;
  final List<TourTimelineItemData> items;
  final int totalItems;
  final int totalDuration;
  final int totalStops;
  final String earliestTime;
  final String latestTime;
  final int shopsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TourTimelineData({
    required this.tourTemplateId,
    required this.tourTemplateTitle,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.items,
    required this.totalItems,
    required this.totalDuration,
    required this.totalStops,
    required this.earliestTime,
    required this.latestTime,
    required this.shopsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TourTimelineData.fromJson(Map<String, dynamic> json) =>
      _$TourTimelineDataFromJson(json);

  Map<String, dynamic> toJson() => _$TourTimelineDataToJson(this);
}

@JsonSerializable()
class TourTimelineItemData {
  final String id;
  final String tourDetailsId;
  final String checkInTime;
  final String activity;
  final String? specialtyShopId;
  final int sortOrder;
  final SpecialtyShopData? specialtyShop;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TourTimelineItemData({
    required this.id,
    required this.tourDetailsId,
    required this.checkInTime,
    required this.activity,
    this.specialtyShopId,
    required this.sortOrder,
    this.specialtyShop,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TourTimelineItemData.fromJson(Map<String, dynamic> json) =>
      _$TourTimelineItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$TourTimelineItemDataToJson(this);
}

@JsonSerializable()
class SpecialtyShopData {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phoneNumber;

  const SpecialtyShopData({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phoneNumber,
  });

  factory SpecialtyShopData.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyShopDataFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialtyShopDataToJson(this);
}

@JsonSerializable()
class UserIncidentReportRequest {
  final String tourOperationId;
  final String title;
  final String description;
  final String severity;
  final List<String>? imageUrls;
  final String? location;

  const UserIncidentReportRequest({
    required this.tourOperationId,
    required this.title,
    required this.description,
    required this.severity,
    this.imageUrls,
    this.location,
  });

  factory UserIncidentReportRequest.fromJson(Map<String, dynamic> json) =>
      _$UserIncidentReportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserIncidentReportRequestToJson(this);
}
