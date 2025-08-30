// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty_shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecialtyShopModel _$SpecialtyShopModelFromJson(Map<String, dynamic> json) =>
    SpecialtyShopModel(
      id: json['id'] as String,
      shopName: json['shopName'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      representativeName: json['representativeName'] as String?,
      openingHours: json['openingHours'] as String?,
      notes: json['notes'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      shopType: json['shopType'] as String?,
      isActive: json['isShopActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SpecialtyShopModelToJson(SpecialtyShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopName': instance.shopName,
      'description': instance.description,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'representativeName': instance.representativeName,
      'openingHours': instance.openingHours,
      'notes': instance.notes,
      'rating': instance.rating,
      'shopType': instance.shopType,
      'isShopActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
