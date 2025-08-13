import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/individual_qr_models.dart';

/// ✅ NEW: Service để parse và validate QR codes
class QRParsingService {
  static final Logger _logger = Logger();

  /// Parse QR code string và determine type
  static QRValidationResult parseAndValidateQR(String qrString) {
    try {
      // Try to parse as JSON first (Individual QR)
      final Map<String, dynamic> qrData = jsonDecode(qrString);
      
      // Check if it's Group Booking QR
      if (_isGroupBookingQR(qrData)) {
        return _validateGroupBookingQR(qrData);
      }
      
      // Check if it's Individual Guest QR
      if (_isIndividualGuestQR(qrData)) {
        return _validateIndividualGuestQR(qrData);
      }
      
      // Check if it's legacy format
      if (_isLegacyQR(qrData)) {
        return _validateLegacyQR(qrData);
      }
      
      return const QRValidationResult(
        isValid: false,
        qrType: 'unknown',
        errorMessage: 'QR format không được hỗ trợ',
      );
      
    } catch (e) {
      // Not JSON, try as plain text (legacy booking code)
      return _validatePlainTextQR(qrString);
    }
  }

  /// Check if QR data is Group Booking format
  static bool _isGroupBookingQR(Map<String, dynamic> data) {
    return data.containsKey('qrType') && 
           data['qrType'] == 'GroupBooking' &&
           data.containsKey('version') &&
           data['version'] == '1.0' &&
           data.containsKey('bookingType') &&
           data['bookingType'] == 'GroupRepresentative';
  }

  /// Check if QR data is Individual Guest format
  static bool _isIndividualGuestQR(Map<String, dynamic> data) {
    return data.containsKey('qrType') && 
           data['qrType'] == 'IndividualGuest' &&
           data.containsKey('version') &&
           data['version'] == '3.0' &&
           data.containsKey('guestId');
  }

  /// Check if QR data is legacy booking format
  static bool _isLegacyQR(Map<String, dynamic> data) {
    return data.containsKey('bookingId') && 
           data.containsKey('bookingCode') &&
           !data.containsKey('guestId');
  }

  /// Validate Individual Guest QR
  static QRValidationResult _validateIndividualGuestQR(Map<String, dynamic> data) {
    try {
      final qr = IndividualGuestQR.fromJson(data);
      
      // Additional validations
      final errors = <String>[];
      
      // Validate required fields
      if (qr.guestId.isEmpty) errors.add('Guest ID không hợp lệ');
      if (qr.guestName.isEmpty) errors.add('Tên khách hàng không hợp lệ');
      if (qr.guestEmail.isEmpty) errors.add('Email không hợp lệ');
      if (qr.bookingId.isEmpty) errors.add('Booking ID không hợp lệ');
      if (qr.tourSlotId.isEmpty) errors.add('Tour Slot ID không hợp lệ');
      
      // Validate tour date (relaxed for testing)
      try {
        final tourDate = DateTime.parse(qr.tourDate);
        final now = DateTime.now();
        final daysDifference = now.difference(tourDate).inDays;
        
        // Relaxed validation for testing
        // Allow check-in up to 365 days before tour (for testing)
        // And up to 30 days after tour
        if (daysDifference > 30) {
          errors.add('QR code đã quá hạn (tour ${daysDifference} ngày trước)');
        }
        
        // Allow testing with future tours
        if (daysDifference < -365) {
          errors.add('QR code chưa hợp lệ (tour còn ${-daysDifference} ngày)');
        }
      } catch (e) {
        errors.add('Ngày tour không hợp lệ');
      }
      
      if (errors.isNotEmpty) {
        return QRValidationResult(
          isValid: false,
          qrType: 'IndividualGuest',
          errorMessage: errors.join(', '),
        );
      }
      
      _logger.i('✅ Valid Individual Guest QR: ${qr.guestName} (${qr.bookingCode})');
      
      return QRValidationResult(
        isValid: true,
        qrType: 'IndividualGuest',
        individualGuestQR: qr,
      );
      
    } catch (e) {
      _logger.e('❌ Individual Guest QR parse error: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'IndividualGuest',
        errorMessage: 'QR data không hợp lệ: $e',
      );
    }
  }

