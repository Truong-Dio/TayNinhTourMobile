import 'package:equatable/equatable.dart';
import '../../data/models/user_tour_booking_model.dart';
import '../../core/constants/app_constants.dart';

class UserTourBooking extends Equatable {
  final String id;
  final String tourOperationId;
  final String? tourSlotId;
  final String userId;
  final int numberOfGuests;
  final double originalPrice;
  final double discountPercent;
  final double totalPrice;
  final String status;
  final String statusName;
  final String bookingCode;
  final String? payOsOrderCode;
  final String? qrCodeData;
  final DateTime bookingDate;
  final DateTime? confirmedDate;
  final DateTime? cancelledDate;
  final String? cancellationReason;
  final String? customerNotes;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String? specialRequests;
  final String bookingType;
  final String? groupName;
  final String? groupDescription;
  final String? groupQRCodeData;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<UserTourBookingGuestModel> guests;
  final UserTourOperationModel tourOperation;
  final UserBookingUserModel user;

  const UserTourBooking({
    required this.id,
    required this.tourOperationId,
    this.tourSlotId,
    required this.userId,
    required this.numberOfGuests,
    required this.originalPrice,
    required this.discountPercent,
    required this.totalPrice,
    required this.status,
    required this.statusName,
    required this.bookingCode,
    this.payOsOrderCode,
    this.qrCodeData,
    required this.bookingDate,
    this.confirmedDate,
    this.cancelledDate,
    this.cancellationReason,
    this.customerNotes,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    this.specialRequests,
    required this.bookingType,
    this.groupName,
    this.groupDescription,
    this.groupQRCodeData,
    required this.createdAt,
    this.updatedAt,
    required this.guests,
    required this.tourOperation,
    required this.user,
  });

  @override
  List<Object?> get props => [
        id,
        tourOperationId,
        tourSlotId,
        userId,
        numberOfGuests,
        originalPrice,
        discountPercent,
        totalPrice,
        status,
        statusName,
        bookingCode,
        payOsOrderCode,
        qrCodeData,
        bookingDate,
        confirmedDate,
        cancelledDate,
        cancellationReason,
        customerNotes,
        contactName,
        contactPhone,
        contactEmail,
        specialRequests,
        bookingType,
        groupName,
        groupDescription,
        groupQRCodeData,
        createdAt,
        updatedAt,
        guests,
        tourOperation,
        user,
      ];

  /// Get user-friendly tour status for UI
  String get userTourStatus {
    return AppConstants.bookingStatusMapping[status] ?? AppConstants.tourStatusUpcoming;
  }

  /// Check if tour is upcoming
  bool get isUpcoming {
    return userTourStatus == AppConstants.tourStatusUpcoming;
  }

  /// Check if tour is ongoing
  bool get isOngoing {
    return userTourStatus == AppConstants.tourStatusOngoing;
  }

  /// Check if tour is completed
  bool get isCompleted {
    return userTourStatus == AppConstants.tourStatusCompleted;
  }

  /// Check if tour is cancelled
  bool get isCancelled {
    return userTourStatus == AppConstants.tourStatusCancelled;
  }

  /// Check if tour can be cancelled by user
  bool get canBeCancelled {
    return isUpcoming && status == 'Confirmed';
  }

  /// Check if tour can be cancelled by user (alias for UI)
  bool get canCancel {
    return canBeCancelled;
  }

  /// Check if QR ticket can be resent
  bool get canResendQR {
    return isUpcoming || isOngoing;
  }

  /// Get formatted total price
  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }

  /// Check if tour can be rated/reviewed
  bool get canBeRated {
    return isCompleted;
  }

  /// Get check-in progress percentage
  double get checkInProgress {
    if (guests.isEmpty) return 0.0;
    final checkedInCount = guests.where((guest) => guest.isCheckedIn).length;
    return checkedInCount / guests.length;
  }

  /// Check if all guests are checked in
  bool get allGuestsCheckedIn {
    return guests.isNotEmpty && guests.every((guest) => guest.isCheckedIn);
  }

  /// Get days until tour starts
  int get daysUntilTour {
    final now = DateTime.now();
    final tourDate = tourOperation.tourStartDate;
    if (tourDate == null) return 0;
    return tourDate.difference(now).inDays;
  }

  /// Check if tour is starting soon (within 24 hours)
  bool get isStartingSoon {
    return daysUntilTour <= 1 && daysUntilTour >= 0;
  }

  /// Get formatted tour date
  String get formattedTourDate {
    final date = tourOperation.tourStartDate;
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get formatted tour time
  String get formattedTourTime {
    final date = tourOperation.tourStartDate;
    if (date == null) return 'N/A';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Copy with method for immutable updates
  UserTourBooking copyWith({
    String? id,
    String? tourOperationId,
    String? tourSlotId,
    String? userId,
    int? numberOfGuests,
    double? originalPrice,
    double? discountPercent,
    double? totalPrice,
    String? status,
    String? statusName,
    String? bookingCode,
    String? payOsOrderCode,
    String? qrCodeData,
    DateTime? bookingDate,
    DateTime? confirmedDate,
    DateTime? cancelledDate,
    String? cancellationReason,
    String? customerNotes,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? specialRequests,
    String? bookingType,
    String? groupName,
    String? groupDescription,
    String? groupQRCodeData,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserTourBookingGuestModel>? guests,
    UserTourOperationModel? tourOperation,
    UserBookingUserModel? user,
  }) {
    return UserTourBooking(
      id: id ?? this.id,
      tourOperationId: tourOperationId ?? this.tourOperationId,
      tourSlotId: tourSlotId ?? this.tourSlotId,
      userId: userId ?? this.userId,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      bookingCode: bookingCode ?? this.bookingCode,
      payOsOrderCode: payOsOrderCode ?? this.payOsOrderCode,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      bookingDate: bookingDate ?? this.bookingDate,
      confirmedDate: confirmedDate ?? this.confirmedDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      customerNotes: customerNotes ?? this.customerNotes,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      specialRequests: specialRequests ?? this.specialRequests,
      bookingType: bookingType ?? this.bookingType,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupQRCodeData: groupQRCodeData ?? this.groupQRCodeData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      guests: guests ?? this.guests,
      tourOperation: tourOperation ?? this.tourOperation,
      user: user ?? this.user,
    );
  }
}
