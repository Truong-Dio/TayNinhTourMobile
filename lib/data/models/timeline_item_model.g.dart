// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineItemModel _$TimelineItemModelFromJson(Map<String, dynamic> json) =>
    TimelineItemModel(
      id: json['id'] as String,
      checkInTime: json['checkInTime'] as String,
      activity: json['activity'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completionNotes: json['completionNotes'] as String?,
      specialtyShopModel: json['specialtyShop'] == null
          ? null
          : SpecialtyShopModel.fromJson(
              json['specialtyShop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimelineItemModelToJson(TimelineItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checkInTime': instance.checkInTime,
      'activity': instance.activity,
      'sortOrder': instance.sortOrder,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'completionNotes': instance.completionNotes,
      'specialtyShop': instance.specialtyShopModel,
    };
