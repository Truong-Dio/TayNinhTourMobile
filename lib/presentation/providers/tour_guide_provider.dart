import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

import '../../core/errors/exceptions.dart';
import '../../data/datasources/tour_guide_api_service.dart';
import '../../data/models/tour_booking_model.dart';
import '../../data/models/timeline_item_model.dart';
import '../../data/models/timeline_progress_models.dart';
import '../../data/models/tour_slot_model.dart';
import '../../data/models/tour_guide_slot_models.dart';
import '../../data/models/individual_qr_models.dart';
import '../../data/models/group_booking_model.dart';
import '../../data/services/qr_parsing_service.dart';
import '../../domain/entities/active_tour.dart';
import '../../domain/entities/tour_booking.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/entities/tour_invitation.dart';

class TourGuideProvider extends ChangeNotifier {
  final TourGuideApiService _tourGuideApiService;
  final Logger _logger;
  
  TourGuideProvider({
    required TourGuideApiService tourGuideApiService,
    required Logger logger,
  }) : _tourGuideApiService = tourGuideApiService,
       _logger = logger;
  
  // State
  bool _isLoading = false;
  List<ActiveTour> _activeTours = [];
  List<TourBooking> _tourBookings = [];
  List<TimelineItem> _timelineItems = [];
  TimelineProgressResponse? _timelineProgressResponse; // NEW: Store timeline with progress
  List<TourInvitation> _tourInvitations = [];
  InvitationStatistics? _invitationStatistics;
  String? _errorMessage;
  String? _currentTourDetailsId;
  String? _currentTourSlotId;

  // NEW: TourSlot-based state
  List<TourGuideSlotModel> _tourSlots = [];
  TourSlotBookingsResponse? _currentSlotBookings;
  
  // ✅ NEW: Individual guest state
  List<TourBookingGuestModel> _currentSlotGuests = [];
  String? _currentUserId;
  
  // Getters
  bool get isLoading => _isLoading;
  List<ActiveTour> get activeTours => _activeTours;
  List<TourBooking> get tourBookings => _tourBookings;
  List<TimelineItem> get timelineItems => _timelineItems;
  TimelineProgressResponse? get timelineProgressResponse => _timelineProgressResponse; // NEW: Getter for timeline progress
  List<TourInvitation> get tourInvitations => _tourInvitations;
  InvitationStatistics? get invitationStatistics => _invitationStatistics;
  String? get errorMessage => _errorMessage;

  // NEW: TourSlot-based getters
  List<TourGuideSlotModel> get tourSlots => _tourSlots;
  TourSlotBookingsResponse? get currentSlotBookings => _currentSlotBookings;
  List<TourBookingModel> get currentSlotBookingsList => _currentSlotBookings?.bookings ?? [];
  
  // ✅ NEW: Individual guest getters
  List<TourBookingGuestModel> get currentSlotGuests => _currentSlotGuests;
  
  /// Get active tours for current tour guide
  Future<void> getMyActiveTours() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getMyActiveTours();
      _activeTours = response.map((model) => model.toEntity()).toList();
      _logger.i('Loaded ${_activeTours.length} active tours');

