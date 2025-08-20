/// App Constants for TayNinh Tour Mobile App
class AppConstants {
  // App Info
  static const String appName = 'TayNinh Tour';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';

  // User Roles
  static const String tourGuideRole = 'Tour Guide';
  static const String userRole = 'User';
  
  // QR Code
  static const String qrCodePrefix = 'TAYNINH_TOUR_';
  static const int qrCodeScanTimeout = 30; // seconds
  
  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Incident Severity
  static const List<String> incidentSeverityLevels = [
    'Low',
    'Medium', 
    'High',
    'Critical'
  ];
  
  // Notification Types
  static const String notificationTypeTimeline = 'timeline_progress';
  static const String notificationTypeIncident = 'incident_report';
  static const String notificationTypeGeneral = 'general';
  
  // Cache Duration
  static const Duration cacheExpiration = Duration(minutes: 30);
  static const Duration shortCacheExpiration = Duration(minutes: 5);

  // Tour Status for User
  static const String tourStatusUpcoming = 'upcoming';
  static const String tourStatusOngoing = 'ongoing';
  static const String tourStatusCompleted = 'completed';
  static const String tourStatusCancelled = 'cancelled';

  // Booking Status Mapping
  static const Map<String, String> bookingStatusMapping = {
    'Pending': 'upcoming',
    'Confirmed': 'upcoming',
    'Completed': 'completed',
    'CancelledByCustomer': 'cancelled',
    'CancelledByCompany': 'cancelled',
    'NoShow': 'cancelled',
    'Refunded': 'cancelled',
  };

  // Feedback Rating
  static const int minRating = 1;
  static const int maxRating = 5;
}
