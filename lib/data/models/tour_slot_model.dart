/// Tour Slot DTO model
class TourSlotDto {
  final String id;
  final String tourTemplateId;
  final String? tourDetailsId;
  final String tourDate; // DateOnly from backend (YYYY-MM-DD format)
  final String scheduleDay; // ScheduleDay enum string value
  final String scheduleDayName; // Vietnamese day name
  final String status; // TourSlotStatus enum string value
  final String statusName; // Vietnamese status name
  final int? maxGuests;
  final int? currentBookings;
  final int? availableSpots;
  final bool isActive;
  final bool? isBookable;
  final TourTemplateInfo? tourTemplate;
  final TourDetailsInfo? tourDetails;
  final TourOperationInfo? tourOperation;
  final String createdAt;
  final String? updatedAt;
  final String formattedDate; // DD/MM/YYYY format
  final String formattedDateWithDay; // "Thứ bảy - DD/MM/YYYY" format

  TourSlotDto({
    required this.id,
    required this.tourTemplateId,
    this.tourDetailsId,
    required this.tourDate,
    required this.scheduleDay,
    required this.scheduleDayName,
    required this.status,
    required this.statusName,
    this.maxGuests,
    this.currentBookings,
    this.availableSpots,
    required this.isActive,
    this.isBookable,
    this.tourTemplate,
    this.tourDetails,
    this.tourOperation,
    required this.createdAt,
    this.updatedAt,
    required this.formattedDate,
    required this.formattedDateWithDay,
  });

  factory TourSlotDto.fromJson(Map<String, dynamic> json) {
    return TourSlotDto(
      id: json['id'] as String,
      tourTemplateId: json['tourTemplateId'] as String,
      tourDetailsId: json['tourDetailsId'] as String?,
      tourDate: json['tourDate'] as String,
      scheduleDay: json['scheduleDay'] as String,
      scheduleDayName: json['scheduleDayName'] as String,
      status: json['status'] as String,
      statusName: json['statusName'] as String,
      maxGuests: json['maxGuests'] as int?,
      currentBookings: json['currentBookings'] as int?,
      availableSpots: json['availableSpots'] as int?,
      isActive: json['isActive'] as bool,
      isBookable: json['isBookable'] as bool?,
      tourTemplate: json['tourTemplate'] != null
          ? TourTemplateInfo.fromJson(json['tourTemplate'] as Map<String, dynamic>)
          : null,
      tourDetails: json['tourDetails'] != null
          ? TourDetailsInfo.fromJson(json['tourDetails'] as Map<String, dynamic>)
          : null,
      tourOperation: json['tourOperation'] != null
          ? TourOperationInfo.fromJson(json['tourOperation'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      formattedDate: json['formattedDate'] as String,
      formattedDateWithDay: json['formattedDateWithDay'] as String,
    );
  }
}

class TourTemplateInfo {
  final String id;
  final String title;
  final String startLocation;
  final String endLocation;
  final String templateType;

  TourTemplateInfo({
    required this.id,
    required this.title,
    required this.startLocation,
    required this.endLocation,
    required this.templateType,
  });

  factory TourTemplateInfo.fromJson(Map<String, dynamic> json) {
    return TourTemplateInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      templateType: json['templateType'] as String,
    );
  }
}

class TourDetailsInfo {
  final String id;
  final String title;
  final String description;
  final String status;
  final String statusName;

  TourDetailsInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.statusName,
  });

  factory TourDetailsInfo.fromJson(Map<String, dynamic> json) {
    return TourDetailsInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      statusName: json['statusName'] as String,
    );
  }
}

class TourOperationInfo {
  final String id;
  final double price;
  final int maxGuests;
  final int currentBookings;
  final int availableSpots;
  final String status;
  final bool isActive;

  TourOperationInfo({
    required this.id,
    required this.price,
    required this.maxGuests,
    required this.currentBookings,
    required this.availableSpots,
    required this.status,
    required this.isActive,
  });

  factory TourOperationInfo.fromJson(Map<String, dynamic> json) {
    return TourOperationInfo(
      id: json['id'] as String,
      price: (json['price'] as num).toDouble(),
      maxGuests: json['maxGuests'] as int,
      currentBookings: json['currentBookings'] as int,
      availableSpots: json['availableSpots'] as int,
      status: json['status'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}

/// Tour Slots Response model
class TourSlotsResponse {
  final bool success;
  final String message;
  final List<TourSlotDto> data;
  final int totalCount;
  final String? tourDetailsId;
  final String? tourTemplateId;
  final FilterInfo? filters;

  TourSlotsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.totalCount,
    this.tourDetailsId,
    this.tourTemplateId,
    this.filters,
  });

  factory TourSlotsResponse.fromJson(Map<String, dynamic> json) {
    return TourSlotsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => TourSlotDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      tourDetailsId: json['tourDetailsId'] as String?,
      tourTemplateId: json['tourTemplateId'] as String?,
      filters: json['filters'] != null
          ? FilterInfo.fromJson(json['filters'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FilterInfo {
  final String? tourTemplateId;
  final String? tourDetailsId;
  final String? fromDate;
  final String? toDate;
  final int? scheduleDay;
  final bool? includeInactive;

  FilterInfo({
    this.tourTemplateId,
    this.tourDetailsId,
    this.fromDate,
    this.toDate,
    this.scheduleDay,
    this.includeInactive,
  });

  factory FilterInfo.fromJson(Map<String, dynamic> json) {
    return FilterInfo(
      tourTemplateId: json['tourTemplateId'] as String?,
      tourDetailsId: json['tourDetailsId'] as String?,
      fromDate: json['fromDate'] as String?,
      toDate: json['toDate'] as String?,
      scheduleDay: json['scheduleDay'] as int?,
      includeInactive: json['includeInactive'] as bool?,
    );
  }
}

/// Tour Slot Data for UI (simplified)
class TourSlotData {
  final String id;
  final String tourDate;
  final String scheduleDayName;
  final String status; // Use status instead of statusName for compatibility
  final String statusName;
  final int? maxGuests;
  final int? currentBookings;
  final int? availableSpots;
  final bool isActive;
  final bool? isBookable;
  final String formattedDate;
  final String formattedDateWithDay;

  TourSlotData({
    required this.id,
    required this.tourDate,
    required this.scheduleDayName,
    required this.status,
    required this.statusName,
    this.maxGuests,
    this.currentBookings,
    this.availableSpots,
    required this.isActive,
    this.isBookable,
    required this.formattedDate,
    required this.formattedDateWithDay,
  });

  factory TourSlotData.fromDto(TourSlotDto dto) {
    return TourSlotData(
      id: dto.id,
      tourDate: dto.tourDate,
      scheduleDayName: dto.scheduleDayName,
      status: dto.status, // Use status enum string
      statusName: dto.statusName,
      maxGuests: dto.maxGuests,
      currentBookings: dto.currentBookings,
      availableSpots: dto.availableSpots,
      isActive: dto.isActive,
      isBookable: dto.isBookable,
      formattedDate: dto.formattedDate,
      formattedDateWithDay: dto.formattedDateWithDay,
    );
  }
}
