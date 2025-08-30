import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/individual_qr_models.dart';

/// ✅ NEW: Service để parse và validate QR codes
class QRParsingService {
  static final Logger _logger = Logger();

  /// Parse QR code string và determine type
  /// ENHANCED: Support all backend QR formats including ultra-compact v2.0 and minimal v1.0
  static QRValidationResult parseAndValidateQR(String qrString) {
    try {
      // Try to parse as JSON first
      final Map<String, dynamic> qrData = jsonDecode(qrString);

      // ✅ Priority 1: Ultra-Compact Individual Guest QR v2.0 (most common)
      if (_isUltraCompactIndividualQR(qrData)) {
        return _validateUltraCompactIndividualQR(qrData);
      }

      // ✅ Priority 2: Ultra-Compact Group QR v2.0
      if (_isUltraCompactGroupQR(qrData)) {
        return _validateUltraCompactGroupQR(qrData);
      }

      // ✅ Priority 3: Minimal QR v1.0 (fallback when ultra-compact is too long)
      if (_isMinimalQR(qrData)) {
        return _validateMinimalQR(qrData);
      }

      // ✅ Priority 4: Compact Booking QR v3.0 (legacy)
      if (_isCompactBookingQR(qrData)) {
        return _validateCompactBookingQR(qrData);
      }

      // ✅ Priority 5: Fallback QR (when main generation fails)
      if (_isFallbackQR(qrData)) {
        return _validateFallbackQR(qrData);
      }

      // ✅ Priority 6: Full format QRs (old mobile app generated)
      if (_isGroupBookingQR(qrData)) {
        return _validateGroupBookingQR(qrData);
      }

      if (_isIndividualGuestQR(qrData)) {
        return _validateIndividualGuestQR(qrData);
      }

      // ✅ Priority 7: Legacy formats
      if (_isLegacyQR(qrData)) {
        return _validateLegacyQR(qrData);
      }

      // ✅ Priority 8: Any QR with booking code (ultra-fallback)
      if (qrData.containsKey('bc') || qrData.containsKey('bookingCode')) {
        return _validateBookingCodeOnlyQR(qrData);
      }

      return const QRValidationResult(
        isValid: false,
        qrType: 'unknown',
        errorMessage: 'QR format không được hỗ trợ hoặc thiếu thông tin bắt buộc',
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

  /// Check if QR data is Ultra-Compact Individual Guest format v2.0
  static bool _isUltraCompactIndividualQR(Map<String, dynamic> data) {
    return data.containsKey('v') &&
           data['v'] == '2.0' &&
           data.containsKey('g') && // guest ID (6 chars)
           data['g'] != null && // guest ID must not be null
           data.containsKey('c') && // booking code (required)
           !data.containsKey('n'); // NO number of guests (distinguishes from group)
  }

  /// Check if QR data is Ultra-Compact Group format v2.0
  static bool _isUltraCompactGroupQR(Map<String, dynamic> data) {
    return data.containsKey('v') &&
           data['v'] == '2.0' &&
           data.containsKey('b') && // booking ID (6 chars)
           data.containsKey('c') && // booking code (required)
           data.containsKey('n') && // number of guests (required for group)
           data['n'] != null && // number of guests must not be null
           (data.containsKey('g') && data['g'] != null || // group name (can be null for some groups)
            data.containsKey('cn')); // or contact name exists
  }

  /// Check if QR data is Minimal format v1.0 (fallback when ultra-compact is too long)
  static bool _isMinimalQR(Map<String, dynamic> data) {
    return data.containsKey('v') &&
           data['v'] == '1.0' &&
           data.containsKey('c') && // booking code (required)
           (data.containsKey('g') || data.containsKey('b')); // guest ID (4 chars) or booking ID (4 chars)
  }

  /// Check if QR data is Compact Booking format v3.0 (legacy)
  static bool _isCompactBookingQR(Map<String, dynamic> data) {
    return data.containsKey('v') &&
           data['v'] == '3.0' &&
           data.containsKey('bid') && // booking ID (8 chars)
           data.containsKey('bc'); // booking code
  }

  /// Check if QR data is Fallback format
  static bool _isFallbackQR(Map<String, dynamic> data) {
    return data.containsKey('type') &&
           data['type'] == 'Fallback' &&
           data.containsKey('bookingCode');
  }

  /// Check if QR data is legacy booking format
  static bool _isLegacyQR(Map<String, dynamic> data) {
    return data.containsKey('bookingId') &&
           data.containsKey('bookingCode') &&
           !data.containsKey('guestId');
  }

  /// Validate Ultra-Compact Individual Guest QR v2.0
  /// ENHANCED: Better validation and error handling based on backend format
  static QRValidationResult _validateUltraCompactIndividualQR(Map<String, dynamic> data) {
    try {
      // Extract ultra-compact data (based on backend GenerateGuestQRCodeData)
      final guestIdShort = data['g']?.toString() ?? '';
      final guestName = data['n']?.toString() ?? '';
      final guestEmail = data['e']?.toString() ?? '';
      final guestPhone = data['p']?.toString();
      final bookingIdShort = data['b']?.toString() ?? '';
      final bookingCode = data['c']?.toString() ?? '';
      final tourDateShort = data['t']?.toString() ?? '';
      final isCheckedIn = (data['s'] ?? 0) == 1;

      // Validate required fields (only essential ones)
      final errors = <String>[];
      if (guestIdShort.isEmpty || guestIdShort.length != 6) {
        errors.add('Guest ID không hợp lệ (cần 6 ký tự)');
      }
      if (bookingCode.isEmpty) {
        errors.add('Booking Code không hợp lệ');
      }

      // Optional validations (có thể thiếu trong ultra-compact)
      if (guestName.isNotEmpty && guestName.length > 20) {
        errors.add('Tên khách hàng quá dài');
      }
      if (guestEmail.isNotEmpty && guestEmail.length > 30) {
        errors.add('Email quá dài');
      }
      if (guestPhone != null && guestPhone!.length > 15) {
        errors.add('Số điện thoại quá dài');
      }

      // Validate tour date format (yyMMdd) if present
      if (tourDateShort.isNotEmpty && tourDateShort.length != 6) {
        errors.add('Ngày tour không đúng định dạng (yyMMdd)');
      }

      if (errors.isNotEmpty) {
        return QRValidationResult(
          isValid: false,
          qrType: 'UltraCompactIndividual',
          errorMessage: errors.join(', '),
        );
      }

      // Convert to full format for compatibility (backend sẽ expand short IDs)
      final fullFormatQR = IndividualGuestQR(
        guestId: guestIdShort, // Backend sẽ expand từ 6 chars thành full GUID
        guestName: guestName.isNotEmpty ? guestName : 'Khách hàng',
        guestEmail: guestEmail.isNotEmpty ? guestEmail : '',
        guestPhone: guestPhone,
        bookingId: bookingIdShort, // Backend sẽ expand từ 6 chars thành full GUID
        bookingCode: bookingCode,
        tourOperationId: '', // Không có trong ultra-compact
        tourSlotId: '', // Không có trong ultra-compact
        totalBookingPrice: 0.0, // Không có trong ultra-compact
        numberOfGuests: 1, // Default cho individual
        originalPrice: 0.0, // Không có trong ultra-compact
        discountPercent: 0.0, // Không có trong ultra-compact
        tourTitle: 'Tour', // Default
        tourDate: tourDateShort.isNotEmpty ? _convertShortDateToFull(tourDateShort) : DateTime.now().toString().substring(0, 10),
        isCheckedIn: isCheckedIn,
        checkInTime: null,
        generatedAt: DateTime.now().toIso8601String(),
        qrType: 'IndividualGuest',
        version: '2.0',
      );

      _logger.i('✅ Valid Ultra-Compact Individual QR v2.0: ${guestName.isNotEmpty ? guestName : guestIdShort}');

      return QRValidationResult(
        isValid: true,
        qrType: 'IndividualGuest',
        individualGuestQR: fullFormatQR,
      );

    } catch (e) {
      _logger.e('❌ Error validating ultra-compact individual QR: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'UltraCompactIndividual',
        errorMessage: 'Ultra-compact Individual QR không hợp lệ: $e',
      );
    }
  }

  /// Validate Individual Guest QR (old full format)
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

  /// Validate Ultra-Compact Group QR v2.0
  static QRValidationResult _validateUltraCompactGroupQR(Map<String, dynamic> data) {
    try {
      // Extract ultra-compact data
      final bookingIdShort = data['b']?.toString() ?? '';
      final bookingCode = data['c']?.toString() ?? '';
      final groupName = data['g']?.toString() ?? '';
      final numberOfGuests = data['n'] ?? 0;
      final tourDateShort = data['t']?.toString() ?? '';
      final contactName = data['cn']?.toString();
      final contactEmail = data['ce']?.toString();
      final contactPhone = data['cp']?.toString();
      final totalPrice = (data['p'] ?? 0.0).toDouble();

      // Validate required fields
      final errors = <String>[];
      if (bookingIdShort.isEmpty) errors.add('Booking ID không hợp lệ');
      if (bookingCode.isEmpty) errors.add('Booking Code không hợp lệ');
      // Group name can be null/empty, use contact name or default
      if (groupName.isEmpty && (contactName?.isEmpty ?? true)) {
        errors.add('Tên nhóm hoặc tên liên hệ không hợp lệ');
      }
      if (numberOfGuests <= 0) errors.add('Số lượng khách không hợp lệ');

      // Validate tour date format (yyMMdd)
      if (tourDateShort.length != 6) {
        errors.add('Ngày tour không hợp lệ');
      }

      if (errors.isNotEmpty) {
        return QRValidationResult(
          isValid: false,
          qrType: 'UltraCompactGroup',
          errorMessage: errors.join(', '),
        );
      }

      // Convert to full format for compatibility
      final effectiveGroupName = groupName.isNotEmpty ? groupName : (contactName?.isNotEmpty == true ? 'Nhóm ${contactName}' : 'Nhóm khách');

      final fullFormatQR = GroupBookingQR(
        bookingId: bookingIdShort, // Will be expanded by backend
        bookingCode: bookingCode,
        bookingType: 'GroupRepresentative',
        groupName: effectiveGroupName,
        groupDescription: null,
        numberOfGuests: numberOfGuests,
        tourOperationId: '', // Not available in compact format
        tourSlotId: '', // Not available in compact format
        tourTitle: 'Tour', // Default
        tourDate: _convertShortDateToFull(tourDateShort),
        contactName: contactName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        totalPrice: totalPrice,
        originalPrice: totalPrice, // Default same as total
        discountPercent: 0.0, // Default
        generatedAt: DateTime.now().toIso8601String(),
        qrType: 'GroupBooking',
        version: '2.0',
      );

      _logger.i('✅ Valid Ultra-Compact Group QR v2.0: ${effectiveGroupName}');

      return QRValidationResult(
        isValid: true,
        qrType: 'GroupBooking',
        groupBookingQR: fullFormatQR,
      );

    } catch (e) {
      return QRValidationResult(
        isValid: false,
        qrType: 'UltraCompactGroup',
        errorMessage: 'Ultra-compact Group QR không hợp lệ: $e',
      );
    }
  }

  /// Validate Minimal QR v1.0 (fallback when ultra-compact is too long)
  /// ENHANCED: Handle both individual and group minimal formats
  static QRValidationResult _validateMinimalQR(Map<String, dynamic> data) {
    try {
      final bookingCode = data['c']?.toString() ?? '';
      final guestIdShort = data['g']?.toString(); // 4 chars for individual
      final bookingIdShort = data['b']?.toString(); // 4 chars for group

      if (bookingCode.isEmpty) {
        return const QRValidationResult(
          isValid: false,
          qrType: 'minimal',
          errorMessage: 'Booking Code không hợp lệ',
        );
      }

      // Determine if it's individual or group based on available fields
      if (guestIdShort != null && guestIdShort.length == 4) {
        // Minimal Individual Guest QR
        final individualQR = IndividualGuestQR(
          guestId: guestIdShort, // Backend sẽ expand
          guestName: 'Khách hàng', // Default
          guestEmail: '',
          guestPhone: null,
          bookingId: '', // Không có trong minimal
          bookingCode: bookingCode,
          tourOperationId: '',
          tourSlotId: '',
          totalBookingPrice: 0.0,
          numberOfGuests: 1,
          originalPrice: 0.0,
          discountPercent: 0.0,
          tourTitle: 'Tour',
          tourDate: DateTime.now().toString().substring(0, 10),
          isCheckedIn: false,
          checkInTime: null,
          generatedAt: DateTime.now().toIso8601String(),
          qrType: 'IndividualGuest',
          version: '1.0',
        );

        _logger.i('✅ Valid Minimal Individual QR v1.0: $bookingCode');

        return QRValidationResult(
          isValid: true,
          qrType: 'IndividualGuest',
          individualGuestQR: individualQR,
        );
      } else if (bookingIdShort != null && bookingIdShort.length == 4) {
        // Minimal Group QR
        final groupQR = GroupBookingQR(
          bookingId: bookingIdShort, // Backend sẽ expand
          bookingCode: bookingCode,
          bookingType: 'GroupRepresentative',
          groupName: 'Nhóm',
          groupDescription: null,
          numberOfGuests: 1, // Default
          tourOperationId: '',
          tourSlotId: '',
          tourTitle: 'Tour',
          tourDate: DateTime.now().toString().substring(0, 10),
          contactName: null,
          contactEmail: null,
          contactPhone: null,
          totalPrice: 0.0,
          originalPrice: 0.0,
          discountPercent: 0.0,
          generatedAt: DateTime.now().toIso8601String(),
          qrType: 'GroupBooking',
          version: '1.0',
        );

        _logger.i('✅ Valid Minimal Group QR v1.0: $bookingCode');

        return QRValidationResult(
          isValid: true,
          qrType: 'GroupBooking',
          groupBookingQR: groupQR,
        );
      } else {
        // Fallback: treat as legacy booking code
        _logger.i('✅ Valid Minimal QR v1.0 (legacy): $bookingCode');

        return QRValidationResult(
          isValid: true,
          qrType: 'minimal',
          legacyBookingCode: bookingCode,
        );
      }

    } catch (e) {
      _logger.e('❌ Error validating minimal QR: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'minimal',
        errorMessage: 'Minimal QR không hợp lệ: $e',
      );
    }
  }

  /// Validate Compact Booking QR v3.0 (legacy format)
  static QRValidationResult _validateCompactBookingQR(Map<String, dynamic> data) {
    try {
      final bookingIdShort = data['bid']?.toString() ?? '';
      final bookingCode = data['bc']?.toString() ?? '';
      final userIdShort = data['uid']?.toString() ?? '';
      final tourOpIdShort = data['toid']?.toString() ?? '';
      final numberOfGuests = data['ng'] ?? 1;
      final totalPrice = (data['tp'] ?? 0.0).toDouble();
      final originalPrice = (data['op'] ?? 0.0).toDouble();
      final discountPercent = (data['dp'] ?? 0.0).toDouble();
      final status = data['st'] ?? 0;
      final bookingDateStr = data['bd']?.toString() ?? '';

      if (bookingIdShort.isEmpty || bookingCode.isEmpty) {
        return const QRValidationResult(
          isValid: false,
          qrType: 'CompactBooking',
          errorMessage: 'Booking ID hoặc Booking Code không hợp lệ',
        );
      }

      // Convert to legacy format for compatibility
      _logger.i('✅ Valid Compact Booking QR v3.0: $bookingCode');

      return QRValidationResult(
        isValid: true,
        qrType: 'legacy',
        legacyBookingCode: bookingCode,
      );

    } catch (e) {
      _logger.e('❌ Error validating compact booking QR: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'CompactBooking',
        errorMessage: 'Compact Booking QR không hợp lệ: $e',
      );
    }
  }

  /// Validate Fallback QR (when main generation fails)
  static QRValidationResult _validateFallbackQR(Map<String, dynamic> data) {
    try {
      final bookingCode = data['bookingCode']?.toString() ?? '';
      final type = data['type']?.toString() ?? '';

      if (bookingCode.isEmpty || type != 'Fallback') {
        return const QRValidationResult(
          isValid: false,
          qrType: 'fallback',
          errorMessage: 'Fallback QR không hợp lệ',
        );
      }

      _logger.i('✅ Valid Fallback QR: $bookingCode');

      return QRValidationResult(
        isValid: true,
        qrType: 'fallback',
        legacyBookingCode: bookingCode,
      );

    } catch (e) {
      _logger.e('❌ Error validating fallback QR: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'fallback',
        errorMessage: 'Fallback QR không hợp lệ: $e',
      );
    }
  }

  /// Validate any QR with booking code only (ultra-fallback)
  static QRValidationResult _validateBookingCodeOnlyQR(Map<String, dynamic> data) {
    try {
      final bookingCode = data['bc']?.toString() ?? data['bookingCode']?.toString() ?? '';

      if (bookingCode.isEmpty) {
        return const QRValidationResult(
          isValid: false,
          qrType: 'bookingCodeOnly',
          errorMessage: 'Booking Code không tìm thấy',
        );
      }

      _logger.i('✅ Valid Booking Code Only QR: $bookingCode');

      return QRValidationResult(
        isValid: true,
        qrType: 'bookingCodeOnly',
        legacyBookingCode: bookingCode,
      );

    } catch (e) {
      _logger.e('❌ Error validating booking code only QR: $e');
      return QRValidationResult(
        isValid: false,
        qrType: 'bookingCodeOnly',
        errorMessage: 'Booking Code QR không hợp lệ: $e',
      );
    }
  }

  /// Convert short date format (yyMMdd) to full date (yyyy-MM-dd)
  static String _convertShortDateToFull(String shortDate) {
    if (shortDate.length != 6) return DateTime.now().toString().substring(0, 10);

    try {
      final year = int.parse('20${shortDate.substring(0, 2)}');
      final month = int.parse(shortDate.substring(2, 4));
      final day = int.parse(shortDate.substring(4, 6));

      return DateTime(year, month, day).toString().substring(0, 10);
    } catch (e) {
      return DateTime.now().toString().substring(0, 10);
    }
  }

  /// Validate Group Booking QR (old full format)
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
  /// ENHANCED: Support all backend QR formats
  static String getDisplayMessage(QRValidationResult result) {
    if (!result.isValid) {
      return result.errorMessage ?? 'QR code không hợp lệ';
    }

    switch (result.qrType) {
      case 'IndividualGuest':
        final qr = result.individualGuestQR!;
        final version = qr.version;
        final statusIcon = qr.isCheckedIn ? '✅' : '⏳';
        return '$statusIcon QR cá nhân (v$version): ${qr.guestName}\nBooking: ${qr.bookingCode}';

      case 'GroupBooking':
        final qr = result.groupBookingQR!;
        final version = qr.version;
        return '👥 QR nhóm (v$version): ${qr.groupName ?? "Nhóm"}\nBooking: ${qr.bookingCode}\nSố khách: ${qr.numberOfGuests}';

      case 'legacy':
      case 'plain':
      case 'minimal':
      case 'fallback':
      case 'bookingCodeOnly':
        return '📋 QR booking: ${result.legacyBookingCode}';

      case 'UltraCompactIndividual':
        return '🔸 QR cá nhân compact: ${result.legacyBookingCode ?? "N/A"}';

      case 'UltraCompactGroup':
        return '🔸 QR nhóm compact: ${result.legacyBookingCode ?? "N/A"}';

      case 'CompactBooking':
        return '🔹 QR booking compact: ${result.legacyBookingCode ?? "N/A"}';

      default:
        return '✅ QR code hợp lệ';
    }
  }

  /// Get QR type display name
  /// ENHANCED: Support all backend QR formats
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
      case 'minimal':
        return 'QR Tối giản';
      case 'fallback':
        return 'QR Dự phòng';
      case 'bookingCodeOnly':
        return 'QR Mã booking đơn';
      case 'UltraCompactIndividual':
        return 'QR Cá nhân siêu compact';
      case 'UltraCompactGroup':
        return 'QR Nhóm siêu compact';
      case 'CompactBooking':
        return 'QR Booking compact';
      default:
        return 'QR không xác định';
    }
  }

  /// Get QR format description for debugging
  static String getQRFormatDescription(String qrType) {
    switch (qrType) {
      case 'IndividualGuest':
        return 'Full format Individual Guest QR với đầy đủ thông tin khách hàng';
      case 'GroupBooking':
        return 'Full format Group Booking QR với thông tin nhóm đầy đủ';
      case 'UltraCompactIndividual':
        return 'Ultra-compact Individual QR v2.0 - chỉ thông tin thiết yếu (6-char IDs)';
      case 'UltraCompactGroup':
        return 'Ultra-compact Group QR v2.0 - chỉ thông tin thiết yếu (6-char IDs)';
      case 'minimal':
        return 'Minimal QR v1.0 - fallback khi ultra-compact quá dài (4-char IDs)';
      case 'CompactBooking':
        return 'Compact Booking QR v3.0 - legacy format với 8-char IDs';
      case 'fallback':
        return 'Fallback QR - được tạo khi generation chính thất bại';
      case 'bookingCodeOnly':
        return 'Booking Code Only QR - chỉ có mã booking';
      case 'legacy':
        return 'Legacy QR format - định dạng cũ';
      case 'plain':
        return 'Plain text QR - chỉ là booking code thuần';
      default:
        return 'Định dạng QR không xác định';
    }
  }
}