      // TODO: Load upcoming tour slots when tour guide is assigned
      // await _loadUpcomingTourSlots();
    } catch (e) {
      _logger.e('Error loading active tours: $e');
      _setError('Có lỗi xảy ra khi tải danh sách tours');
    } finally {
      _setLoading(false);
    }
  }

  /// Load upcoming tour slots for all active tours
  Future<void> _loadUpcomingTourSlots() async {
    try {
      // TODO: Implement when we have proper tour guide assignment
      // For now, just log that we would load tour slots

      _logger.i('Would load upcoming tour slots here');
    } catch (e) {
      _logger.e('Error loading upcoming tour slots: $e');
    }
  }


  
  /// Get tour bookings for a specific tour operation
  Future<List<TourBookingModel>> getTourBookings(String operationId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourBookings(operationId);
      _logger.i('Loaded ${response.length} tour bookings');
      return response;
    } catch (e) {
      _logger.e('Error loading tour bookings: $e');
      _setError('Có lỗi xảy ra khi tải danh sách khách hàng');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// [NEW] Get tour slots for current tour guide
  Future<void> getMyTourSlots({DateTime? fromDate}) async {
    try {
      _setLoading(true);
      _clearError();

      final fromDateStr = fromDate?.toIso8601String();
      final response = await _tourGuideApiService.getMyTourSlots(fromDateStr);
      _tourSlots = response;
      _logger.i('Loaded ${_tourSlots.length} tour slots');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading tour slots: $e');
      _setError('Có lỗi xảy ra khi tải danh sách tour slots');
    } finally {
      _setLoading(false);
    }
  }

  /// [NEW] Get tour bookings for a specific tour slot
  Future<void> getTourSlotBookings(String tourSlotId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourSlotBookings(tourSlotId);
      _currentSlotBookings = response;
      _currentTourSlotId = tourSlotId;
      _logger.i('Loaded ${response.bookings.length} bookings for tour slot');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading tour slot bookings: $e');
      _setError('Có lỗi xảy ra khi tải danh sách khách hàng theo slot');
    } finally {
      _setLoading(false);
    }
  }

  /// [NEW] Find booking by QR code in current slot
  TourBookingModel? findBookingByQRCode(String qrCodeData) {
    if (_currentSlotBookings == null) return null;

    try {
      return _currentSlotBookings!.bookings.firstWhere(
        (booking) => booking.qrCodeData == qrCodeData,
      );
    } catch (e) {
      _logger.w('Booking not found for QR code: $qrCodeData');
      return null;
    }
  }

  /// [NEW] Check if booking belongs to current slot
  bool isBookingInCurrentSlot(String bookingId) {
    if (_currentSlotBookings == null) return false;

    return _currentSlotBookings!.bookings.any(
      (booking) => booking.id == bookingId,
    );
  }

  /// Get tour timeline for a specific tour operation
  Future<List<TimelineItemModel>> getTourTimeline(String operationId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourTimeline(operationId);
      _timelineItems = response.map((model) => model.toEntity()).toList();
      _currentTourDetailsId = operationId; // Store current tour details ID
      _logger.i('Loaded ${response.length} timeline items');
      notifyListeners();
      return response;
    } catch (e) {
      _logger.e('Error loading tour timeline: $e');
      _setError('Có lỗi xảy ra khi tải lịch trình tour');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check-in a guest
  Future<bool> checkInGuest(String bookingId, {String? qrCodeData, String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = CheckInGuestRequest(qrCodeData: qrCodeData, notes: notes);
      await _tourGuideApiService.checkInGuest(bookingId, request);
      return true;
    } catch (e) {
      _logger.e('Error checking in guest: $e');

      // Extract message from custom exceptions
      final errorMessage = _extractErrorMessage(e, 'Có lỗi xảy ra khi check-in khách hàng');
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check-in a guest with override time restriction
  Future<bool> checkInGuestWithOverride(
    String bookingId, {
    String? qrCodeData,
    String? notes,
    bool overrideTimeRestriction = false,
    String? overrideReason,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final request = CheckInGuestWithOverrideRequest(
        qrCodeData: qrCodeData,
        notes: notes,
        overrideTimeRestriction: overrideTimeRestriction,
        overrideReason: overrideReason,
      );
      await _tourGuideApiService.checkInGuestWithOverride(bookingId, request);
      return true;
    } catch (e) {
      _logger.e('Error checking in guest with override: $e');

      // Extract message from custom exceptions
      final errorMessage = _extractErrorMessage(e, 'Có lỗi xảy ra khi check-in sớm khách hàng');
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ NEW: Parse and handle QR code (supports both individual and legacy)
  Future<QRValidationResult> parseQRCode(String qrCodeData) async {
    try {
      // Parse QR using service
      final result = QRParsingService.parseAndValidateQR(qrCodeData);
      
      if (!result.isValid) {
        _logger.w('❌ Invalid QR: ${result.errorMessage}');
        _setError(result.errorMessage ?? 'QR code không hợp lệ');
      } else {
        _logger.i('✅ Valid QR: ${result.qrType}');
      }
      
      return result;
    } catch (e) {
      _logger.e('QR parsing error: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'error',
        errorMessage: 'Lỗi xử lý QR code: $e',
      );
    }
  }

  /// ✅ NEW: Check-in individual guest by QR code
  Future<IndividualGuestCheckInResponse?> checkInIndividualGuest({
    required String guestId,
    required String tourSlotId,
    String? notes,
    String? qrCodeData,
    bool overrideTime = false,
    String overrideReason = '',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Get current user ID (you may need to implement this)
      final tourguideId = _currentUserId ?? 'current-tourguide-id'; // TODO: Get from auth
      
      final request = IndividualGuestCheckInRequest(
        guestId: guestId,
        tourSlotId: tourSlotId,
        tourguideId: tourguideId,
        checkInTime: DateTime.now().toIso8601String(),
        notes: notes,
        qrCodeData: qrCodeData,
      );

      final response = await _tourGuideApiService.checkInIndividualGuest(request);
      
      if (response.success) {
        _logger.i('✅ Individual guest check-in successful: ${response.guestInfo?.guestName}');
        
        // Update local state
        _updateGuestStatusInList(guestId, true);
        
        return response;
      } else {
        _setError(response.message);
        return response;
      }
    } catch (e) {
      _logger.e('❌ Individual guest check-in error: $e');
      final errorMessage = _extractErrorMessage(e, 'Có lỗi xảy ra khi check-in khách hàng');
      _setError(errorMessage);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ NEW: Get guest status by guest ID
  Future<TourBookingGuestModel?> getGuestStatus(String guestId) async {
    try {
      final guestStatus = await _tourGuideApiService.getGuestStatus(guestId);
      _logger.i('Got guest status: ${guestStatus.guestName}');
      return guestStatus;
    } catch (e) {
      _logger.e('Error getting guest status: $e');
      _setError('Không thể lấy thông tin khách hàng');
      return null;
    }
  }

  /// ✅ NEW: Get all guests for current tour slot
  Future<void> getTourSlotGuests(String tourSlotId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourSlotGuests(tourSlotId);
      _currentSlotGuests = response.guests;
      _currentTourSlotId = tourSlotId;
      
      _logger.i('Loaded ${response.guests.length} guests for tour slot (Total: ${response.totalGuests}, Checked-in: ${response.checkedInGuests})');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading tour slot guests: $e');
      _setError('Không thể tải danh sách khách hàng');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ NEW: Validate tourguide permission
  Future<bool> validateTourguidePermission(String tourSlotId) async {
    try {
      final hasPermission = await _tourGuideApiService.validateTourguidePermission(tourSlotId);
      _logger.i('Tourguide permission for slot $tourSlotId: $hasPermission');
      return hasPermission;
    } catch (e) {
      _logger.e('Error validating permission: $e');
      return false;
    }
  }

  /// ✅ NEW: Find guest by QR data in current slot
  TourBookingGuestModel? findGuestByQRData(IndividualGuestQR qrData) {
    try {
      return _currentSlotGuests.firstWhere(
        (guest) => guest.id == qrData.guestId,
      );
    } catch (e) {
      _logger.w('Guest not found for QR: ${qrData.guestId}');
      return null;
    }
  }

  /// ✅ NEW: Find booking by booking ID in current slot
  TourBookingModel? findBookingById(String bookingId) {
    if (_currentSlotBookings == null) return null;

    try {
      return _currentSlotBookings!.bookings.firstWhere(
        (booking) => booking.id == bookingId,
      );
    } catch (e) {
      _logger.w('Booking not found for ID: $bookingId');
      return null;
    }
  }

  /// ✅ NEW: Check-in group by QR code
  Future<bool> checkInGroupByQR({
    required String qrCodeData,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Parse QR data to get booking ID
      final qrJson = jsonDecode(qrCodeData);
      final bookingId = qrJson['bookingId'] as String;

      // Call API to check-in group
      final request = CheckInGroupRequest(
        qrCodeData: qrCodeData,
        checkInNotes: notes,
      );

      final response = await _tourGuideApiService.checkInGroupByQR(request);
      
      if (response != null && response.success) {
        _logger.i('✅ Group check-in successful: ${response.checkedInCount} guests checked in');
        
        // Reload bookings to update UI
        if (_currentTourSlotId != null) {
          await getTourSlotBookings(_currentTourSlotId!);
        }
        
        return true;
      } else {
        _setError(response?.message ?? 'Check-in nhóm thất bại');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Group check-in error: $e');
      final errorMessage = _extractErrorMessage(e, 'Có lỗi xảy ra khi check-in nhóm');
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ NEW: Check-in group with time override
  Future<bool> checkInGroupWithOverride({
    required String qrCodeData,
    String? notes,
    required bool overrideTimeRestriction,
    required String overrideReason,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Parse QR data to get booking ID
      final qrJson = jsonDecode(qrCodeData);
      final bookingId = qrJson['bookingId'] as String;

      // Prepare notes with override reason
      final checkInNotes = notes ?? '';
      final fullNotes = overrideTimeRestriction 
        ? '$checkInNotes\n[OVERRIDE] Lý do: $overrideReason'
        : checkInNotes;

      // Call API to check-in group with override
      final request = CheckInGroupRequest(
        qrCodeData: qrCodeData,
        checkInNotes: fullNotes,
      );

      final response = await _tourGuideApiService.checkInGroupByQR(request);
      
      if (response != null && response.success) {
        _logger.i('✅ Group check-in with override successful: ${response.checkedInCount} guests checked in');
        
        // Reload bookings to update UI
        if (_currentTourSlotId != null) {
          await getTourSlotBookings(_currentTourSlotId!);
        }
        
        return true;
      } else {
        _setError(response?.message ?? 'Check-in nhóm thất bại');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Group check-in with override error: $e');
      final errorMessage = _extractErrorMessage(e, 'Có lỗi xảy ra khi check-in nhóm');
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ NEW: Update guest status in local list
  void _updateGuestStatusInList(String guestId, bool isCheckedIn) {
    final guestIndex = _currentSlotGuests.indexWhere((g) => g.id == guestId);
    if (guestIndex >= 0) {
      final updatedGuest = TourBookingGuestModel(
        id: _currentSlotGuests[guestIndex].id,
        guestName: _currentSlotGuests[guestIndex].guestName,
        guestEmail: _currentSlotGuests[guestIndex].guestEmail,
        guestPhone: _currentSlotGuests[guestIndex].guestPhone,
        qrCodeData: _currentSlotGuests[guestIndex].qrCodeData,
        isCheckedIn: isCheckedIn,
        checkInTime: isCheckedIn ? DateTime.now().toIso8601String() : null,
        checkInNotes: _currentSlotGuests[guestIndex].checkInNotes,
        tourBookingId: _currentSlotGuests[guestIndex].tourBookingId,
      );
      
      _currentSlotGuests[guestIndex] = updatedGuest;
      notifyListeners();
    }
  }

  /// ✅ NEW: Set current user ID (call this during login)
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }
  
  /// Complete a timeline item
  Future<bool> completeTimelineItem(String timelineId, {String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = CompleteTimelineRequest(notes: notes);
      await _tourGuideApiService.completeTimelineItem(timelineId, request);

      // Reload timeline to update UI with completion status
      if (_currentTourDetailsId != null) {
        await getTourTimeline(_currentTourDetailsId!);
      }

      return true;
    } catch (e) {
      _logger.e('Error completing timeline item: $e');
      final errorMessage = _extractErrorMessage(e, 'Có lỗi xảy ra khi hoàn thành mục lịch trình');
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Report an incident
  Future<bool> reportIncident({
    required String tourOperationId,
    required String title,
    required String description,
    required String severity,
    List<String>? imageUrls,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final request = ReportIncidentRequest(
        tourOperationId: tourOperationId,
        title: title,
        description: description,
        severity: severity,
        imageUrls: imageUrls,
      );

      await _tourGuideApiService.reportIncident(request);
      return true;
    } catch (e) {
      _logger.e('Error reporting incident: $e');
      _setError('Có lỗi xảy ra khi báo cáo sự cố');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Notify guests
  Future<bool> notifyGuests(String operationId, String message, {bool isUrgent = false}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = NotifyGuestsRequest(message: message, isUrgent: isUrgent);
      await _tourGuideApiService.notifyGuests(operationId, request);
      return true;
    } catch (e) {
      _logger.e('Error notifying guests: $e');
      _setError('Có lỗi xảy ra khi gửi thông báo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete tour
  Future<bool> completeTour(String operationId) async {
    try {
      _setLoading(true);
      _clearError();

      await _tourGuideApiService.completeTour(operationId);

      // Refresh active tours list
      await getMyActiveTours();

      return true;
    } catch (e) {
      _logger.e('Error completing tour: $e');
      _setError('Có lỗi xảy ra khi hoàn thành tour');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload incident images
  Future<List<String>?> uploadIncidentImages(List<File> imageFiles) async {
    try {
      _setLoading(true);
      _clearError();

      // Convert File to MultipartFile
      final multipartFiles = <MultipartFile>[];
      for (final file in imageFiles) {
        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
        multipartFiles.add(multipartFile);
      }

      final response = await _tourGuideApiService.uploadIncidentImages(multipartFiles);
      return response;
    } catch (e) {
      _logger.e('Error uploading images: $e');
      _setError('Có lỗi xảy ra khi upload ảnh');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get tour slots for a tour details
  Future<List<TourSlotData>> getTourSlots(String tourDetailsId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourSlots(tourDetailsId);

      _logger.i('Tour slots loaded successfully: ${response.data.length} slots');

      // Convert TourSlotDto to TourSlotData
      return response.data.map((dto) => TourSlotData.fromDto(dto)).toList();
    } catch (e) {
      _logger.e('Error getting tour slots: $e');
      _setError('Có lỗi xảy ra khi lấy danh sách lịch trình');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get tour slot details
  Future<TourSlotDetailsResponse?> getTourSlotDetails(String tourSlotId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourSlotDetails(tourSlotId);

      _logger.i('Tour slot details loaded successfully');
      return response;
    } catch (e) {
      _logger.e('Error getting tour slot details: $e');
      _setError('Có lỗi xảy ra khi lấy chi tiết lịch trình');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get timeline for tour details (OLD - shared timeline)
  Future<List<TimelineItemData>> getTimeline(String tourDetailsId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTimeline(tourDetailsId, true);

      _logger.i('Timeline loaded successfully: ${response.data.items.length} items');
      return response.data.items;
    } catch (e) {
      _logger.e('Error getting timeline: $e');
      _setError('Có lỗi xảy ra khi lấy lịch trình chi tiết');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// [NEW] Get timeline with progress for specific tour slot (independent per slot)
  Future<TimelineProgressResponse> getTourSlotTimelineWithProgress(String tourSlotId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourSlotTimeline(
        tourSlotId,
        false, // includeInactive
        true,  // includeShopInfo
      );

      // Store the timeline progress response
      _timelineProgressResponse = response;
      _currentTourSlotId = tourSlotId; // Store current tour slot ID

      // Convert timeline with progress to TimelineItem entities for backward compatibility
      _timelineItems = response.timeline.map((item) => TimelineItem(
        id: item.id,
        checkInTime: item.checkInTime,
        activity: item.activity,
        sortOrder: item.sortOrder,
        isCompleted: item.isCompleted,
        completedAt: item.completedAt,
        completionNotes: item.completionNotes,
        specialtyShop: item.specialtyShop != null ? SpecialtyShop(
          id: item.specialtyShop!.id,
          shopName: item.specialtyShop!.shopName,
          address: item.specialtyShop!.address ?? '',
          description: item.specialtyShop!.description,
        ) : null,
      )).toList();

      _logger.i('Tour slot timeline loaded successfully: ${response.timeline.length} items');
      notifyListeners();
      return response;
    } catch (e) {
      _logger.e('Error getting tour slot timeline: $e');
      _setError('Có lỗi xảy ra khi lấy lịch trình tour slot');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// [NEW] Complete timeline item for specific tour slot
  Future<bool> completeTimelineItemForSlot(String tourSlotId, String timelineItemId, {String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = CompleteTimelineRequest(notes: notes);
      final response = await _tourGuideApiService.completeTimelineItemForSlot(
        tourSlotId,
        timelineItemId,
        request
      );

      // Reload timeline to update UI with completion status
      await getTourSlotTimelineWithProgress(tourSlotId);

      _logger.i('Timeline item completed successfully: ${response.message}');
      return response.success;
    } catch (e) {
      _logger.e('Error completing timeline item for slot: $e');
      _setError('Có lỗi xảy ra khi hoàn thành mục lịch trình');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Extract error message from exceptions
  String _extractErrorMessage(dynamic error, String defaultMessage) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is ServerException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else if (error is AppException) {
      return error.message;
    }
    return defaultMessage;
  }
  
  // Clear data when switching tours
  void clearTourData() {
    _tourBookings.clear();
    _timelineItems.clear();
    _timelineProgressResponse = null; // NEW: Clear timeline progress
    notifyListeners();
  }

  /// Get my tour invitations
  Future<void> getMyInvitations({String? status}) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getMyInvitations(status);
      _tourInvitations = (response.invitations ?? []).map((model) => TourInvitation(
        id: model.id,
        status: model.status ?? 'pending',
        invitedAt: DateTime.parse(model.invitedAt),
        respondedAt: model.respondedAt != null ? DateTime.parse(model.respondedAt!) : null,
        canAccept: model.canAccept ?? false,
        canReject: model.canReject ?? false,
        tourTitle: model.tourDetails?.title,
        tourDescription: model.tourDetails?.description,
      )).toList();

      if (response.statistics != null) {
        _invitationStatistics = InvitationStatistics(
          totalInvitations: response.statistics!.totalInvitations,
          pendingCount: response.statistics!.pendingCount,
          acceptedCount: response.statistics!.acceptedCount,
          rejectedCount: response.statistics!.rejectedCount,
        );
      }
      _logger.i('Loaded ${_tourInvitations.length} tour invitations');
    } catch (e) {
      _logger.e('Error loading tour invitations: $e');
      _setError('Có lỗi xảy ra khi tải danh sách lời mời');
    } finally {
      _setLoading(false);
    }
  }

  /// Accept tour invitation
  Future<bool> acceptInvitation(String invitationId, {String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = {
        'notes': notes,
      };

      await _tourGuideApiService.acceptInvitation(invitationId);

      // Refresh invitations list
      await getMyInvitations();

      _logger.i('Accepted invitation: $invitationId');
      return true;
    } catch (e) {
      _logger.e('Error accepting invitation: $e');
      _setError('Có lỗi xảy ra khi chấp nhận lời mời');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reject tour invitation
  Future<bool> rejectInvitation(String invitationId, {String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = {
        'notes': notes,
      };

      await _tourGuideApiService.rejectInvitation(invitationId);

      // Refresh invitations list
      await getMyInvitations();

      _logger.i('Rejected invitation: $invitationId');
      return true;
    } catch (e) {
      _logger.e('Error rejecting invitation: $e');
      _setError('Có lỗi xảy ra khi từ chối lời mời');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
