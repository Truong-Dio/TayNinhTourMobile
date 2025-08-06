import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/datasources/tour_guide_api_service.dart';
import '../../domain/entities/active_tour.dart';
import '../../domain/entities/tour_booking.dart';
import '../../domain/entities/timeline_item.dart';
import '../../core/errors/failures.dart';

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
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  List<ActiveTour> get activeTours => _activeTours;
  List<TourBooking> get tourBookings => _tourBookings;
  List<TimelineItem> get timelineItems => _timelineItems;
  String? get errorMessage => _errorMessage;
  
  /// Get active tours for current tour guide
  Future<void> getMyActiveTours() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _tourGuideApiService.getMyActiveTours();
      
      if (response.success && response.data != null) {
        _activeTours = response.data!.map((model) => model.toEntity()).toList();
        _logger.i('Loaded ${_activeTours.length} active tours');
      } else {
        _setError(response.message ?? 'Không thể tải danh sách tours');
      }
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
      
      if (response.success && response.data != null) {
        _tourBookings = response.data!.map((model) => model.toEntity()).toList();
        _logger.i('Loaded ${_tourBookings.length} tour bookings');
      } else {
        _setError(response.message ?? 'Không thể tải danh sách khách hàng');
      }
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
      
      if (response.success && response.data != null) {
        _timelineItems = response.data!.map((model) => model.toEntity()).toList();
        // Sort by sort order
        _timelineItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _logger.i('Loaded ${_timelineItems.length} timeline items');
      } else {
        _setError(response.message ?? 'Không thể tải lịch trình tour');
      }
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
      final response = await _tourGuideApiService.checkInGuest(bookingId, request);

      if (response['success'] == true) {
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
      } else {
        _setError(response['message'] ?? 'Không thể check-in khách hàng');
        return false;
      }
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
      final response = await _tourGuideApiService.completeTimelineItem(timelineId, request);

      if (response['success'] == true) {
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
      } else {
        _setError(response['message'] ?? 'Không thể hoàn thành mục lịch trình');
        return false;
      }
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
      
      final response = await _tourGuideApiService.reportIncident(request);

      if (response['success'] == true) {
        _logger.i('Incident reported successfully');
        return true;
      } else {
        _setError(response['message'] ?? 'Không thể báo cáo sự cố');
        return false;
      }
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
      final response = await _tourGuideApiService.notifyGuests(operationId, request);

      if (response['success'] == true) {
        _logger.i('Guests notified successfully');
        return true;
      } else {
        _setError(response['message'] ?? 'Không thể gửi thông báo');
        return false;
      }
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
}
