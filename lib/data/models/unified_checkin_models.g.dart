// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_checkin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnifiedCheckInRequest _$UnifiedCheckInRequestFromJson(
        Map<String, dynamic> json) =>
    UnifiedCheckInRequest(
      qrCodeData: json['qrCodeData'] as String,
      tourSlotId: json['tourSlotId'] as String,
      notes: json['notes'] as String?,
      overrideTimeRestriction:
          json['overrideTimeRestriction'] as bool? ?? false,
      overrideReason: json['overrideReason'] as String?,
      allowPartialCheckIn: json['allowPartialCheckIn'] as bool? ?? true,
      specificGuestIds: (json['specificGuestIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UnifiedCheckInRequestToJson(
        UnifiedCheckInRequest instance) =>
    <String, dynamic>{
      'qrCodeData': instance.qrCodeData,
      'tourSlotId': instance.tourSlotId,
      'notes': instance.notes,
      'overrideTimeRestriction': instance.overrideTimeRestriction,
      'overrideReason': instance.overrideReason,
      'allowPartialCheckIn': instance.allowPartialCheckIn,
      'specificGuestIds': instance.specificGuestIds,
    };

UnifiedCheckInResponse _$UnifiedCheckInResponseFromJson(
        Map<String, dynamic> json) =>
    UnifiedCheckInResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String,
      success: json['success'] as bool,
      qrType: json['qrType'] as String,
      bookingCode: json['bookingCode'] as String?,
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkedInCount: (json['checkedInCount'] as num).toInt(),
      totalGuestCount: (json['totalGuestCount'] as num).toInt(),
      isCompleteCheckIn: json['isCompleteCheckIn'] as bool,
      individualGuest: json['individualGuest'] == null
          ? null
          : IndividualGuestInfo.fromJson(
              json['individualGuest'] as Map<String, dynamic>),
      groupInfo: json['groupInfo'] == null
          ? null
          : GroupCheckInInfo.fromJson(
              json['groupInfo'] as Map<String, dynamic>),
      checkedInGuests: (json['checkedInGuests'] as List<dynamic>)
          .map((e) => CheckedInGuestInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnifiedCheckInResponseToJson(
        UnifiedCheckInResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'success': instance.success,
      'qrType': instance.qrType,
      'bookingCode': instance.bookingCode,
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkedInCount': instance.checkedInCount,
      'totalGuestCount': instance.totalGuestCount,
      'isCompleteCheckIn': instance.isCompleteCheckIn,
      'individualGuest': instance.individualGuest,
      'groupInfo': instance.groupInfo,
      'checkedInGuests': instance.checkedInGuests,
    };

IndividualGuestInfo _$IndividualGuestInfoFromJson(Map<String, dynamic> json) =>
    IndividualGuestInfo(
      guestId: json['guestId'] as String,
      guestName: json['guestName'] as String,
      guestEmail: json['guestEmail'] as String?,
      guestPhone: json['guestPhone'] as String?,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkInNotes: json['checkInNotes'] as String?,
    );

Map<String, dynamic> _$IndividualGuestInfoToJson(
        IndividualGuestInfo instance) =>
    <String, dynamic>{
      'guestId': instance.guestId,
      'guestName': instance.guestName,
      'guestEmail': instance.guestEmail,
      'guestPhone': instance.guestPhone,
      'checkInTime': instance.checkInTime.toIso8601String(),
      'checkInNotes': instance.checkInNotes,
    };

GroupCheckInInfo _$GroupCheckInInfoFromJson(Map<String, dynamic> json) =>
    GroupCheckInInfo(
      bookingId: json['bookingId'] as String,
      bookingCode: json['bookingCode'] as String,
      groupName: json['groupName'] as String?,
      totalGuests: (json['totalGuests'] as num).toInt(),
      checkedInGuests: (json['checkedInGuests'] as num).toInt(),
      contactName: json['contactName'] as String?,
      contactEmail: json['contactEmail'] as String?,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      isPartialCheckIn: json['isPartialCheckIn'] as bool,
    );

Map<String, dynamic> _$GroupCheckInInfoToJson(GroupCheckInInfo instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'bookingCode': instance.bookingCode,
      'groupName': instance.groupName,
      'totalGuests': instance.totalGuests,
      'checkedInGuests': instance.checkedInGuests,
      'contactName': instance.contactName,
      'contactEmail': instance.contactEmail,
      'checkInTime': instance.checkInTime.toIso8601String(),
      'isPartialCheckIn': instance.isPartialCheckIn,
    };

CheckedInGuestInfo _$CheckedInGuestInfoFromJson(Map<String, dynamic> json) =>
    CheckedInGuestInfo(
      guestId: json['guestId'] as String,
      guestName: json['guestName'] as String,
      guestEmail: json['guestEmail'] as String?,
      isGroupRepresentative: json['isGroupRepresentative'] as bool,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkInNotes: json['checkInNotes'] as String?,
    );

Map<String, dynamic> _$CheckedInGuestInfoToJson(CheckedInGuestInfo instance) =>
    <String, dynamic>{
      'guestId': instance.guestId,
      'guestName': instance.guestName,
      'guestEmail': instance.guestEmail,
      'isGroupRepresentative': instance.isGroupRepresentative,
      'checkInTime': instance.checkInTime.toIso8601String(),
      'checkInNotes': instance.checkInNotes,
    };
