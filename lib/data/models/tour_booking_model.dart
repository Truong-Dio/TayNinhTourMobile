import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tour_booking.dart';

part 'tour_booking_model.g.dart';

@JsonSerializable()
class TourBookingModel extends TourBooking {
  const TourBookingModel({
    required super.id,
    required super.bookingCode,
    super.contactName,
    super.contactPhone,
    super.contactEmail,
    required super.numberOfGuests,
    required super.totalPrice,
    required super.isCheckedIn,
    super.checkInTime,
    super.checkInNotes,
    super.qrCodeData,
    super.customerName,
    super.tourSlotDate,
    super.tourSlotId,
  });
  
  factory TourBookingModel.fromJson(Map<String, dynamic> json) => _$TourBookingModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TourBookingModelToJson(this);
  
  TourBooking toEntity() {
    return TourBooking(
      id: id,
      bookingCode: bookingCode,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      numberOfGuests: numberOfGuests,
      totalPrice: totalPrice,
      isCheckedIn: isCheckedIn,
      checkInTime: checkInTime,
      checkInNotes: checkInNotes,
      qrCodeData: qrCodeData,
      customerName: customerName,
      tourSlotDate: tourSlotDate,
      tourSlotId: tourSlotId,
    );
  }
}
