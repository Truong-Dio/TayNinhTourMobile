import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/active_tour_model.dart';
import '../models/tour_booking_model.dart';
import '../models/timeline_item_model.dart';
import '../models/timeline_progress_models.dart';
import '../models/timeline_request_models.dart';
import '../models/tour_invitation_model.dart';
import '../models/tour_slot_model.dart';
import '../models/tour_guide_slot_models.dart';
import '../models/individual_qr_models.dart';
import '../models/unified_checkin_models.dart';
import '../../core/constants/api_constants.dart';

part 'tour_guide_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class TourGuideApiService {
  factory TourGuideApiService(Dio dio, {String baseUrl}) = _TourGuideApiService;
  
  /// Get active tours for current tour guide
  @GET(ApiConstants.myActiveTours)
  Future<List<ActiveTourModel>> getMyActiveTours();

  /// [NEW] Get tour slots for current tour guide
  @GET('/TourGuide/my-tour-slots')
  Future<List<TourGuideSlotModel>> getMyTourSlots(
    @Query('fromDate') String? fromDate,
  );

  /// [NEW] Get tour bookings for a specific tour slot
  @GET('/TourGuide/tour-slot/{tourSlotId}/bookings')
  Future<TourSlotBookingsResponse> getTourSlotBookings(
    @Path('tourSlotId') String tourSlotId,
  );

  /// [LEGACY] Get tour bookings for a specific tour operation - for backward compatibility
  @GET('/TourGuide/tour/{operationId}/bookings')
  Future<List<TourBookingModel>> getTourBookings(
    @Path('operationId') String operationId,
  );

  /// Get tour timeline for a specific tour operation (LEGACY - for backward compatibility)
  @GET('/TourGuide/tour/{operationId}/timeline')
  Future<List<TimelineItemModel>> getTourTimeline(
    @Path('operationId') String operationId,
  );

  /// [NEW] Get timeline with progress for a specific tour slot
  @GET('/TourGuide/tour-slot/{tourSlotId}/timeline')
  Future<TimelineProgressResponse> getTourSlotTimeline(
    @Path('tourSlotId') String tourSlotId,
    @Query('includeInactive') bool? includeInactive,
    @Query('includeShopInfo') bool? includeShopInfo,
  );

  /// Check-in a guest
  @POST('/TourGuide/checkin/{bookingId}')
  Future<void> checkInGuest(
    @Path('bookingId') String bookingId,
    @Body() CheckInGuestRequest request,
  );

  /// Check-in a guest with override time restriction
  @POST('/TourGuide/checkin-override/{bookingId}')
  Future<void> checkInGuestWithOverride(
    @Path('bookingId') String bookingId,
    @Body() CheckInGuestWithOverrideRequest request,
  );

  /// ✅ NEW: Check-in individual guest by QR code (legacy endpoint)
  @POST('/TourGuide/check-in-guest-qr')
  Future<IndividualGuestCheckInResponse> checkInIndividualGuest(
    @Body() IndividualGuestCheckInRequest request,
  );

  /// ✅ NEW: Check-in guest by QR code (supports all QR formats)
  @POST('/TourGuide/check-in-guest-qr')
  Future<dynamic> checkInGuestByQRRaw(
    @Body() CheckInGuestByQRRequest request,
  );

  /// ✅ NEW: Unified check-in endpoint - Tự động nhận diện và xử lý QR code
  /// Hỗ trợ cả Individual Guest QR và Group Representative QR
  @POST('/TourGuide/check-in-unified')
  Future<UnifiedCheckInResponse> unifiedCheckIn(
    @Body() UnifiedCheckInRequest request,
  );

  /// ✅ NEW: Check-in group by QR code
  @POST('/TourGuide/check-in-group')
  Future<GroupCheckInResponse> checkInGroupByQR(
    @Body() CheckInGroupByQRRequest request,
  );

  /// ✅ NEW: Get guest status by guest ID
  @GET('/TourGuide/guest/{guestId}/status')
  Future<TourBookingGuestModel> getGuestStatus(
    @Path('guestId') String guestId,
  );

  /// ✅ NEW: Get all guests for a tour slot
  @GET('/TourGuide/tour-slot/{tourSlotId}/guests')
  Future<TourSlotGuestsResponse> getTourSlotGuests(
    @Path('tourSlotId') String tourSlotId,
  );

  /// ✅ NEW: Validate tourguide permission for tour slot
  @GET('/TourGuide/validate-permission/{tourSlotId}')
  Future<bool> validateTourguidePermission(
    @Path('tourSlotId') String tourSlotId,
  );

  /// Complete a timeline item (LEGACY - for backward compatibility)
  @POST('/TourGuide/timeline/{timelineId}/complete')
  Future<void> completeTimelineItem(
    @Path('timelineId') String timelineId,
    @Body() CompleteTimelineRequest request,
  );

  /// [NEW] Complete timeline item for a specific tour slot
  @POST('/TourGuide/tour-slot/{tourSlotId}/timeline/{timelineItemId}/complete')
  Future<CompleteTimelineResponse> completeTimelineItemForSlot(
    @Path('tourSlotId') String tourSlotId,
    @Path('timelineItemId') String timelineItemId,
    @Body() CompleteTimelineRequest request,
  );

  /// [NEW] Bulk complete multiple timeline items
  @POST('/TourGuide/timeline/bulk-complete')
  Future<BulkTimelineResponse> bulkCompleteTimelineItems(
    @Body() BulkCompleteTimelineRequest request,
  );

  /// [NEW] Reset timeline item completion
  @POST('/TourGuide/tour-slot/{tourSlotId}/timeline/{timelineItemId}/reset')
  Future<CompleteTimelineResponse> resetTimelineItem(
    @Path('tourSlotId') String tourSlotId,
    @Path('timelineItemId') String timelineItemId,
    @Body() ResetTimelineRequest request,
  );

  /// [NEW] Get progress summary for tour slot
  @GET('/TourGuide/tour-slot/{tourSlotId}/progress-summary')
  Future<TimelineProgressSummaryDto> getProgressSummary(
    @Path('tourSlotId') String tourSlotId,
  );

  /// [NEW] Get timeline statistics
  @GET('/TourGuide/tour-slot/{tourSlotId}/statistics')
  Future<TimelineStatisticsResponse> getTimelineStatistics(
    @Path('tourSlotId') String tourSlotId,
  );

  /// Report an incident
  @POST('/TourGuide/incident/report')
  Future<void> reportIncident(
    @Body() ReportIncidentRequest request,
  );

  /// Notify guests
  @POST('/TourGuide/tour/{operationId}/notify-guests')
  Future<void> notifyGuests(
    @Path('operationId') String operationId,
    @Body() NotifyGuestsRequest request,
  );

  /// Upload incident images
  @POST('/TourGuide/incident/upload-images')
  @MultiPart()
  Future<List<String>> uploadIncidentImages(
    @Part() List<MultipartFile> files,
  );

  /// Get tour slots by tour details ID
  @GET('/TourSlot')
  Future<TourSlotsResponse> getTourSlots(
    @Query('tourDetailsId') String tourDetailsId,
  );

  /// Get tour slot details with bookings
  @GET('/TourSlot/{tourSlotId}/tour-details-and-bookings')
  Future<TourSlotDetailsResponse> getTourSlotDetails(
    @Path('tourSlotId') String tourSlotId,
  );

  /// Get timeline for tour details
  @GET('/TourDetails/{tourDetailsId}/timeline')
  Future<TimelineResponse> getTimeline(
    @Path('tourDetailsId') String tourDetailsId,
    @Query('includeShopInfo') bool includeShopInfo,
  );

  /// Get my tour invitations
  @GET('/TourGuideInvitation/my-invitations')
  Future<MyInvitationsResponseModel> getMyInvitations(
    @Query('status') String? status,
  );

  /// Accept tour invitation
  @POST('/TourGuideInvitation/{invitationId}/accept')
  Future<void> acceptInvitation(
    @Path('invitationId') String invitationId,
  );

  /// Reject tour invitation
  @POST('/TourGuideInvitation/{invitationId}/reject')
  Future<void> rejectInvitation(
    @Path('invitationId') String invitationId,
  );

  /// Complete tour
  @POST('/TourGuide/tour/{operationId}/complete')
  Future<void> completeTour(
    @Path('operationId') String operationId,
  );


}

