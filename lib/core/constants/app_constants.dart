/// App Constants for TayNinh Tour Mobile App
class AppConstants {
  // App Info
  static const String appName = 'TayNinh Tour HDV';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  
  // User Roles
  static const String tourGuideRole = 'Tour Guide';
  
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
}
