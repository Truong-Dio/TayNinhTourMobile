import 'package:json_annotation/json_annotation.dart';

part 'individual_qr_models.g.dart';

/// ✅ NEW: Request model for QR check-in
@JsonSerializable()
class CheckInGuestByQRRequest {
  final String qrCodeData;
  final String tourSlotId;
  final String tourguideId;
  final String checkInTime;
  final String? notes;
  final bool? overrideTime;
  final String? overrideReason;

  const CheckInGuestByQRRequest({
    required this.qrCodeData,
    required this.tourSlotId,
    required this.tourguideId,
    required this.checkInTime,
    this.notes,
    this.overrideTime,
    this.overrideReason,
  });

  factory CheckInGuestByQRRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckInGuestByQRRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInGuestByQRRequestToJson(this);
}

/// ✅ NEW: Request model for Group QR check-in (matches backend CheckInGroupRequest)
@JsonSerializable()
class CheckInGroupByQRRequest {
  @JsonKey(name: 'QrCodeData')
  final String qrCodeData;
  @JsonKey(name: 'TourGuideId')
  final String? tourGuideId;
  @JsonKey(name: 'CheckInNotes')
  final String? checkInNotes;
  @JsonKey(name: 'SpecificGuestIds')
  final List<String>? specificGuestIds;
  @JsonKey(name: 'AllowPartialCheckIn')
  final bool allowPartialCheckIn;

  const CheckInGroupByQRRequest({
    required this.qrCodeData,
    this.tourGuideId,
    this.checkInNotes,
    this.specificGuestIds,
    this.allowPartialCheckIn = true,
  });

  factory CheckInGroupByQRRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckInGroupByQRRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInGroupByQRRequestToJson(this);
}

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

/// ✅ NEW: Group Booking QR Code data model
@JsonSerializable()
class GroupBookingQR {
  final String bookingId;
  final String bookingCode;
  final String bookingType;
  final String? groupName;
  final String? groupDescription;
  final int numberOfGuests;
  final String? tourOperationId;
  final String? tourSlotId;
  final String? tourTitle;
  final String tourDate;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final double totalPrice;
  final double originalPrice;
  final double discountPercent;
  final String generatedAt;
  final String qrType;
  final String version;

  const GroupBookingQR({
    required this.bookingId,
    required this.bookingCode,
    required this.bookingType,
    this.groupName,
    this.groupDescription,
    required this.numberOfGuests,
    this.tourOperationId,
    this.tourSlotId,
    this.tourTitle,
    required this.tourDate,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    required this.totalPrice,
    required this.originalPrice,
    required this.discountPercent,
    required this.generatedAt,
    required this.qrType,
    required this.version,
  });

  factory GroupBookingQR.fromJson(Map<String, dynamic> json) => _$GroupBookingQRFromJson(json);
  Map<String, dynamic> toJson() => _$GroupBookingQRToJson(this);
}

/// ✅ NEW: QR Code validation result
class QRValidationResult {
  final bool isValid;
  final String qrType;
  final String? errorMessage;
  final IndividualGuestQR? individualGuestQR;
  final GroupBookingQR? groupBookingQR;
  final String? legacyBookingCode;

  const QRValidationResult({
    required this.isValid,
    required this.qrType,
    this.errorMessage,
    this.individualGuestQR,
    this.groupBookingQR,
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
  @JsonKey(defaultValue: true)
  final bool success;
  
  @JsonKey(defaultValue: '')
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

/// ✅ NEW: Group check-in response
@JsonSerializable()
class GroupCheckInResponse {
  @JsonKey(defaultValue: true)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final String? bookingId;
  final String? bookingCode;
  final String? groupName;
  final int? numberOfGuests;
  final int? checkedInGuests;
  final String? checkInTime;
  final List<TourBookingGuestModel>? guests;

  const GroupCheckInResponse({
    required this.success,
    required this.message,
    this.bookingId,
    this.bookingCode,
    this.groupName,
    this.numberOfGuests,
    this.checkedInGuests,
    this.checkInTime,
    this.guests,
  });

  factory GroupCheckInResponse.fromJson(Map<String, dynamic> json) => _$GroupCheckInResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupCheckInResponseToJson(this);
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