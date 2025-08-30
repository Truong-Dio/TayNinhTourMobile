import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/individual_qr_models.dart';

/// ✅ SIMPLIFIED: Service để validate QR codes cơ bản
/// Backend sẽ handle tất cả parsing logic phức tạp
class QRParsingService {
  static final Logger _logger = Logger();

  /// Simplified QR validation - chỉ check format cơ bản
  /// Backend sẽ handle tất cả parsing logic
  static QRValidationResult parseAndValidateQR(String qrString) {
    try {
      _logger.i('🔍 Validating QR code: ${qrString.length} chars');

      // Basic validation: check if it's valid JSON
      final Map<String, dynamic> qrData = jsonDecode(qrString);

      // ✅ SIMPLIFIED: Chỉ check cơ bản để determine UI display
      String qrType = 'Unknown';
      String? bookingCode;
      String? displayInfo;

      // Try to extract booking code for display
      bookingCode = _extractBookingCode(qrData);

      // Try to determine basic type for UI display
      if (_looksLikeIndividualQR(qrData)) {
        qrType = 'IndividualGuest';
        displayInfo = _extractGuestName(qrData) ?? 'Khách hàng';
      } else if (_looksLikeGroupQR(qrData)) {
        qrType = 'GroupBooking';
        displayInfo = _extractGroupName(qrData) ?? 'Nhóm';
      } else if (bookingCode != null) {
        qrType = 'Legacy';
        displayInfo = bookingCode;
      }

      _logger.i('✅ QR validated: Type=$qrType, BookingCode=$bookingCode');

      return QRValidationResult(
        isValid: true,
        qrType: qrType,
        legacyBookingCode: bookingCode,
        // Note: We don't create full objects anymore - backend will handle parsing
      );

    } catch (e) {
      if (e is FormatException) {
        _logger.w('❌ Invalid JSON in QR code');
        return const QRValidationResult(
          isValid: false,
          qrType: 'Invalid',
          errorMessage: 'QR code không đúng định dạng JSON',
        );
      } else {
        _logger.e('❌ Error validating QR: $e');
        return QRValidationResult(
          isValid: false,
          qrType: 'Error',
          errorMessage: 'Lỗi xử lý QR code: $e',
        );
      }
    }
  }

  /// Extract booking code from various QR formats
  static String? _extractBookingCode(Map<String, dynamic> qrData) {
    // Try different booking code fields
    return qrData['c'] as String? ??           // Ultra-compact v2.0
           qrData['bc'] as String? ??          // Compact v3.0
           qrData['bookingCode'] as String?;   // Full format
  }

  /// Extract guest name for display
  static String? _extractGuestName(Map<String, dynamic> qrData) {
    return qrData['n'] as String? ??           // Ultra-compact v2.0
           qrData['guestName'] as String?;     // Full format
  }

  /// Extract group name for display
  static String? _extractGroupName(Map<String, dynamic> qrData) {
    return qrData['g'] as String? ??           // Ultra-compact v2.0 (group name)
           qrData['groupName'] as String?;     // Full format
  }

  /// Simple check if QR looks like individual guest QR
  static bool _looksLikeIndividualQR(Map<String, dynamic> qrData) {
    // Ultra-compact v2.0: has 'g' (guest ID) but no 'n' (numberOfGuests)
    if (qrData.containsKey('v') && qrData['v'] == '2.0') {
      return qrData.containsKey('g') &&
             qrData['g'] is String &&
             (qrData['g'] as String).length == 6 &&
             !qrData.containsKey('n'); // No numberOfGuests
    }

    // Full format
    return qrData['qrType'] == 'IndividualGuest';
  }

  /// Simple check if QR looks like group QR
  static bool _looksLikeGroupQR(Map<String, dynamic> qrData) {
    // Ultra-compact v2.0: has 'b' (booking ID) and 'n' (numberOfGuests)
    if (qrData.containsKey('v') && qrData['v'] == '2.0') {
      return qrData.containsKey('b') &&
             qrData.containsKey('n'); // Has numberOfGuests
    }

    // Full format
    return qrData['qrType'] == 'GroupBooking' ||
           qrData['bookingType'] == 'GroupRepresentative';
  }

  /// Generate user-friendly description of QR code for UI display
  static String getQRDescription(QRValidationResult result) {
    if (!result.isValid) {
      return '❌ ${result.errorMessage ?? 'QR code không hợp lệ'}';
    }

    switch (result.qrType) {
      case 'IndividualGuest':
        return '👤 QR cá nhân: ${result.legacyBookingCode ?? 'N/A'}';

      case 'GroupBooking':
        return '👥 QR nhóm: ${result.legacyBookingCode ?? 'N/A'}';

      case 'Legacy':
      default:
        return '📋 QR booking: ${result.legacyBookingCode ?? 'N/A'}';
    }
  }
}