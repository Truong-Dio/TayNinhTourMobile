import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/datasources/user_api_service.dart';
import '../../data/models/user_tour_booking_model.dart';
import '../../data/models/tour_feedback_model.dart';
import '../../data/models/timeline_progress_models.dart';
import '../../domain/entities/user_tour_booking.dart';
import '../../domain/entities/tour_feedback.dart';
import '../../domain/entities/create_tour_feedback_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

class UserProvider extends ChangeNotifier {
  final UserApiService _userApiService;
  final Logger _logger;

  UserProvider({
    required UserApiService userApiService,
    required Logger logger,
  })  : _userApiService = userApiService,
        _logger = logger;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  List<UserTourBooking> _bookings = [];
  UserTourBooking? _selectedBooking;
  TourTimelineData? _tourTimeline;
  List<TourFeedback> _myFeedbacks = [];
  UserDashboardSummaryModel? _dashboardSummary;
  UserTourProgressModel? _tourProgress;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserTourBooking> get bookings => _bookings;
  UserTourBooking? get selectedBooking => _selectedBooking;
  TourTimelineData? get tourTimeline => _tourTimeline;
  List<TourFeedback> get myFeedbacks => _myFeedbacks;
  UserDashboardSummaryModel? get dashboardSummary => _dashboardSummary;
  UserTourProgressModel? get tourProgress => _tourProgress;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;

  // Filtered bookings by status
  List<UserTourBooking> get upcomingBookings =>
      _bookings.where((booking) => booking.isUpcoming).toList();

  List<UserTourBooking> get ongoingBookings =>
      _bookings.where((booking) => booking.isOngoing).toList();

  List<UserTourBooking> get completedBookings =>
      _bookings.where((booking) => booking.isCompleted).toList();

  List<UserTourBooking> get cancelledBookings =>
      _bookings.where((booking) => booking.isCancelled).toList();

  // Dashboard stats
  int get totalBookings => _bookings.length;
  int get upcomingCount => upcomingBookings.length;
  int get ongoingCount => ongoingBookings.length;
  int get completedCount => completedBookings.length;
  int get cancelledCount => cancelledBookings.length;
  int get pendingFeedbacksCount =>
      completedBookings.where((booking) => !_hasFeedback(booking.id)).length;

