import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/active_tour_model.dart';
import '../models/tour_booking_model.dart';
import '../models/timeline_item_model.dart';
import '../models/tour_invitation_model.dart';
import '../../core/constants/api_constants.dart';

part 'tour_guide_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class TourGuideApiService {
  factory TourGuideApiService(Dio dio, {String baseUrl}) = _TourGuideApiService;
  
  /// Get active tours for current tour guide
  @GET(ApiConstants.myActiveTours)
  Future<List<ActiveTourModel>> getMyActiveTours();

  /// Get tour bookings for a specific tour operation
  @GET('/TourGuide/tour/{operationId}/bookings')
  Future<List<TourBookingModel>> getTourBookings(
    @Path('operationId') String operationId,
  );

  /// Get tour timeline for a specific tour operation
  @GET('/TourGuide/tour/{operationId}/timeline')
  Future<List<TimelineItemModel>> getTourTimeline(
    @Path('operationId') String operationId,
  );
  
  /// Check-in a guest
  @POST('/TourGuide/checkin/{bookingId}')
  Future<void> checkInGuest(
    @Path('bookingId') String bookingId,
    @Body() CheckInRequest request,
  );

  /// Complete a timeline item
  @POST('/TourGuide/timeline/{timelineId}/complete')
  Future<void> completeTimelineItem(
    @Path('timelineId') String timelineId,
    @Body() CompleteTimelineRequest request,
  );

  /// Report an incident
  @POST(ApiConstants.reportIncident)
  Future<void> reportIncident(
    @Body() ReportIncidentRequest request,
  );

  /// Notify guests
  @POST('/TourGuide/tour/{operationId}/notify-guests')
  Future<void> notifyGuests(
    @Path('operationId') String operationId,
    @Body() NotifyGuestsRequest request,
  );

  /// Get my tour invitations
  @GET(ApiConstants.myInvitations)
  Future<MyInvitationsResponseModel> getMyInvitations(
    @Query('status') String? status,
  );

  /// Accept tour invitation
  @POST('/TourGuideInvitation/{invitationId}/accept')
  Future<void> acceptInvitation(
    @Path('invitationId') String invitationId,
    @Body() Map<String, dynamic> request,
  );

  /// Reject tour invitation
  @POST('/TourGuideInvitation/{invitationId}/reject')
  Future<void> rejectInvitation(
    @Path('invitationId') String invitationId,
    @Body() Map<String, dynamic> request,
  );
}



/// Check-in request
class CheckInRequest {
  final String? qrCodeData;
  final String? notes;
  
  CheckInRequest({
    this.qrCodeData,
    this.notes,
  });
  
  Map<String, dynamic> toJson() => {
    'qrCodeData': qrCodeData,
    'notes': notes,
  };
}

/// Complete timeline request
class CompleteTimelineRequest {
  final String? notes;
  
  CompleteTimelineRequest({
    this.notes,
  });
  
  Map<String, dynamic> toJson() => {
    'notes': notes,
  };
}

/// Report incident request
class ReportIncidentRequest {
  final String tourOperationId;
  final String title;
  final String description;
  final String severity;
  final List<String>? imageUrls;
  
  ReportIncidentRequest({
    required this.tourOperationId,
    required this.title,
    required this.description,
    required this.severity,
    this.imageUrls,
  });
  
  Map<String, dynamic> toJson() => {
    'tourOperationId': tourOperationId,
    'title': title,
    'description': description,
    'severity': severity,
    'imageUrls': imageUrls,
  };
}

/// Notify guests request
class NotifyGuestsRequest {
  final String message;
  final bool isUrgent;
  
  NotifyGuestsRequest({
    required this.message,
    this.isUrgent = false,
  });
  
  Map<String, dynamic> toJson() => {
    'message': message,
    'isUrgent': isUrgent,
  };
}
