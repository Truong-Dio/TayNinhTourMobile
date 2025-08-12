import 'package:json_annotation/json_annotation.dart';

part 'individual_qr_models.g.dart';

/// ✅ NEW: Individual Guest QR Code data model
@JsonSerializable()
class IndividualGuestQR {
  final String guestId;
  final String guestName;
  final String guestEmail;
  final String? guestPhone;
  final String bookingId;
  final String bookingCode;
  final String tourOperationId;
  final String tourSlotId;
  final double totalBookingPrice;
  final int numberOfGuests;
  final double originalPrice;
  final double discountPercent;
  final String tourTitle;
  final String tourDate;
  final bool isCheckedIn;
  final String? checkInTime;
  final String generatedAt;
  final String qrType;
  final String version;

  const IndividualGuestQR({
    required this.guestId,
    required this.guestName,
    required this.guestEmail,
    this.guestPhone,
    required this.bookingId,
    required this.bookingCode,
    required this.tourOperationId,
    required this.tourSlotId,
    required this.totalBookingPrice,
    required this.numberOfGuests,
    required this.originalPrice,
    required this.discountPercent,
    required this.tourTitle,
    required this.tourDate,
    required this.isCheckedIn,
    this.checkInTime,
    required this.generatedAt,
    required this.qrType,
    required this.version,
  });

  factory IndividualGuestQR.fromJson(Map<String, dynamic> json) => _$IndividualGuestQRFromJson(json);
  Map<String, dynamic> toJson() => _$IndividualGuestQRToJson(this);
}

/// ✅ NEW: Tour Booking Guest model (từ backend)
@JsonSerializable()
class TourBookingGuestModel {
  final String id;
  final String guestName;
  final String guestEmail;
  final String? guestPhone;
  final String? qrCodeData;
  final bool isCheckedIn;
  final String? checkInTime;
  final String? checkInNotes;
  final String? tourBookingId;
  final String? bookingCode;
  final String? bookingId;
  final String? customerName;
  final int? totalGuests;

  const TourBookingGuestModel({
    required this.id,
    required this.guestName,
    required this.guestEmail,
    this.guestPhone,
    this.qrCodeData,
    required this.isCheckedIn,
    this.checkInTime,
    this.checkInNotes,
    this.tourBookingId,
    this.bookingCode,
    this.bookingId,
    this.customerName,
    this.totalGuests,
  });

  factory TourBookingGuestModel.fromJson(Map<String, dynamic> json) => _$TourBookingGuestModelFromJson(json);
  Map<String, dynamic> toJson() => _$TourBookingGuestModelToJson(this);
}

/// ✅ NEW: QR Code validation result
class QRValidationResult {
  final bool isValid;
  final String qrType;
  final String? errorMessage;
  final IndividualGuestQR? individualGuestQR;
  final String? legacyBookingCode;

  const QRValidationResult({
    required this.isValid,
    required this.qrType,
    this.errorMessage,
    this.individualGuestQR,
    this.legacyBookingCode,
  });
}

/// ✅ NEW: Individual guest check-in request
@JsonSerializable()
class IndividualGuestCheckInRequest {
  final String guestId;
  final String tourSlotId;
  final String tourguideId;
  final String checkInTime;
  final String? notes;
  final String? checkInLocation;
  final String? qrCodeData;

  const IndividualGuestCheckInRequest({
    required this.guestId,
    required this.tourSlotId,
    required this.tourguideId,
    required this.checkInTime,
    this.notes,
    this.checkInLocation,
    this.qrCodeData,
  });

  factory IndividualGuestCheckInRequest.fromJson(Map<String, dynamic> json) => _$IndividualGuestCheckInRequestFromJson(json);
  Map<String, dynamic> toJson() => _$IndividualGuestCheckInRequestToJson(this);
}

/// ✅ NEW: Individual guest check-in response
@JsonSerializable()
class IndividualGuestCheckInResponse {
  final bool success;
  final String message;
  final TourBookingGuestModel? guestInfo;
  final String? checkInTime;

  const IndividualGuestCheckInResponse({
    required this.success,
    required this.message,
    this.guestInfo,
    this.checkInTime,
  });

  factory IndividualGuestCheckInResponse.fromJson(Map<String, dynamic> json) => _$IndividualGuestCheckInResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IndividualGuestCheckInResponseToJson(this);
}

/// ✅ NEW: Tour slot guests response
@JsonSerializable()
class TourSlotGuestsResponse {
  @JsonKey(name: 'tourSlotId')
  final String tourSlotId;
  
  @JsonKey(name: 'tourSlotDate')
  final String? tourSlotDate;
  
  @JsonKey(name: 'totalGuests')
  final int totalGuests;
  
  @JsonKey(name: 'checkedInGuests')
  final int checkedInGuests;
  
  @JsonKey(name: 'pendingGuests')
  final int pendingGuests;
  
  @JsonKey(name: 'guests')
  final List<TourBookingGuestModel> guests;

  const TourSlotGuestsResponse({
    required this.tourSlotId,
    this.tourSlotDate,
    required this.totalGuests,
    required this.checkedInGuests,
    required this.pendingGuests,
    required this.guests,
  });

  factory TourSlotGuestsResponse.fromJson(Map<String, dynamic> json) => _$TourSlotGuestsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourSlotGuestsResponseToJson(this);
}