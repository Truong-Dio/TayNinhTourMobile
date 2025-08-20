import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_tour_booking.dart';

part 'user_tour_booking_model.g.dart';

@JsonSerializable()
class UserTourBookingModel extends UserTourBooking {
  const UserTourBookingModel({
    required super.id,
    required super.tourOperationId,
    required super.userId,
    required super.numberOfGuests,
    required super.originalPrice,
    required super.discountPercent,
    required super.totalPrice,
    required super.status,
    required super.statusName,
    required super.bookingCode,
    super.payOsOrderCode,
    super.qrCodeData,
    required super.bookingDate,
    super.confirmedDate,
    super.cancelledDate,
    super.cancellationReason,
    super.customerNotes,
    required super.contactName,
    required super.contactPhone,
    required super.contactEmail,
    super.specialRequests,
    required super.bookingType,
    super.groupName,
    super.groupDescription,
    super.groupQRCodeData,
    required super.createdAt,
    super.updatedAt,
    required super.guests,
    required super.tourOperation,
    required super.user,
  });

  factory UserTourBookingModel.fromJson(Map<String, dynamic> json) => 
      _$UserTourBookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserTourBookingModelToJson(this);

  factory UserTourBookingModel.fromEntity(UserTourBooking booking) {
    return UserTourBookingModel(
      id: booking.id,
      tourOperationId: booking.tourOperationId,
      userId: booking.userId,
      numberOfGuests: booking.numberOfGuests,
      originalPrice: booking.originalPrice,
      discountPercent: booking.discountPercent,
      totalPrice: booking.totalPrice,
      status: booking.status,
      statusName: booking.statusName,
      bookingCode: booking.bookingCode,
      payOsOrderCode: booking.payOsOrderCode,
      qrCodeData: booking.qrCodeData,
      bookingDate: booking.bookingDate,
      confirmedDate: booking.confirmedDate,
      cancelledDate: booking.cancelledDate,
      cancellationReason: booking.cancellationReason,
      customerNotes: booking.customerNotes,
      contactName: booking.contactName,
      contactPhone: booking.contactPhone,
      contactEmail: booking.contactEmail,
      specialRequests: booking.specialRequests,
      bookingType: booking.bookingType,
      groupName: booking.groupName,
      groupDescription: booking.groupDescription,
      groupQRCodeData: booking.groupQRCodeData,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
      guests: booking.guests,
      tourOperation: booking.tourOperation,
      user: booking.user,
    );
  }

  UserTourBooking toEntity() {
    return UserTourBooking(
      id: id,
      tourOperationId: tourOperationId,
      userId: userId,
      numberOfGuests: numberOfGuests,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      totalPrice: totalPrice,
      status: status,
      statusName: statusName,
      bookingCode: bookingCode,
      payOsOrderCode: payOsOrderCode,
      qrCodeData: qrCodeData,
      bookingDate: bookingDate,
      confirmedDate: confirmedDate,
      cancelledDate: cancelledDate,
      cancellationReason: cancellationReason,
      customerNotes: customerNotes,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      specialRequests: specialRequests,
      bookingType: bookingType,
      groupName: groupName,
      groupDescription: groupDescription,
      groupQRCodeData: groupQRCodeData,
      createdAt: createdAt,
      updatedAt: updatedAt,
      guests: guests,
      tourOperation: tourOperation,
      user: user,
    );
  }
}

@JsonSerializable()
class UserTourBookingGuestModel {
  final String id;
  final String tourBookingId;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final bool isGroupRepresentative;
  final String? qrCodeData;
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final String? checkInNotes;
  final DateTime createdAt;

  const UserTourBookingGuestModel({
    required this.id,
    required this.tourBookingId,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.isGroupRepresentative,
    this.qrCodeData,
    required this.isCheckedIn,
    this.checkInTime,
    this.checkInNotes,
    required this.createdAt,
  });

  factory UserTourBookingGuestModel.fromJson(Map<String, dynamic> json) => 
      _$UserTourBookingGuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserTourBookingGuestModelToJson(this);
}

@JsonSerializable()
class UserTourOperationModel {
  final String id;
  final String tourDetailsId;
  final String tourTitle;
  final double price;
  final int maxGuests;
  final int currentBookings;
  final int availableSpots;
  final DateTime tourStartDate;
  final String? guideId;
  final String? guideName;
  final String? guidePhone;

  const UserTourOperationModel({
    required this.id,
    required this.tourDetailsId,
    required this.tourTitle,
    required this.price,
    required this.maxGuests,
    required this.currentBookings,
    required this.availableSpots,
    required this.tourStartDate,
    this.guideId,
    this.guideName,
    this.guidePhone,
  });

