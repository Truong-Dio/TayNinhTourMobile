import 'package:json_annotation/json_annotation.dart';

part 'group_booking_model.g.dart';

/// Model for Group Booking QR Code data
@JsonSerializable()
class GroupBookingQR {
  final String bookingId;
  final String bookingCode;
  final String bookingType;
  final String? groupName;
  final String? groupDescription;
  final int numberOfGuests;
  final String tourOperationId;
  final String? tourSlotId;
  final String? tourTitle;
  final String? tourDate;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final double totalPrice;
  final double? originalPrice;
  final double? discountPercent;
  final String qrType;
  final String version;
  final String? generatedAt;

  const GroupBookingQR({
    required this.bookingId,
    required this.bookingCode,
    required this.bookingType,
    this.groupName,
    this.groupDescription,
    required this.numberOfGuests,
    required this.tourOperationId,
    this.tourSlotId,
    this.tourTitle,
    this.tourDate,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    required this.totalPrice,
    this.originalPrice,
    this.discountPercent,
    required this.qrType,
    required this.version,
    this.generatedAt,
  });

  factory GroupBookingQR.fromJson(Map<String, dynamic> json) => _$GroupBookingQRFromJson(json);
  Map<String, dynamic> toJson() => _$GroupBookingQRToJson(this);
}