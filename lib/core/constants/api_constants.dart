/// API Constants for TayNinh Tour Mobile App
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:5267/api';
  static const String prodBaseUrl = 'https://api.tayninhtravel.com/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  
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
