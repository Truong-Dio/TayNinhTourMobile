import 'package:json_annotation/json_annotation.dart';

part 'unified_checkin_models.g.dart';

/// ✅ NEW: Unified request model for check-in bằng QR code
/// Tự động nhận diện loại QR (Individual Guest hoặc Group Representative)
@JsonSerializable()
class UnifiedCheckInRequest {
  /// Raw QR code data được scan từ mobile app
  /// Backend sẽ tự parse và nhận diện loại QR
  final String qrCodeData;

  /// ID của tour slot hiện tại (để validation)
  final String tourSlotId;

  /// Ghi chú bổ sung khi check-in (tùy chọn)
  final String? notes;

  /// Override thời gian check-in (cho phép check-in sớm/muộn)
  /// Mặc định: false - chỉ cho phép check-in trong khung thời gian hợp lệ
  final bool overrideTimeRestriction;

  /// Lý do override thời gian (bắt buộc nếu overrideTimeRestriction = true)
  final String? overrideReason;

  /// Cho phép check-in một phần nhóm (chỉ áp dụng cho Group QR)
  /// Default: true
  final bool allowPartialCheckIn;

  /// Danh sách ID của các khách cụ thể cần check-in (chỉ áp dụng cho Group QR)
  /// Nếu null hoặc empty, sẽ check-in toàn bộ khách trong booking
  final List<String>? specificGuestIds;

  const UnifiedCheckInRequest({
    required this.qrCodeData,
    required this.tourSlotId,
    this.notes,
    this.overrideTimeRestriction = false,
    this.overrideReason,
    this.allowPartialCheckIn = true,
    this.specificGuestIds,
  });

  factory UnifiedCheckInRequest.fromJson(Map<String, dynamic> json) =>
      _$UnifiedCheckInRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UnifiedCheckInRequestToJson(this);
}

/// ✅ NEW: Unified response model for check-in bằng QR code
/// Chứa thông tin phù hợp cho cả Individual Guest và Group Representative
@JsonSerializable()
class UnifiedCheckInResponse {
  final int statusCode;
  final String message;
  final bool success;

  /// Loại QR code được nhận diện
  /// "Individual" hoặc "Group"
  final String qrType;

  /// Booking code liên quan
  final String? bookingCode;

  /// Thời gian check-in
  final DateTime? checkInTime;

  /// Số lượng khách đã check-in thành công
  final int checkedInCount;

  /// Tổng số khách trong booking
  final int totalGuestCount;

  /// Check-in có hoàn toàn thành công không
  /// (tất cả khách trong booking đã check-in)
  final bool isCompleteCheckIn;

  /// Thông tin chi tiết cho Individual Guest check-in
  /// Chỉ có giá trị khi qrType = "Individual"
  final IndividualGuestInfo? individualGuest;

  /// Thông tin chi tiết cho Group check-in
  /// Chỉ có giá trị khi qrType = "Group"
  final GroupCheckInInfo? groupInfo;

  /// Danh sách khách đã check-in trong lần này
  final List<CheckedInGuestInfo> checkedInGuests;

  const UnifiedCheckInResponse({
    required this.statusCode,
    required this.message,
    required this.success,
    required this.qrType,
    this.bookingCode,
    this.checkInTime,
    required this.checkedInCount,
    required this.totalGuestCount,
    required this.isCompleteCheckIn,
    this.individualGuest,
    this.groupInfo,
    required this.checkedInGuests,
  });

  factory UnifiedCheckInResponse.fromJson(Map<String, dynamic> json) =>
      _$UnifiedCheckInResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnifiedCheckInResponseToJson(this);
}

/// Thông tin chi tiết cho Individual Guest check-in
@JsonSerializable()
class IndividualGuestInfo {
  final String guestId;
  final String guestName;
  final String? guestEmail;
  final String? guestPhone;
  final DateTime checkInTime;
  final String? checkInNotes;

  const IndividualGuestInfo({
    required this.guestId,
    required this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.checkInTime,
    this.checkInNotes,
  });

  factory IndividualGuestInfo.fromJson(Map<String, dynamic> json) =>
      _$IndividualGuestInfoFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualGuestInfoToJson(this);
}

/// Thông tin chi tiết cho Group check-in
@JsonSerializable()
class GroupCheckInInfo {
  final String bookingId;
  final String bookingCode;
  final String? groupName;
  final int totalGuests;
  final int checkedInGuests;
  final String? contactName;
  final String? contactEmail;
  final DateTime checkInTime;
  final bool isPartialCheckIn;

  const GroupCheckInInfo({
    required this.bookingId,
    required this.bookingCode,
    this.groupName,
    required this.totalGuests,
    required this.checkedInGuests,
    this.contactName,
    this.contactEmail,
    required this.checkInTime,
    required this.isPartialCheckIn,
  });

  factory GroupCheckInInfo.fromJson(Map<String, dynamic> json) =>
      _$GroupCheckInInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GroupCheckInInfoToJson(this);
}

/// Thông tin khách đã check-in
@JsonSerializable()
class CheckedInGuestInfo {
  final String guestId;
  final String guestName;
  final String? guestEmail;
  final bool isGroupRepresentative;
  final DateTime checkInTime;
  final String? checkInNotes;

  const CheckedInGuestInfo({
    required this.guestId,
    required this.guestName,
    this.guestEmail,
    required this.isGroupRepresentative,
    required this.checkInTime,
    this.checkInNotes,
  });

  factory CheckedInGuestInfo.fromJson(Map<String, dynamic> json) =>
      _$CheckedInGuestInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckedInGuestInfoToJson(this);
}