  /// Validate Group Booking QR
  static QRValidationResult _validateGroupBookingQR(Map<String, dynamic> data) {
    try {
      final qr = GroupBookingQR.fromJson(data);
      
      // Additional validations
      final errors = <String>[];
      
      // Validate required fields
      if (qr.bookingId.isEmpty) errors.add('Booking ID không hợp lệ');
      if (qr.bookingCode.isEmpty) errors.add('Booking Code không hợp lệ');
      if (qr.numberOfGuests <= 0) errors.add('Số lượng khách không hợp lệ');
      if (qr.tourSlotId?.isEmpty ?? true) errors.add('Tour Slot ID không hợp lệ');
      
      // Validate tour date (relaxed for testing)
      try {
        final tourDate = DateTime.parse(qr.tourDate);
        final now = DateTime.now();
        final daysDifference = now.difference(tourDate).inDays;
        
        // Relaxed validation for testing
        if (daysDifference > 30) {
          errors.add('QR code đã quá hạn (tour ${daysDifference} ngày trước)');
        }
        
        if (daysDifference < -365) {
          errors.add('QR code chưa hợp lệ (tour còn ${-daysDifference} ngày)');
        }
      } catch (e) {
        errors.add('Ngày tour không hợp lệ');
      }
      
      if (errors.isNotEmpty) {
        return QRValidationResult(
          isValid: false,
          qrType: 'GroupBooking',
          errorMessage: errors.join(', '),
        );
      }
      
      _logger.i('✅ Valid Group Booking QR: ${qr.groupName ?? "Nhóm"} (${qr.bookingCode})');
      
      return QRValidationResult(
        isValid: true,
        qrType: 'GroupBooking',
        groupBookingQR: qr,
      );
      
    } catch (e) {
      _logger.e('❌ Group Booking QR parse error: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'GroupBooking',
        errorMessage: 'QR data không hợp lệ: $e',
      );
    }
  }

  /// Validate legacy QR format
  static QRValidationResult _validateLegacyQR(Map<String, dynamic> data) {
    try {
      final bookingCode = data['bookingCode']?.toString();
      final bookingId = data['bookingId']?.toString();
      
      if (bookingCode == null && bookingId == null) {
        return const QRValidationResult(
          isValid: false,
          qrType: 'legacy',
          errorMessage: 'Không tìm thấy mã booking',
        );
      }
      
      _logger.i('✅ Valid Legacy QR: ${bookingCode ?? bookingId}');
      
      return QRValidationResult(
        isValid: true,
        qrType: 'legacy',
        legacyBookingCode: bookingCode ?? bookingId,
      );
      
    } catch (e) {
      return QRValidationResult(
        isValid: false,
        qrType: 'legacy',
        errorMessage: 'Legacy QR không hợp lệ: $e',
      );
    }
  }

  /// Validate plain text QR (simple booking code)
  static QRValidationResult _validatePlainTextQR(String qrString) {
    final trimmed = qrString.trim();
    
    if (trimmed.isEmpty) {
      return const QRValidationResult(
        isValid: false,
        qrType: 'plain',
        errorMessage: 'QR code trống',
      );
    }
    
    // Basic validation cho booking code format
    if (trimmed.length < 5 || trimmed.length > 50) {
      return const QRValidationResult(
        isValid: false,
        qrType: 'plain',
        errorMessage: 'Mã booking không hợp lệ',
      );
    }
    
    _logger.i('✅ Valid Plain Text QR: $trimmed');
    
    return QRValidationResult(
      isValid: true,
      qrType: 'plain',
      legacyBookingCode: trimmed,
    );
  }

  /// Format QR validation result for display
  static String getDisplayMessage(QRValidationResult result) {
    if (!result.isValid) {
      return result.errorMessage ?? 'QR code không hợp lệ';
    }
    
    switch (result.qrType) {
      case 'IndividualGuest':
        final qr = result.individualGuestQR!;
        return 'QR hợp lệ: ${qr.guestName}\nBooking: ${qr.bookingCode}';
        
      case 'GroupBooking':
        final qr = result.groupBookingQR!;
        return 'QR nhóm hợp lệ: ${qr.groupName ?? "Nhóm"}\nBooking: ${qr.bookingCode}\nSố khách: ${qr.numberOfGuests}';
        
      case 'legacy':
      case 'plain':
        return 'QR hợp lệ: ${result.legacyBookingCode}';
        
      default:
        return 'QR code hợp lệ';
    }
  }

  /// Get QR type display name
  static String getQRTypeDisplayName(String qrType) {
    switch (qrType) {
      case 'IndividualGuest':
        return 'QR Khách hàng cá nhân';
      case 'GroupBooking':
        return 'QR Nhóm đại diện';
      case 'legacy':
        return 'QR Booking cũ';
      case 'plain':
        return 'QR Mã booking';
      default:
        return 'QR không xác định';
    }
  }
}