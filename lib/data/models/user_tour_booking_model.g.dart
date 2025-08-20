// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_tour_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTourBookingModel _$UserTourBookingModelFromJson(
        Map<String, dynamic> json) =>
    UserTourBookingModel(
      id: json['id'] as String,
      tourOperationId: json['tourOperationId'] as String,
      userId: json['userId'] as String,
      numberOfGuests: (json['numberOfGuests'] as num).toInt(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      statusName: json['statusName'] as String,
      bookingCode: json['bookingCode'] as String,
      payOsOrderCode: json['payOsOrderCode'] as String?,
      qrCodeData: json['qrCodeData'] as String?,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      confirmedDate: json['confirmedDate'] == null
          ? null
          : DateTime.parse(json['confirmedDate'] as String),
      cancelledDate: json['cancelledDate'] == null
          ? null
          : DateTime.parse(json['cancelledDate'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      customerNotes: json['customerNotes'] as String?,
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String,
      specialRequests: json['specialRequests'] as String?,
      bookingType: json['bookingType'] as String,
      groupName: json['groupName'] as String?,
      groupDescription: json['groupDescription'] as String?,
      groupQRCodeData: json['groupQRCodeData'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      guests: (json['guests'] as List<dynamic>)
          .map((e) =>
              UserTourBookingGuestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tourOperation: UserTourOperationModel.fromJson(
          json['tourOperation'] as Map<String, dynamic>),
      user: UserBookingUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserTourBookingModelToJson(
        UserTourBookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourOperationId': instance.tourOperationId,
      'userId': instance.userId,
      'numberOfGuests': instance.numberOfGuests,
      'originalPrice': instance.originalPrice,
      'discountPercent': instance.discountPercent,
      'totalPrice': instance.totalPrice,
      'status': instance.status,
      'statusName': instance.statusName,
      'bookingCode': instance.bookingCode,
      'payOsOrderCode': instance.payOsOrderCode,
      'qrCodeData': instance.qrCodeData,
      'bookingDate': instance.bookingDate.toIso8601String(),
      'confirmedDate': instance.confirmedDate?.toIso8601String(),
      'cancelledDate': instance.cancelledDate?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'customerNotes': instance.customerNotes,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'specialRequests': instance.specialRequests,
      'bookingType': instance.bookingType,
      'groupName': instance.groupName,
      'groupDescription': instance.groupDescription,
      'groupQRCodeData': instance.groupQRCodeData,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'guests': instance.guests,
      'tourOperation': instance.tourOperation,
      'user': instance.user,
    };

UserTourBookingGuestModel _$UserTourBookingGuestModelFromJson(
        Map<String, dynamic> json) =>
    UserTourBookingGuestModel(
      id: json['id'] as String,
      tourBookingId: json['tourBookingId'] as String,
      guestName: json['guestName'] as String?,
      guestEmail: json['guestEmail'] as String?,
      guestPhone: json['guestPhone'] as String?,
      isGroupRepresentative: json['isGroupRepresentative'] as bool,
      qrCodeData: json['qrCodeData'] as String?,
      isCheckedIn: json['isCheckedIn'] as bool,
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkInNotes: json['checkInNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserTourBookingGuestModelToJson(
        UserTourBookingGuestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourBookingId': instance.tourBookingId,
      'guestName': instance.guestName,
      'guestEmail': instance.guestEmail,
      'guestPhone': instance.guestPhone,
      'isGroupRepresentative': instance.isGroupRepresentative,
      'qrCodeData': instance.qrCodeData,
      'isCheckedIn': instance.isCheckedIn,
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkInNotes': instance.checkInNotes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

UserTourOperationModel _$UserTourOperationModelFromJson(
        Map<String, dynamic> json) =>
    UserTourOperationModel(
      id: json['id'] as String,
      tourDetailsId: json['tourDetailsId'] as String,
      tourTitle: json['tourTitle'] as String?,
      price: (json['price'] as num).toDouble(),
      maxGuests: (json['maxGuests'] as num).toInt(),
      currentBookings: (json['currentBookings'] as num).toInt(),
      availableSpots: (json['availableSpots'] as num).toInt(),
      tourStartDate: json['tourStartDate'] == null
          ? null
          : DateTime.parse(json['tourStartDate'] as String),
      guideId: json['guideId'] as String?,
      guideName: json['guideName'] as String?,
      guidePhone: json['guidePhone'] as String?,
    );

Map<String, dynamic> _$UserTourOperationModelToJson(
        UserTourOperationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourDetailsId': instance.tourDetailsId,
      'tourTitle': instance.tourTitle,
      'price': instance.price,
      'maxGuests': instance.maxGuests,
      'currentBookings': instance.currentBookings,
      'availableSpots': instance.availableSpots,
      'tourStartDate': instance.tourStartDate?.toIso8601String(),
      'guideId': instance.guideId,
      'guideName': instance.guideName,
      'guidePhone': instance.guidePhone,
    };

UserBookingUserModel _$UserBookingUserModelFromJson(
        Map<String, dynamic> json) =>
    UserBookingUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$UserBookingUserModelToJson(
        UserBookingUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
    };

UserBookingsResponse _$UserBookingsResponseFromJson(
        Map<String, dynamic> json) =>
    UserBookingsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserBookingsData.fromJson(json['data'] as Map<String, dynamic>),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$UserBookingsResponseToJson(
        UserBookingsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'note': instance.note,
    };

UserBookingsData _$UserBookingsDataFromJson(Map<String, dynamic> json) =>
    UserBookingsData(
      items: (json['items'] as List<dynamic>)
          .map((e) => UserTourBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      pageIndex: (json['pageIndex'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$UserBookingsDataToJson(UserBookingsData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'pageIndex': instance.pageIndex,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };

UserDashboardSummaryModel _$UserDashboardSummaryModelFromJson(
        Map<String, dynamic> json) =>
    UserDashboardSummaryModel(
      totalBookings: (json['totalBookings'] as num).toInt(),
      upcomingTours: (json['upcomingTours'] as num).toInt(),
      ongoingTours: (json['ongoingTours'] as num).toInt(),
      completedTours: (json['completedTours'] as num).toInt(),
      cancelledTours: (json['cancelledTours'] as num).toInt(),
      pendingFeedbacks: (json['pendingFeedbacks'] as num).toInt(),
      recentBookings: (json['recentBookings'] as List<dynamic>)
          .map((e) => UserTourBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingBookings: (json['upcomingBookings'] as List<dynamic>)
          .map((e) => UserTourBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserDashboardSummaryModelToJson(
        UserDashboardSummaryModel instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'upcomingTours': instance.upcomingTours,
      'ongoingTours': instance.ongoingTours,
      'completedTours': instance.completedTours,
      'cancelledTours': instance.cancelledTours,
      'pendingFeedbacks': instance.pendingFeedbacks,
      'recentBookings': instance.recentBookings,
      'upcomingBookings': instance.upcomingBookings,
    };

UserDashboardResponse _$UserDashboardResponseFromJson(
        Map<String, dynamic> json) =>
    UserDashboardResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserDashboardSummaryModel.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserDashboardResponseToJson(
        UserDashboardResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

UserTourProgressModel _$UserTourProgressModelFromJson(
        Map<String, dynamic> json) =>
    UserTourProgressModel(
      tourOperationId: json['tourOperationId'] as String,
      tourTitle: json['tourTitle'] as String,
      tourStartDate: DateTime.parse(json['tourStartDate'] as String),
      guideName: json['guideName'] as String?,
      guidePhone: json['guidePhone'] as String?,
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) =>
              TourTimelineProgressItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: TourProgressStatsModel.fromJson(
          json['stats'] as Map<String, dynamic>),
      currentStatus: json['currentStatus'] as String,
      currentLocation: json['currentLocation'] as String?,
      estimatedCompletion: json['estimatedCompletion'] == null
          ? null
          : DateTime.parse(json['estimatedCompletion'] as String),
    );

Map<String, dynamic> _$UserTourProgressModelToJson(
        UserTourProgressModel instance) =>
    <String, dynamic>{
      'tourOperationId': instance.tourOperationId,
      'tourTitle': instance.tourTitle,
      'tourStartDate': instance.tourStartDate.toIso8601String(),
      'guideName': instance.guideName,
      'guidePhone': instance.guidePhone,
      'timeline': instance.timeline,
      'stats': instance.stats,
      'currentStatus': instance.currentStatus,
      'currentLocation': instance.currentLocation,
      'estimatedCompletion': instance.estimatedCompletion?.toIso8601String(),
    };

TourTimelineProgressItemModel _$TourTimelineProgressItemModelFromJson(
        Map<String, dynamic> json) =>
    TourTimelineProgressItemModel(
      id: json['id'] as String,
      checkInTime: json['checkInTime'] as String,
      activity: json['activity'] as String,
      specialtyShopId: json['specialtyShopId'] as String?,
      specialtyShopName: json['specialtyShopName'] as String?,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$TourTimelineProgressItemModelToJson(
        TourTimelineProgressItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checkInTime': instance.checkInTime,
      'activity': instance.activity,
      'specialtyShopId': instance.specialtyShopId,
      'specialtyShopName': instance.specialtyShopName,
      'sortOrder': instance.sortOrder,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'isActive': instance.isActive,
    };

TourProgressStatsModel _$TourProgressStatsModelFromJson(
        Map<String, dynamic> json) =>
    TourProgressStatsModel(
      totalItems: (json['totalItems'] as num).toInt(),
      completedItems: (json['completedItems'] as num).toInt(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      totalGuests: (json['totalGuests'] as num).toInt(),
      checkedInGuests: (json['checkedInGuests'] as num).toInt(),
      checkInPercentage: (json['checkInPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$TourProgressStatsModelToJson(
        TourProgressStatsModel instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'completedItems': instance.completedItems,
      'progressPercentage': instance.progressPercentage,
      'totalGuests': instance.totalGuests,
      'checkedInGuests': instance.checkedInGuests,
      'checkInPercentage': instance.checkInPercentage,
    };

UserTourProgressResponse _$UserTourProgressResponseFromJson(
        Map<String, dynamic> json) =>
    UserTourProgressResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data:
          UserTourProgressModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserTourProgressResponseToJson(
        UserTourProgressResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ResendQRTicketResultModel _$ResendQRTicketResultModelFromJson(
        Map<String, dynamic> json) =>
    ResendQRTicketResultModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      email: json['email'] as String?,
    );

Map<String, dynamic> _$ResendQRTicketResultModelToJson(
        ResendQRTicketResultModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'sentAt': instance.sentAt?.toIso8601String(),
      'email': instance.email,
    };
