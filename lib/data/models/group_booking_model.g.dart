// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupBookingQR _$GroupBookingQRFromJson(Map<String, dynamic> json) =>
    GroupBookingQR(
      bookingId: json['bookingId'] as String,
      bookingCode: json['bookingCode'] as String,
      bookingType: json['bookingType'] as String,
      groupName: json['groupName'] as String?,
      groupDescription: json['groupDescription'] as String?,
      numberOfGuests: (json['numberOfGuests'] as num).toInt(),
      tourOperationId: json['tourOperationId'] as String,
      tourSlotId: json['tourSlotId'] as String?,
      tourTitle: json['tourTitle'] as String?,
      tourDate: json['tourDate'] as String?,
      contactName: json['contactName'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      qrType: json['qrType'] as String,
      version: json['version'] as String,
      generatedAt: json['generatedAt'] as String?,
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
      'qrType': instance.qrType,
      'version': instance.version,
      'generatedAt': instance.generatedAt,
    };
