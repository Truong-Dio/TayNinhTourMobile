// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourBookingModel _$TourBookingModelFromJson(Map<String, dynamic> json) =>
    TourBookingModel(
      id: json['id'] as String,
      bookingCode: json['bookingCode'] as String,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      numberOfGuests: (json['numberOfGuests'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      isCheckedIn: json['isCheckedIn'] as bool,
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkInNotes: json['checkInNotes'] as String?,
      qrCodeData: json['qrCodeData'] as String?,
      customerName: json['customerName'] as String?,
      tourSlotDate: json['tourSlotDate'] as String?,
      tourSlotId: json['tourSlotId'] as String?,
      bookingType: json['bookingType'] as String?,
    );

Map<String, dynamic> _$TourBookingModelToJson(TourBookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingCode': instance.bookingCode,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'numberOfGuests': instance.numberOfGuests,
      'totalPrice': instance.totalPrice,
      'isCheckedIn': instance.isCheckedIn,
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkInNotes': instance.checkInNotes,
      'qrCodeData': instance.qrCodeData,
      'customerName': instance.customerName,
      'tourSlotDate': instance.tourSlotDate,
      'tourSlotId': instance.tourSlotId,
      'bookingType': instance.bookingType,
    };
