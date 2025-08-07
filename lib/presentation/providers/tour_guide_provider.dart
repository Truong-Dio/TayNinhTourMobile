import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/datasources/tour_guide_api_service.dart';
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
  List<TourInvitation> _tourInvitations = [];
  InvitationStatistics? _invitationStatistics;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  List<ActiveTour> get activeTours => _activeTours;
  List<TourBooking> get tourBookings => _tourBookings;
  List<TimelineItem> get timelineItems => _timelineItems;
  List<TourInvitation> get tourInvitations => _tourInvitations;
  InvitationStatistics? get invitationStatistics => _invitationStatistics;
  String? get errorMessage => _errorMessage;
  
  /// Get active tours for current tour guide
  Future<void> getMyActiveTours() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getMyActiveTours();
      _activeTours = response.map((model) => model.toEntity()).toList();
      _logger.i('Loaded ${_activeTours.length} active tours');
    } catch (e) {
      _logger.e('Error loading active tours: $e');
      _setError('Có lỗi xảy ra khi tải danh sách tours');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get tour bookings for a specific tour operation
  Future<void> getTourBookings(String operationId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourBookings(operationId);
      _tourBookings = response.map((model) => model.toEntity()).toList();
      _logger.i('Loaded ${_tourBookings.length} tour bookings');
    } catch (e) {
      _logger.e('Error loading tour bookings: $e');
      _setError('Có lỗi xảy ra khi tải danh sách khách hàng');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get tour timeline for a specific tour details
  Future<void> getTourTimeline(String tourDetailsId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _tourGuideApiService.getTourTimeline(tourDetailsId);
      _timelineItems = response.map((model) => model.toEntity()).toList();
      // Sort by sort order
      _timelineItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _logger.i('Loaded ${_timelineItems.length} timeline items');
    } catch (e) {
      _logger.e('Error loading tour timeline: $e');
      _setError('Có lỗi xảy ra khi tải lịch trình tour');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check-in a guest
  Future<bool> checkInGuest(String bookingId, {String? qrCodeData, String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final request = CheckInRequest(qrCodeData: qrCodeData, notes: notes);
      await _tourGuideApiService.checkInGuest(bookingId, request);

      // If no exception thrown, consider it successful
        // Update local booking state
        final bookingIndex = _tourBookings.indexWhere((b) => b.id == bookingId);
        if (bookingIndex != -1) {
          final updatedBooking = TourBooking(
            id: _tourBookings[bookingIndex].id,
            bookingCode: _tourBookings[bookingIndex].bookingCode,
            contactName: _tourBookings[bookingIndex].contactName,
            contactPhone: _tourBookings[bookingIndex].contactPhone,
            contactEmail: _tourBookings[bookingIndex].contactEmail,
            numberOfGuests: _tourBookings[bookingIndex].numberOfGuests,
            adultCount: _tourBookings[bookingIndex].adultCount,
            childCount: _tourBookings[bookingIndex].childCount,
            totalPrice: _tourBookings[bookingIndex].totalPrice,
            isCheckedIn: true,
            checkInTime: DateTime.now(),
            checkInNotes: notes,
            qrCodeData: _tourBookings[bookingIndex].qrCodeData,
            customerName: _tourBookings[bookingIndex].customerName,
            status: _tourBookings[bookingIndex].status,
            bookingDate: _tourBookings[bookingIndex].bookingDate,
          );
          
          _tourBookings[bookingIndex] = updatedBooking;
          notifyListeners();
        }
        
        _logger.i('Guest checked in successfully: $bookingId');
        return true;
    } catch (e) {
      _logger.e('Error checking in guest: $e');
      _setError('Có lỗi xảy ra khi check-in khách hàng');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Complete a timeline item
  Future<bool> completeTimelineItem(String timelineId, {String? notes}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final request = CompleteTimelineRequest(notes: notes);
      await _tourGuideApiService.completeTimelineItem(timelineId, request);

      // If no exception thrown, consider it successful
        // Update local timeline state
        final itemIndex = _timelineItems.indexWhere((item) => item.id == timelineId);
        if (itemIndex != -1) {
          final updatedItem = TimelineItem(
            id: _timelineItems[itemIndex].id,
            checkInTime: _timelineItems[itemIndex].checkInTime,
            activity: _timelineItems[itemIndex].activity,
            sortOrder: _timelineItems[itemIndex].sortOrder,
            isCompleted: true,
            completedAt: DateTime.now(),
            completionNotes: notes,
            specialtyShop: _timelineItems[itemIndex].specialtyShop,
          );
          
          _timelineItems[itemIndex] = updatedItem;
          notifyListeners();
        }
        
        _logger.i('Timeline item completed successfully: $timelineId');
        return true;
    } catch (e) {
      _logger.e('Error completing timeline item: $e');
      _setError('Có lỗi xảy ra khi hoàn thành mục lịch trình');
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

      _logger.i('Incident reported successfully');
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

      _logger.i('Guests notified successfully');
      return true;
    } catch (e) {
      _logger.e('Error notifying guests: $e');
      _setError('Có lỗi xảy ra khi gửi thông báo');
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
  
  // Clear data when switching tours
  void clearTourData() {
    _tourBookings.clear();
    _timelineItems.clear();
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

      await _tourGuideApiService.acceptInvitation(invitationId, request);

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

      await _tourGuideApiService.rejectInvitation(invitationId, request);

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
