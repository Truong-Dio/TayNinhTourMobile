import 'package:json_annotation/json_annotation.dart';

part 'specialty_shop_model.g.dart';

/// Specialty shop model
@JsonSerializable()
class SpecialtyShopModel {
  final String id;
  final String shopName;
  final String? description;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? representativeName;
  final String? openingHours;
  final String? notes;
  final double? rating;
  final String shopType;
  @JsonKey(name: 'isShopActive')
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SpecialtyShopModel({
    required this.id,
    required this.shopName,
    this.description,
    this.address,
    this.phoneNumber,
    this.email,
    this.website,
    this.representativeName,
    this.openingHours,
    this.notes,
    this.rating,
    required this.shopType,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory SpecialtyShopModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyShopModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialtyShopModelToJson(this);

  /// Get display name for the shop
  String get displayName => shopName;

  /// Get contact info summary
  String get contactInfo {
    final parts = <String>[];
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      parts.add('📞 $phoneNumber');
    }
    if (email != null && email!.isNotEmpty) {
      parts.add('📧 $email');
    }
    return parts.join(' • ');
  }

  /// Get rating display
  String get ratingDisplay {
    if (rating == null) return 'Chưa có đánh giá';
    return '⭐ ${rating!.toStringAsFixed(1)}';
  }

  /// Check if shop has complete contact info
  bool get hasCompleteContactInfo {
    return phoneNumber != null && 
           phoneNumber!.isNotEmpty && 
           address != null && 
           address!.isNotEmpty;
  }
}