  /// Get my tour bookings
  Future<void> getMyBookings({
    int pageIndex = 1,
    int pageSize = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh || pageIndex == 1) {
        _setLoading(true);
        _bookings.clear();
      }

      _logger.i('Fetching user bookings - Page: $pageIndex, Size: $pageSize');

      final response = await _userApiService.getMyBookings(
        pageIndex: pageIndex,
        pageSize: pageSize,
      );

      if (response.success) {
        final newBookings = response.data.items
            .map((model) => model.toEntity())
            .toList();

        if (pageIndex == 1) {
          _bookings = newBookings;
        } else {
          _bookings.addAll(newBookings);
        }

        _currentPage = response.data.pageIndex;
        _totalPages = response.data.totalPages;
        _hasNextPage = response.data.hasNextPage;
        _hasPreviousPage = response.data.hasPreviousPage;

        _clearError();
        _logger.i('Successfully loaded ${newBookings.length} bookings');

        // Also load feedbacks if this is the first page or refresh
        if (pageIndex == 1 || refresh) {
          await getMyFeedbacks(refresh: true);
        }
      } else {
        _setError('Không thể tải danh sách tour: ${response.message}');
      }
    } catch (e) {
      _logger.e('Error fetching user bookings: $e');
      _setError('Lỗi khi tải danh sách tour: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get booking details
  Future<void> getBookingDetails(String bookingId) async {
    try {
      _setLoading(true);
      _logger.i('Fetching booking details for: $bookingId');

      final response = await _userApiService.getBookingDetails(bookingId);

      if (response.success) {
        _selectedBooking = response.data.toEntity();
        _clearError();
        _logger.i('Successfully loaded booking details');
      } else {
        _setError('Không thể tải chi tiết tour: ${response.message}');
      }
    } catch (e) {
      _logger.e('Error fetching booking details: $e');
      _setError('Lỗi khi tải chi tiết tour: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get tour timeline
  Future<void> getTourTimeline(String tourDetailsId) async {
    try {
      _setLoading(true);
      _logger.i('Fetching tour timeline for: $tourDetailsId');

      final response = await _userApiService.getTourTimeline(tourDetailsId);

      if (response.success) {
        _tourTimeline = response.data;
        _clearError();
        _logger.i('Successfully loaded tour timeline');
      } else {
        _setError('Không thể tải lịch trình tour: ${response.message}');
      }
    } catch (e) {
      _logger.e('Error fetching tour timeline: $e');
      _setError('Lỗi khi tải lịch trình tour: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if booking already has feedback
  bool hasBookingFeedback(String bookingId) {
    return _myFeedbacks.any((feedback) => feedback.bookingId == bookingId);
  }

  /// Get feedback for a specific booking
  TourFeedback? getBookingFeedback(String bookingId) {
    try {
      return _myFeedbacks.firstWhere((feedback) => feedback.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }



  /// Submit tour feedback
  Future<bool> submitTourFeedback(CreateTourFeedbackData feedbackData) async {
    try {
      _setLoading(true);
      _logger.i('Submitting tour feedback for booking: ${feedbackData.bookingId}');

      // Validate feedback data
      if (!feedbackData.isValid) {
        final errors = feedbackData.validationErrors;
        _setError('Dữ liệu không hợp lệ: ${errors.join(', ')}');
        return false;
      }

      final request = CreateTourFeedbackRequest(
        bookingId: feedbackData.bookingId,
        tourRating: feedbackData.tourRating,
        tourComment: feedbackData.tourComment,
        guideRating: feedbackData.guideRating,
        guideComment: feedbackData.guideComment,
      );

      final feedback = await _userApiService.submitTourFeedback(request);

      // Add to local feedback list
      _myFeedbacks.add(feedback.toEntity());

      _clearError();
      _logger.i('Successfully submitted tour feedback');
      return true;
    } catch (e) {
      _logger.e('Error submitting tour feedback: $e');
      _setError('Lỗi khi gửi đánh giá: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      _logger.i('Cancelling booking: $bookingId');

      await _userApiService.cancelBooking(bookingId);

      // Update local booking status
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(
          status: 'CancelledByCustomer',
          statusName: 'Đã hủy bởi khách hàng',
          cancelledDate: DateTime.now(),
        );
      }

      _clearError();
      _logger.i('Successfully cancelled booking');
      return true;
    } catch (e) {
      _logger.e('Error cancelling booking: $e');
      _setError('Lỗi khi hủy tour: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend QR ticket
  Future<bool> resendQRTicket(String bookingId) async {
    try {
      _setLoading(true);
      _logger.i('Resending QR ticket for booking: $bookingId');

      await _userApiService.resendQRTicket(bookingId);

      _clearError();
      _logger.i('Successfully resent QR ticket');
      return true;
    } catch (e) {
      _logger.e('Error resending QR ticket: $e');
      _setError('Lỗi khi gửi lại vé QR: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }



  /// Get dashboard summary - Generate from bookings data since API endpoint doesn't exist
  Future<void> getDashboardSummary() async {
    try {
      _setLoading(true);
      _logger.i('Generating dashboard summary from bookings data');

      // Generate dashboard summary from existing bookings data
      _generateDashboardSummaryFromBookings();
      _clearError();
      _logger.i('Successfully generated dashboard summary');
    } catch (e) {
      _setError('Error generating dashboard summary: $e');
      _logger.e('Error generating dashboard summary: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate dashboard summary from bookings data
  void _generateDashboardSummaryFromBookings() {
    if (_bookings.isEmpty) {
      // Create empty dashboard summary
      _dashboardSummary = UserDashboardSummaryModel(
        totalBookings: 0,
        upcomingTours: 0,
        ongoingTours: 0,
        completedTours: 0,
        cancelledTours: 0,
        pendingFeedbacks: 0,
        recentBookings: [],
        upcomingBookings: [],
      );
      return;
    }

    int totalBookings = _bookings.length;
    int upcomingTours = 0;
    int completedTours = 0;
    int cancelledTours = 0;
    int ongoingTours = 0;
    int pendingFeedbacks = 0;

    List<UserTourBookingModel> recentBookings = [];
    List<UserTourBookingModel> upcomingBookings = [];

    for (var booking in _bookings) {
      switch (booking.userTourStatus) {
        case AppConstants.tourStatusUpcoming:
          upcomingTours++;
          upcomingBookings.add(UserTourBookingModel.fromEntity(booking));
          break;
        case AppConstants.tourStatusCompleted:
          completedTours++;
          break;
        case AppConstants.tourStatusCancelled:
          cancelledTours++;
          break;
        case AppConstants.tourStatusOngoing:
          ongoingTours++;
          break;
        default:
          pendingFeedbacks++;
          break;
      }

      // Add to recent bookings (limit to 5 most recent)
      if (recentBookings.length < 5) {
        recentBookings.add(UserTourBookingModel.fromEntity(booking));
      }
    }

    _dashboardSummary = UserDashboardSummaryModel(
      totalBookings: totalBookings,
      upcomingTours: upcomingTours,
      ongoingTours: ongoingTours,
      completedTours: completedTours,
      cancelledTours: cancelledTours,
      pendingFeedbacks: pendingFeedbacks,
      recentBookings: recentBookings,
      upcomingBookings: upcomingBookings,
    );
  }

  /// Get tour progress
  TimelineProgressResponse? _timelineProgressResponse;
  TimelineProgressResponse? get timelineProgressResponse => _timelineProgressResponse;

  Future<void> getTourSlotTimeline(String tourSlotId) async {
    try {
      _setLoading(true);
      _clearError();
      _logger.i('Fetching tour timeline for slot: $tourSlotId');

      final rawResponse = await _userApiService.getUserTourSlotTimelineRaw(tourSlotId);

      // Parse the API response wrapper
      if (rawResponse['statusCode'] != 200) {
        throw Exception(rawResponse['message'] ?? 'Unknown error');
      }

      final data = rawResponse['data'];
      if (data == null) {
        throw Exception('No data returned from API');
      }

      // Extract timeline array from the response
      final timelineData = data['timeline'] as List<dynamic>?;
      if (timelineData == null || timelineData.isEmpty) {
        // Create empty response if no timeline data
        _timelineProgressResponse = TimelineProgressResponse(
          timeline: [],
          summary: TimelineProgressSummaryDto(
            tourSlotId: tourSlotId,
            totalItems: 0,
            completedItems: 0,
          ),
          tourSlot: TourSlotInfoDto(
            id: tourSlotId,
            tourDate: DateTime.now().toIso8601String().split('T')[0],
            currentBookings: 0,
            maxGuests: 0,
            status: 'Unknown',
          ),
          tourDetails: TourDetailsInfoDto(
            id: '',
            title: 'Unknown Tour',
            description: '',
            status: 'Unknown',
            imageUrls: [],
          ),
          canModifyProgress: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        // Convert timeline items
        final timelineItems = timelineData.map((item) =>
          TimelineWithProgressDto.fromJson(item as Map<String, dynamic>)
        ).toList();

        // Create response with available data
        _timelineProgressResponse = TimelineProgressResponse(
          timeline: timelineItems,
          summary: TimelineProgressSummaryDto(
            tourSlotId: tourSlotId,
            totalItems: timelineItems.length,
            completedItems: timelineItems.where((item) => item.isCompleted).length,
          ),
          tourSlot: TourSlotInfoDto(
            id: tourSlotId,
            tourDate: DateTime.now().toIso8601String().split('T')[0],
            currentBookings: 0,
            maxGuests: 0,
            status: 'Active',
          ),
          tourDetails: TourDetailsInfoDto(
            id: '',
            title: 'Tour Details',
            description: '',
            status: 'Active',
            imageUrls: [],
          ),
          canModifyProgress: true,
          lastUpdated: DateTime.now(),
        );
      }

      _logger.i('Successfully fetched and parsed tour timeline');

    } catch (e) {
      _errorMessage = 'Lỗi khi tải tiến độ tour: $e';
      _logger.e('Error fetching tour timeline: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get my feedbacks
  Future<void> getMyFeedbacks({
    int pageIndex = 1,
    int pageSize = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh || pageIndex == 1) {
        _setLoading(true);
        _myFeedbacks.clear();
      }

      _logger.i('Fetching my feedbacks - Page: $pageIndex, Size: $pageSize');

      final response = await _userApiService.getMyFeedbacks(
        pageIndex: pageIndex,
        pageSize: pageSize,
      );

      final feedbackResponse = response.toTourFeedbackResponse();
      final newFeedbacks = feedbackResponse.feedbacks
          .map((model) => model.toEntity())
          .toList();

      if (pageIndex == 1) {
        _myFeedbacks = newFeedbacks;
      } else {
        _myFeedbacks.addAll(newFeedbacks);
      }

      _clearError();
      _logger.i('Successfully loaded ${newFeedbacks.length} feedbacks');
    } catch (e) {
      _logger.e('Error fetching my feedbacks: $e');
      _setError('Lỗi khi tải danh sách đánh giá: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update feedback
  Future<bool> updateFeedback(String feedbackId, UpdateTourFeedbackRequest request) async {
    try {
      _setLoading(true);
      _logger.i('Updating feedback: $feedbackId');

      await _userApiService.updateFeedback(feedbackId, request);

      // Update local feedback
      final feedbackIndex = _myFeedbacks.indexWhere((f) => f.id == feedbackId);
      if (feedbackIndex != -1) {
        final updatedFeedback = _myFeedbacks[feedbackIndex].copyWith(
          tourRating: request.tourRating ?? _myFeedbacks[feedbackIndex].tourRating,
          tourComment: request.tourComment ?? _myFeedbacks[feedbackIndex].tourComment,
          guideRating: request.guideRating ?? _myFeedbacks[feedbackIndex].guideRating,
          guideComment: request.guideComment ?? _myFeedbacks[feedbackIndex].guideComment,
        );
        _myFeedbacks[feedbackIndex] = updatedFeedback;
      }

      _clearError();
      _logger.i('Successfully updated feedback');
      return true;
    } catch (e) {
      _logger.e('Error updating feedback: $e');
      _setError('Lỗi khi cập nhật đánh giá: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete feedback
  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      _setLoading(true);
      _logger.i('Deleting feedback: $feedbackId');

      await _userApiService.deleteFeedback(feedbackId);

      // Remove from local list
      _myFeedbacks.removeWhere((f) => f.id == feedbackId);

      _clearError();
      _logger.i('Successfully deleted feedback');
      return true;
    } catch (e) {
      _logger.e('Error deleting feedback: $e');
      _setError('Lỗi khi xóa đánh giá: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  /// Clear tour timeline
  void clearTourTimeline() {
    _tourTimeline = null;
    notifyListeners();
  }

  /// Clear dashboard summary
  void clearDashboardSummary() {
    _dashboardSummary = null;
    notifyListeners();
  }

  /// Clear tour progress
  void clearTourProgress() {
    _tourProgress = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      getMyBookings(refresh: true),
      getDashboardSummary(),
      getMyFeedbacks(refresh: true),
    ]);
  }

  // Private helper methods
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

  bool _hasFeedback(String bookingId) {
    return _myFeedbacks.any((feedback) => feedback.bookingId == bookingId);
  }

  /// Report incident for user
  Future<bool> reportIncident({
    required String tourOperationId,
    required String title,
    required String description,
    required String location,
    required String priority,
    required String category,
  }) async {
    try {
      _logger.i('Reporting incident for tour: $tourOperationId');

      // Create detailed content with all incident information
      final detailedContent = '''
Báo cáo sự cố tour

Tour Operation ID: $tourOperationId
Loại sự cố: $category
Mức độ ưu tiên: $priority
Địa điểm: $location

Mô tả chi tiết:
$description
      '''.trim();

      // Use Support Tickets API as alternative for user incident reporting
      final success = await _userApiService.createSupportTicket(
        title: title,
        content: detailedContent,
      );

      if (success) {
        _logger.i('Successfully reported incident');
        return true;
      } else {
        _logger.e('Failed to report incident');
        return false;
      }
    } catch (e) {
      _logger.e('Error reporting incident: $e');
      return false;
    }
  }
}
