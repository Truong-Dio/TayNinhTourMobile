/// API Constants for TayNinh Tour HDV Mobile App
class ApiConstants {
  // Base URLs - Using local server for development
  static const String baseUrl = prodBaseUrl;
  static const String localBaseUrl = 'http://192.168.100.55:5267/api'; // For physical device on same network
  static const String emulatorBaseUrl = 'http://10.0.2.2:5267/api'; // For Android emulator
  static const String prodBaseUrl = 'https://card-diversevercel.io.vn/api';

  // Authentication endpoints (corrected path)
  static const String login = '/Authentication/login';
  static const String refreshToken = '/Authentication/refresh-token';
  static const String sendOtpResetPassword = '/Authentication/send-otp-reset-password';
  static const String resetPassword = '/Authentication/reset-password';

  // Account management endpoints
  static const String changePassword = '/Account/change-password';
  static const String editProfile = '/Account/edit-profile';

  // Core HDV Tour Guide endpoints (6 endpoints theo plan)
  static const String myActiveTours = '/TourGuide/my-active-tours';
  static const String tourBookings = '/TourGuide/tour/{operationId}/bookings';
  static const String tourTimeline = '/TourGuide/tour/{operationId}/timeline';
  static const String checkInGuest = '/TourGuide/checkin/{bookingId}';
  static const String completeTimelineItem = '/TourGuide/timeline/{timelineId}/complete';
  static const String reportIncident = '/TourGuide/incident/report';
  static const String notifyGuests = '/TourGuide/tour/{operationId}/notify-guests';

  // NEW: Tour Slot completion endpoint
  static const String completeTourSlot = '/TourSlot/{tourSlotId}/complete';

  // Tour Guide Invitation endpoints - FIXED: Correct controller name
  static const String myInvitations = '/TourGuideInvitation/my-invitations';
  static const String acceptInvitation = '/TourGuideInvitation/{invitationId}/accept';
  static const String rejectInvitation = '/TourGuideInvitation/{invitationId}/reject';

  // Image upload for incident reports
  static const String uploadImage = '/Image/Upload';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