  factory UserTourOperationModel.fromJson(Map<String, dynamic> json) => 
      _$UserTourOperationModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserTourOperationModelToJson(this);
}

@JsonSerializable()
class UserBookingUserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  const UserBookingUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory UserBookingUserModel.fromJson(Map<String, dynamic> json) => 
      _$UserBookingUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserBookingUserModelToJson(this);
}

@JsonSerializable()
class UserBookingsResponse {
  final bool success;
  final String message;
  final UserBookingsData data;
  final String? note;

  const UserBookingsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.note,
  });

  factory UserBookingsResponse.fromJson(Map<String, dynamic> json) => 
      _$UserBookingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserBookingsResponseToJson(this);
}

@JsonSerializable()
class UserBookingsData {
  final List<UserTourBookingModel> items;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const UserBookingsData({
    required this.items,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory UserBookingsData.fromJson(Map<String, dynamic> json) =>
      _$UserBookingsDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBookingsDataToJson(this);
}

// Dashboard Summary Models
@JsonSerializable()
class UserDashboardSummaryModel {
  final int totalBookings;
  final int upcomingTours;
  final int ongoingTours;
  final int completedTours;
  final int cancelledTours;
  final int pendingFeedbacks;
  final List<UserTourBookingModel> recentBookings;
  final List<UserTourBookingModel> upcomingBookings;

  const UserDashboardSummaryModel({
    required this.totalBookings,
    required this.upcomingTours,
    required this.ongoingTours,
    required this.completedTours,
    required this.cancelledTours,
    required this.pendingFeedbacks,
    required this.recentBookings,
    required this.upcomingBookings,
  });

  factory UserDashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$UserDashboardSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDashboardSummaryModelToJson(this);
}

@JsonSerializable()
class UserDashboardResponse {
  final bool success;
  final String message;
  final UserDashboardSummaryModel data;

  const UserDashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserDashboardResponseToJson(this);
}

// Tour Progress Models
@JsonSerializable()
class UserTourProgressModel {
  final String tourOperationId;
  final String tourTitle;
  final DateTime tourStartDate;
  final String? guideName;
  final String? guidePhone;
  final List<TourTimelineProgressItemModel> timeline;
  final TourProgressStatsModel stats;
  final String currentStatus;
  final String? currentLocation;
  final DateTime? estimatedCompletion;

  const UserTourProgressModel({
    required this.tourOperationId,
    required this.tourTitle,
    required this.tourStartDate,
    this.guideName,
    this.guidePhone,
    required this.timeline,
    required this.stats,
    required this.currentStatus,
    this.currentLocation,
    this.estimatedCompletion,
  });

  factory UserTourProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserTourProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserTourProgressModelToJson(this);
}

@JsonSerializable()
class TourTimelineProgressItemModel {
  final String id;
  final String checkInTime;
  final String activity;
  final String? specialtyShopId;
  final String? specialtyShopName;
  final int sortOrder;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isActive;

  const TourTimelineProgressItemModel({
    required this.id,
    required this.checkInTime,
    required this.activity,
    this.specialtyShopId,
    this.specialtyShopName,
    required this.sortOrder,
    required this.isCompleted,
    this.completedAt,
    required this.isActive,
  });

  factory TourTimelineProgressItemModel.fromJson(Map<String, dynamic> json) =>
      _$TourTimelineProgressItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourTimelineProgressItemModelToJson(this);
}

@JsonSerializable()
class TourProgressStatsModel {
  final int totalItems;
  final int completedItems;
  final double progressPercentage;
  final int totalGuests;
  final int checkedInGuests;
  final double checkInPercentage;

  const TourProgressStatsModel({
    required this.totalItems,
    required this.completedItems,
    required this.progressPercentage,
    required this.totalGuests,
    required this.checkedInGuests,
    required this.checkInPercentage,
  });

  factory TourProgressStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TourProgressStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourProgressStatsModelToJson(this);
}

@JsonSerializable()
class UserTourProgressResponse {
  final bool success;
  final String message;
  final UserTourProgressModel data;

  const UserTourProgressResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserTourProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$UserTourProgressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserTourProgressResponseToJson(this);
}

// Resend QR Ticket Models
@JsonSerializable()
class ResendQRTicketResultModel {
  final bool success;
  final String message;
  final DateTime? sentAt;
  final String? email;

  const ResendQRTicketResultModel({
    required this.success,
    required this.message,
    this.sentAt,
    this.email,
  });

  factory ResendQRTicketResultModel.fromJson(Map<String, dynamic> json) =>
      _$ResendQRTicketResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResendQRTicketResultModelToJson(this);
}
