/// API Constants for TayNinh Tour Mobile App
class ApiConstants {
  // Base URLs - Using production server only
  static const String baseUrl = 'https://tayninhtour.card-diversevercel.io.vn/api';
  static const String prodBaseUrl = 'https://tayninhtour.card-diversevercel.io.vn/api';
  
  // Auth endpoints
  static const String login = '/Auth/login';
  static const String refreshToken = '/Auth/refresh-token';
  static const String logout = '/Auth/logout';
  
  // Tour Guide endpoints
  static const String myActiveTours = '/TourGuide/my-active-tours';
  static const String tourBookings = '/TourGuide/tour/{operationId}/bookings';
  static const String tourTimeline = '/TourGuide/tour/{tourDetailsId}/timeline';
  static const String checkInGuest = '/TourGuide/checkin/{bookingId}';
  static const String completeTimelineItem = '/TourGuide/timeline/{timelineId}/complete';
  static const String reportIncident = '/TourGuide/incident/report';
  static const String notifyGuests = '/TourGuide/tour/{operationId}/notify-guests';
  
  // Image upload
  static const String uploadImage = '/public/upload-image';
  
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
