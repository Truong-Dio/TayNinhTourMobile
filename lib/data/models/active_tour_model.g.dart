// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_tour_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveTourModel _$ActiveTourModelFromJson(Map<String, dynamic> json) =>
    ActiveTourModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      price: (json['price'] as num).toDouble(),
      maxGuests: (json['maxGuests'] as num).toInt(),
      currentBookings: (json['currentBookings'] as num).toInt(),
      checkedInCount: (json['checkedInCount'] as num).toInt(),
      bookingsCount: (json['bookingsCount'] as num).toInt(),
      status: json['status'] as String,
      tourTemplateModel: TourTemplateModel.fromJson(
          json['tourTemplate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ActiveTourModelToJson(ActiveTourModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'price': instance.price,
      'maxGuests': instance.maxGuests,
      'currentBookings': instance.currentBookings,
      'checkedInCount': instance.checkedInCount,
      'bookingsCount': instance.bookingsCount,
      'status': instance.status,
      'tourTemplate': instance.tourTemplateModel,
    };

TourTemplateModel _$TourTemplateModelFromJson(Map<String, dynamic> json) =>
    TourTemplateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TourTemplateModelToJson(TourTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'description': instance.description,
    };
