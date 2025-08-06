import 'package:equatable/equatable.dart';

/// Tour Booking entity
class TourBooking extends Equatable {
  final String id;
  final String bookingCode;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final int numberOfGuests;
  final int adultCount;
  final int childCount;
  final double totalPrice;
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final String? checkInNotes;
  final String? qrCodeData;
  final String? customerName;
  final String status;
  final DateTime bookingDate;
  
  const TourBooking({
    required this.id,
    required this.bookingCode,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    required this.numberOfGuests,
    required this.adultCount,
    required this.childCount,
    required this.totalPrice,
    required this.isCheckedIn,
    this.checkInTime,
    this.checkInNotes,
    this.qrCodeData,
    this.customerName,
    required this.status,
    required this.bookingDate,
  });
  
  @override
  List<Object?> get props => [
    id,
    bookingCode,
    contactName,
    contactPhone,
    contactEmail,
    numberOfGuests,
    adultCount,
    childCount,
    totalPrice,
    isCheckedIn,
    checkInTime,
    checkInNotes,
    qrCodeData,
    customerName,
    status,
    bookingDate,
  ];
}
