// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_qr_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInGuestByQRRequest _$CheckInGuestByQRRequestFromJson(
        Map<String, dynamic> json) =>
    CheckInGuestByQRRequest(
      qrCodeData: json['qrCodeData'] as String,
      tourSlotId: json['tourSlotId'] as String,
      tourguideId: json['tourguideId'] as String,
      checkInTime: json['checkInTime'] as String,
      notes: json['notes'] as String?,
      overrideTime: json['overrideTime'] as bool?,
      overrideReason: json['overrideReason'] as String?,
    );

Map<String, dynamic> _$CheckInGuestByQRRequestToJson(
        CheckInGuestByQRRequest instance) =>
    <String, dynamic>{
      'qrCodeData': instance.qrCodeData,
      'tourSlotId': instance.tourSlotId,
      'tourguideId': instance.tourguideId,
      'checkInTime': instance.checkInTime,
      'notes': instance.notes,
      'overrideTime': instance.overrideTime,
      'overrideReason': instance.overrideReason,
    };

CheckInGroupByQRRequest _$CheckInGroupByQRRequestFromJson(
        Map<String, dynamic> json) =>
    CheckInGroupByQRRequest(
      qrCodeData: json['QrCodeData'] as String,
      tourGuideId: json['TourGuideId'] as String?,
      checkInNotes: json['CheckInNotes'] as String?,
      specificGuestIds: (json['SpecificGuestIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allowPartialCheckIn: json['AllowPartialCheckIn'] as bool? ?? true,
    );

Map<String, dynamic> _$CheckInGroupByQRRequestToJson(
        CheckInGroupByQRRequest instance) =>
    <String, dynamic>{
      'QrCodeData': instance.qrCodeData,
      'TourGuideId': instance.tourGuideId,
      'CheckInNotes': instance.checkInNotes,
      'SpecificGuestIds': instance.specificGuestIds,
      'AllowPartialCheckIn': instance.allowPartialCheckIn,
    };

IndividualGuestQR _$IndividualGuestQRFromJson(Map<String, dynamic> json) =>
    IndividualGuestQR(
      guestId: json['guestId'] as String,
      guestName: json['guestName'] as String,
      guestEmail: json['guestEmail'] as String,
      guestPhone: json['guestPhone'] as String?,
      bookingId: json['bookingId'] as String,
      bookingCode: json['bookingCode'] as String,
      tourOperationId: json['tourOperationId'] as String,
      tourSlotId: json['tourSlotId'] as String,
      totalBookingPrice: (json['totalBookingPrice'] as num).toDouble(),
      numberOfGuests: (json['numberOfGuests'] as num).toInt(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num).toDouble(),
      tourTitle: json['tourTitle'] as String,
      tourDate: json['tourDate'] as String,
      isCheckedIn: json['isCheckedIn'] as bool,
      checkInTime: json['checkInTime'] as String?,
      generatedAt: json['generatedAt'] as String,
      qrType: json['qrType'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$IndividualGuestQRToJson(IndividualGuestQR instance) =>
    <String, dynamic>{
      'guestId': instance.guestId,
      'guestName': instance.guestName,
      'guestEmail': instance.guestEmail,
      'guestPhone': instance.guestPhone,
      'bookingId': instance.bookingId,
      'bookingCode': instance.bookingCode,
      'tourOperationId': instance.tourOperationId,
      'tourSlotId': instance.tourSlotId,
      'totalBookingPrice': instance.totalBookingPrice,
      'numberOfGuests': instance.numberOfGuests,
      'originalPrice': instance.originalPrice,
      'discountPercent': instance.discountPercent,
      'tourTitle': instance.tourTitle,
      'tourDate': instance.tourDate,
      'isCheckedIn': instance.isCheckedIn,
      'checkInTime': instance.checkInTime,
      'generatedAt': instance.generatedAt,
      'qrType': instance.qrType,
      'version': instance.version,
    };

TourBookingGuestModel _$TourBookingGuestModelFromJson(
        Map<String, dynamic> json) =>
    TourBookingGuestModel(
      id: json['id'] as String,
      guestName: json['guestName'] as String,
      guestEmail: json['guestEmail'] as String,
      guestPhone: json['guestPhone'] as String?,
      qrCodeData: json['qrCodeData'] as String?,
      isCheckedIn: json['isCheckedIn'] as bool,
      checkInTime: json['checkInTime'] as String?,
      checkInNotes: json['checkInNotes'] as String?,
      tourBookingId: json['tourBookingId'] as String?,
      bookingCode: json['bookingCode'] as String?,
      bookingId: json['bookingId'] as String?,
      customerName: json['customerName'] as String?,
      totalGuests: (json['totalGuests'] as num?)?.toInt(),
      isGroupRepresentative: json['isGroupRepresentative'] as bool?,
    );

Map<String, dynamic> _$TourBookingGuestModelToJson(
        TourBookingGuestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guestName': instance.guestName,
      'guestEmail': instance.guestEmail,
      'guestPhone': instance.guestPhone,
      'qrCodeData': instance.qrCodeData,
      'isCheckedIn': instance.isCheckedIn,
      'checkInTime': instance.checkInTime,
      'checkInNotes': instance.checkInNotes,
      'tourBookingId': instance.tourBookingId,
      'bookingCode': instance.bookingCode,
      'bookingId': instance.bookingId,
      'customerName': instance.customerName,
      'totalGuests': instance.totalGuests,
      'isGroupRepresentative': instance.isGroupRepresentative,
    };

GroupBookingQR _$GroupBookingQRFromJson(Map<String, dynamic> json) =>
    GroupBookingQR(
      bookingId: json['bookingId'] as String,
      bookingCode: json['bookingCode'] as String,
      bookingType: json['bookingType'] as String,
      groupName: json['groupName'] as String?,
      groupDescription: json['groupDescription'] as String?,
      numberOfGuests: (json['numberOfGuests'] as num).toInt(),
      tourOperationId: json['tourOperationId'] as String?,
      tourSlotId: json['tourSlotId'] as String?,
      tourTitle: json['tourTitle'] as String?,
      tourDate: json['tourDate'] as String,
      contactName: json['contactName'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num).toDouble(),
      generatedAt: json['generatedAt'] as String,
      qrType: json['qrType'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$GroupBookingQRToJson(GroupBookingQR instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'bookingCode': instance.bookingCode,
      'bookingType': instance.bookingType,
      'groupName': instance.groupName,
      'groupDescription': instance.groupDescription,
      'numberOfGuests': instance.numberOfGuests,
      'tourOperationId': instance.tourOperationId,
      'tourSlotId': instance.tourSlotId,
      'tourTitle': instance.tourTitle,
      'tourDate': instance.tourDate,
      'contactName': instance.contactName,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'totalPrice': instance.totalPrice,
      'originalPrice': instance.originalPrice,
      'discountPercent': instance.discountPercent,
      'generatedAt': instance.generatedAt,
      'qrType': instance.qrType,
      'version': instance.version,
    };

IndividualGuestCheckInRequest _$IndividualGuestCheckInRequestFromJson(
        Map<String, dynamic> json) =>
    IndividualGuestCheckInRequest(
      guestId: json['guestId'] as String,
      tourSlotId: json['tourSlotId'] as String,
      tourguideId: json['tourguideId'] as String,
      checkInTime: json['checkInTime'] as String,
      notes: json['notes'] as String?,
      checkInLocation: json['checkInLocation'] as String?,
      qrCodeData: json['qrCodeData'] as String?,
    );

Map<String, dynamic> _$IndividualGuestCheckInRequestToJson(
        IndividualGuestCheckInRequest instance) =>
    <String, dynamic>{
      'guestId': instance.guestId,
      'tourSlotId': instance.tourSlotId,
      'tourguideId': instance.tourguideId,
      'checkInTime': instance.checkInTime,
      'notes': instance.notes,
      'checkInLocation': instance.checkInLocation,
      'qrCodeData': instance.qrCodeData,
    };

IndividualGuestCheckInResponse _$IndividualGuestCheckInResponseFromJson(
        Map<String, dynamic> json) =>
    IndividualGuestCheckInResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      guestInfo: json['guestInfo'] == null
          ? null
          : TourBookingGuestModel.fromJson(
              json['guestInfo'] as Map<String, dynamic>),
      checkInTime: json['checkInTime'] as String?,
    );

Map<String, dynamic> _$IndividualGuestCheckInResponseToJson(
        IndividualGuestCheckInResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'guestInfo': instance.guestInfo,
      'checkInTime': instance.checkInTime,
    };

GroupCheckInResponse _$GroupCheckInResponseFromJson(
        Map<String, dynamic> json) =>
    GroupCheckInResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      bookingId: json['bookingId'] as String?,
      bookingCode: json['bookingCode'] as String?,
      groupName: json['groupName'] as String?,
      numberOfGuests: (json['numberOfGuests'] as num?)?.toInt(),
      checkedInGuests: (json['checkedInGuests'] as num?)?.toInt(),
      checkInTime: json['checkInTime'] as String?,
      guests: (json['guests'] as List<dynamic>?)
          ?.map(
              (e) => TourBookingGuestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupCheckInResponseToJson(
        GroupCheckInResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'bookingId': instance.bookingId,
      'bookingCode': instance.bookingCode,
      'groupName': instance.groupName,
      'numberOfGuests': instance.numberOfGuests,
      'checkedInGuests': instance.checkedInGuests,
      'checkInTime': instance.checkInTime,
      'guests': instance.guests,
    };

TourSlotGuestsResponse _$TourSlotGuestsResponseFromJson(
        Map<String, dynamic> json) =>
    TourSlotGuestsResponse(
      tourSlotId: json['tourSlotId'] as String,
      tourSlotDate: json['tourSlotDate'] as String?,
      totalGuests: (json['totalGuests'] as num).toInt(),
      checkedInGuests: (json['checkedInGuests'] as num).toInt(),
      pendingGuests: (json['pendingGuests'] as num).toInt(),
      guests: (json['guests'] as List<dynamic>)
          .map((e) => TourBookingGuestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TourSlotGuestsResponseToJson(
        TourSlotGuestsResponse instance) =>
    <String, dynamic>{
      'tourSlotId': instance.tourSlotId,
      'tourSlotDate': instance.tourSlotDate,
      'totalGuests': instance.totalGuests,
      'checkedInGuests': instance.checkedInGuests,
      'pendingGuests': instance.pendingGuests,
      'guests': instance.guests,
    };