// TODO: Add TourSlotsResponse when needed
// class TourSlotsResponse {
//   final bool success;
//   final String message;
//   final List<TourSlotModel> data;
//   final int totalCount;
//   final String tourDetailsId;
// }



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

/// Upload images response
class UploadImagesResponse {
  final bool success;
  final String message;
  final List<String> data;

  UploadImagesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UploadImagesResponse.fromJson(Map<String, dynamic> json) => UploadImagesResponse(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: List<String>.from(json['data'] ?? []),
  );
}





/// Tour slot details response
class TourSlotDetailsResponse {
  final bool success;
  final String message;
  final TourSlotWithBookingsData data;

  TourSlotDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TourSlotDetailsResponse.fromJson(Map<String, dynamic> json) {
    try {
      return TourSlotDetailsResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: TourSlotWithBookingsData.fromJson(json['data'] ?? {}),
      );
    } catch (e) {
      print('Error parsing TourSlotDetailsResponse: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

/// Tour slot with bookings data (matches backend TourSlotWithBookingsDto)
class TourSlotWithBookingsData {
  final TourSlotDetailsInfo slot;
  final TourDetailsInfo? tourDetails;
  final List<BookedUserInfo> bookedUsers;
  final BookingStatistics statistics;

  TourSlotWithBookingsData({
    required this.slot,
    this.tourDetails,
    required this.bookedUsers,
    required this.statistics,
  });

  factory TourSlotWithBookingsData.fromJson(Map<String, dynamic> json) {
    try {
      return TourSlotWithBookingsData(
        slot: TourSlotDetailsInfo.fromJson(json['slot'] ?? {}),
        tourDetails: json['tourDetails'] != null ? TourDetailsInfo.fromJson(json['tourDetails']) : null,
        bookedUsers: (json['bookedUsers'] as List?)?.map((e) => BookedUserInfo.fromJson(e)).toList() ?? [],
        statistics: BookingStatistics.fromJson(json['statistics'] ?? {}),
      );
    } catch (e) {
      print('Error parsing TourSlotWithBookingsData: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

/// Tour slot details info
class TourSlotDetailsInfo {
  final String id;
  final String tourDate;
  final String status;
  final int maxGuests;
  final int currentBookings;
  final bool isActive;

  TourSlotDetailsInfo({
    required this.id,
    required this.tourDate,
    required this.status,
    required this.maxGuests,
    required this.currentBookings,
    required this.isActive,
  });

  factory TourSlotDetailsInfo.fromJson(Map<String, dynamic> json) => TourSlotDetailsInfo(
    id: json['id'] ?? '',
    tourDate: json['tourDate'] ?? '',
    status: json['status'] ?? '',
    maxGuests: json['maxGuests'] ?? 0,
    currentBookings: json['currentBookings'] ?? 0,
    isActive: json['isActive'] ?? false,
  );
}

/// Tour details info
class TourDetailsInfo {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> skillsRequired;
  final String status;
  final String statusName;
  final String createdAt;

  TourDetailsInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.skillsRequired,
    required this.status,
    required this.statusName,
    required this.createdAt,
  });

  factory TourDetailsInfo.fromJson(Map<String, dynamic> json) => TourDetailsInfo(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    skillsRequired: List<String>.from(json['skillsRequired'] ?? []),
    status: json['status'] ?? '',
    statusName: json['statusName'] ?? '',
    createdAt: json['createdAt'] ?? '',
  );
}

/// Booked user info
class BookedUserInfo {
  final String id;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final int numberOfGuests;
  final String status;
  final bool isCheckedIn;
  final String? checkInTime;
  final String? qrCodeData;

  BookedUserInfo({
    required this.id,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.numberOfGuests,
    required this.status,
    required this.isCheckedIn,
    this.checkInTime,
    this.qrCodeData,
  });

  factory BookedUserInfo.fromJson(Map<String, dynamic> json) => BookedUserInfo(
    id: json['id'] ?? '',
    contactName: json['contactName'] ?? '',
    contactPhone: json['contactPhone'] ?? '',
    contactEmail: json['contactEmail'] ?? '',
    numberOfGuests: json['numberOfGuests'] ?? 0,
    status: json['status'] ?? '',
    isCheckedIn: json['isCheckedIn'] ?? false,
    checkInTime: json['checkInTime'],
    qrCodeData: json['qrCodeData'],
  );
}

/// Booking statistics
class BookingStatistics {
  final int totalBookings;
  final int totalGuests;
  final int confirmedBookings;
  final int pendingBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double confirmedRevenue;
  final double occupancyRate;

  BookingStatistics({
    required this.totalBookings,
    required this.totalGuests,
    required this.confirmedBookings,
    required this.pendingBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.confirmedRevenue,
    required this.occupancyRate,
  });

  factory BookingStatistics.fromJson(Map<String, dynamic> json) => BookingStatistics(
    totalBookings: json['totalBookings'] ?? 0,
    totalGuests: json['totalGuests'] ?? 0,
    confirmedBookings: json['confirmedBookings'] ?? 0,
    pendingBookings: json['pendingBookings'] ?? 0,
    cancelledBookings: json['cancelledBookings'] ?? 0,
    totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    confirmedRevenue: (json['confirmedRevenue'] ?? 0).toDouble(),
    occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
  );
}

/// Tour booking data
class TourBookingData {
  final String id;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final int numberOfGuests;
  final String status;
  final bool isCheckedIn;
  final String? checkInTime;
  final String? qrCodeData;

  TourBookingData({
    required this.id,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.numberOfGuests,
    required this.status,
    required this.isCheckedIn,
    this.checkInTime,
    this.qrCodeData,
  });

  factory TourBookingData.fromJson(Map<String, dynamic> json) => TourBookingData(
    id: json['id'] ?? '',
    contactName: json['contactName'] ?? '',
    contactPhone: json['contactPhone'] ?? '',
    contactEmail: json['contactEmail'] ?? '',
    numberOfGuests: json['numberOfGuests'] ?? 0,
    status: json['status'] ?? '',
    isCheckedIn: json['isCheckedIn'] ?? false,
    checkInTime: json['checkInTime'],
    qrCodeData: json['qrCodeData'],
  );
}

/// Timeline response
class TimelineResponse {
  final int statusCode;
  final String message;
  final bool success;
  final TimelineData data;

  TimelineResponse({
    required this.statusCode,
    required this.message,
    required this.success,
    required this.data,
  });

  factory TimelineResponse.fromJson(Map<String, dynamic> json) => TimelineResponse(
    statusCode: json['statusCode'] ?? 200,
    message: json['message'] ?? '',
    success: json['success'] ?? false,
    data: TimelineData.fromJson(json['data'] ?? {}),
  );
}

/// Timeline data
class TimelineData {
  final String tourTemplateId;
  final String tourTemplateTitle;
  final List<TimelineItemData> items;
  final int totalItems;
  final String startLocation;
  final String endLocation;
  final String createdAt;
  final String? updatedAt;

  TimelineData({
    required this.tourTemplateId,
    required this.tourTemplateTitle,
    required this.items,
    required this.totalItems,
    required this.startLocation,
    required this.endLocation,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimelineData.fromJson(Map<String, dynamic> json) => TimelineData(
    tourTemplateId: json['tourTemplateId'] ?? '',
    tourTemplateTitle: json['tourTemplateTitle'] ?? '',
    items: (json['items'] as List?)?.map((e) => TimelineItemData.fromJson(e)).toList() ?? [],
    totalItems: json['totalItems'] ?? 0,
    startLocation: json['startLocation'] ?? '',
    endLocation: json['endLocation'] ?? '',
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'],
  );
}

/// Timeline item data
class TimelineItemData {
  final String id;
  final String tourDetailsId;
  final String checkInTime;
  final String activity;
  final String? specialtyShopId;
  final int sortOrder;
  final SpecialtyShopData? specialtyShop;
  final String createdAt;
  final String? updatedAt;

  TimelineItemData({
    required this.id,
    required this.tourDetailsId,
    required this.checkInTime,
    required this.activity,
    this.specialtyShopId,
    required this.sortOrder,
    this.specialtyShop,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimelineItemData.fromJson(Map<String, dynamic> json) => TimelineItemData(
    id: json['id'] ?? '',
    tourDetailsId: json['tourDetailsId'] ?? '',
    checkInTime: json['checkInTime'] ?? '',
    activity: json['activity'] ?? '',
    specialtyShopId: json['specialtyShopId'],
    sortOrder: json['sortOrder'] ?? 0,
    specialtyShop: json['specialtyShop'] != null ? SpecialtyShopData.fromJson(json['specialtyShop']) : null,
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'],
  );

  // For compatibility with existing code
  bool get isCompleted => false; // Timeline items don't have completion status in this API
  String? get completedAt => null;
  String? get completionNotes => null;
  String? get location => specialtyShop?.location;
}

/// Specialty shop data
class SpecialtyShopData {
  final String id;
  final String shopName;
  final String shopType;
  final String location;
  final String? description;
  final bool isShopActive;

  SpecialtyShopData({
    required this.id,
    required this.shopName,
    required this.shopType,
    required this.location,
    this.description,
    required this.isShopActive,
  });

  factory SpecialtyShopData.fromJson(Map<String, dynamic> json) => SpecialtyShopData(
    id: json['id'] ?? '',
    shopName: json['shopName'] ?? '',
    shopType: json['shopType'] ?? '',
    location: json['location'] ?? '',
    description: json['description'],
    isShopActive: json['isShopActive'] ?? false,
  );
}

/// API Response wrapper
class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T data;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) => ApiResponse(
    statusCode: json['statusCode'] ?? 200,
    message: json['message'] ?? '',
    data: fromJsonT(json['data']),
    success: json['success'] ?? false,
  );
}



/// Request models
class CheckInGuestRequest {
  final String? qrCodeData;
  final String? notes;

  CheckInGuestRequest({this.qrCodeData, this.notes});

  Map<String, dynamic> toJson() => {
    'qrCodeData': qrCodeData,
    'notes': notes,
  };
}

class CheckInGuestWithOverrideRequest {
  final String? qrCodeData;
  final String? notes;
  final bool overrideTimeRestriction;
  final String? overrideReason;

  CheckInGuestWithOverrideRequest({
    this.qrCodeData,
    this.notes,
    this.overrideTimeRestriction = false,
    this.overrideReason,
  });

  Map<String, dynamic> toJson() => {
    'qrCodeData': qrCodeData,
    'notes': notes,
    'overrideTimeRestriction': overrideTimeRestriction,
    'overrideReason': overrideReason,
  };
}

/// ✅ NEW: Check-in group request
class CheckInGroupRequest {
  final String qrCodeData;
  final String? checkInNotes;
  final String? location;

  CheckInGroupRequest({
    required this.qrCodeData,
    this.checkInNotes,
    this.location,
  });

  Map<String, dynamic> toJson() => {
    'QrCodeData': qrCodeData,  // ✅ FIX: Backend expects QrCodeData with capital Q
    'CheckInNotes': checkInNotes,
    'Location': location,
  };
}

/// ✅ NEW: Check-in group response
class CheckInGroupResponse {
  final bool success;
  final String message;
  final String bookingId;
  final String bookingCode;
  final String? groupName;
  final int totalGuests;
  final int checkedInCount;
  final int previouslyCheckedInCount;
  final DateTime checkInTime;
  final List<CheckedInGuestInfo> checkedInGuests;
  final bool isCompleteCheckIn;

  CheckInGroupResponse({
    required this.success,
    required this.message,
    required this.bookingId,
    required this.bookingCode,
    this.groupName,
    required this.totalGuests,
    required this.checkedInCount,
    required this.previouslyCheckedInCount,
    required this.checkInTime,
    required this.checkedInGuests,
    required this.isCompleteCheckIn,
  });

  factory CheckInGroupResponse.fromJson(Map<String, dynamic> json) => CheckInGroupResponse(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    bookingId: json['bookingId'] ?? '',
    bookingCode: json['bookingCode'] ?? '',
    groupName: json['groupName'],
    totalGuests: json['totalGuests'] ?? 0,
    checkedInCount: json['checkedInCount'] ?? 0,
    previouslyCheckedInCount: json['previouslyCheckedInCount'] ?? 0,
    checkInTime: DateTime.parse(json['checkInTime'] ?? DateTime.now().toIso8601String()),
    checkedInGuests: (json['checkedInGuests'] as List<dynamic>?)
        ?.map((e) => CheckedInGuestInfo.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    isCompleteCheckIn: json['isCompleteCheckIn'] ?? false,
  );
}

/// ✅ NEW: Checked-in guest info for group check-in
class CheckedInGuestInfo {
  final String guestId;
  final String guestName;
  final String? guestEmail;
  final bool isGroupRepresentative;
  final DateTime checkInTime;

  CheckedInGuestInfo({
    required this.guestId,
    required this.guestName,
    this.guestEmail,
    required this.isGroupRepresentative,
    required this.checkInTime,
  });

  factory CheckedInGuestInfo.fromJson(Map<String, dynamic> json) => CheckedInGuestInfo(
    guestId: json['guestId'] ?? '',
    guestName: json['guestName'] ?? '',
    guestEmail: json['guestEmail'],
    isGroupRepresentative: json['isGroupRepresentative'] ?? false,
    checkInTime: DateTime.parse(json['checkInTime'] ?? DateTime.now().toIso8601String()),
  );
}

/// ✅ EXTENSION: Add wrapper method for proper response parsing
extension TourGuideApiServiceExtension on TourGuideApiService {
  /// Check-in guest by QR code with proper response parsing
  Future<IndividualGuestCheckInResponse> checkInGuestByQR(
    CheckInGuestByQRRequest request,
  ) async {
    try {
      final responseData = await checkInGuestByQRRaw(request);

      // Parse backend response format
      if (responseData is Map<String, dynamic>) {
        // Backend returns: { "data": {...}, "isSuccess": true, "message": "...", "success": true }
        final success = responseData['success'] == true || responseData['isSuccess'] == true;
        final message = responseData['message'] ?? '';
        final data = responseData['data'] as Map<String, dynamic>?;

        if (success && data != null) {
          // Convert backend data to mobile format
          final guestInfo = TourBookingGuestModel(
            id: data['id'] ?? '',
            guestName: data['guestName'] ?? '',
            guestEmail: data['guestEmail'] ?? '',
            guestPhone: null,
            isCheckedIn: data['isCheckedIn'] == true,
            checkInTime: data['checkInTime'],
            checkInNotes: data['checkInNotes'],
            tourBookingId: data['tourBookingId'],
            bookingCode: data['bookingCode'],
            bookingId: data['bookingId'],
            customerName: data['customerName'],
            totalGuests: data['totalGuests'],
          );

          return IndividualGuestCheckInResponse(
            success: true,
            message: message,
            guestInfo: guestInfo,
            checkInTime: data['checkInTime'],
          );
        } else {
          return IndividualGuestCheckInResponse(
            success: false,
            message: message.isNotEmpty ? message : 'Check-in thất bại',
          );
        }
      }

      // Fallback for unexpected response format
      return IndividualGuestCheckInResponse(
        success: false,
        message: 'Định dạng response không hợp lệ',
      );
    } catch (e) {
      return IndividualGuestCheckInResponse(
        success: false,
        message: 'Lỗi kết nối: $e',
      );
    }
  }
}
