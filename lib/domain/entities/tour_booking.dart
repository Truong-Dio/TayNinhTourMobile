import 'package:equatable/equatable.dart';

/// Tour Booking entity
class TourBooking extends Equatable {
  final String id;
  final String bookingCode;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final int numberOfGuests;
  final double totalPrice;
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final String? checkInNotes;
  final String? qrCodeData;
  final String? customerName;
  final String? tourSlotDate; // ✅ NEW: From API response
  final String? tourSlotId;   // ✅ NEW: From API response

  const TourBooking({
    required this.id,
    required this.bookingCode,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.isCheckedIn,
    this.checkInTime,
    this.checkInNotes,
    this.qrCodeData,
    this.customerName,
    this.tourSlotDate,
    this.tourSlotId,
  });
  
  @override
  List<Object?> get props => [
    id,
    bookingCode,
    contactName,
    contactPhone,
    contactEmail,
    numberOfGuests,
    totalPrice,
    isCheckedIn,
    checkInTime,
    checkInNotes,
    qrCodeData,
    customerName,
    tourSlotDate,
    tourSlotId,
  ];
}
