import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/active_tour.dart';

part 'active_tour_model.g.dart';

@JsonSerializable()
class ActiveTourModel extends ActiveTour {
  @JsonKey(name: 'tourTemplate')
  final TourTemplateModel tourTemplateModel;

  const ActiveTourModel({
    required super.id,
    required super.tourDetailsId,
    required super.title,
    super.description,
    required super.startDate,
    required super.endDate,
    required super.price,
    required super.maxGuests,
    required super.currentBookings,
    required super.checkedInCount,
    required super.bookingsCount,
    required super.status,
    required this.tourTemplateModel,
  }) : super(tourTemplate: tourTemplateModel);

  factory ActiveTourModel.fromJson(Map<String, dynamic> json) => _$ActiveTourModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTourModelToJson(this);

  ActiveTour toEntity() {
    return ActiveTour(
      id: id,
      tourDetailsId: tourDetailsId,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      price: price,
      maxGuests: maxGuests,
      currentBookings: currentBookings,
      checkedInCount: checkedInCount,
      bookingsCount: bookingsCount,
      status: status,
      tourTemplate: tourTemplateModel.toEntity(),
    );
  }
}

@JsonSerializable()
class TourTemplateModel extends TourTemplate {
  const TourTemplateModel({
    required super.id,
    required super.title,
    required super.startLocation,
    required super.endLocation,
    super.description,
  });
  
  factory TourTemplateModel.fromJson(Map<String, dynamic> json) => _$TourTemplateModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TourTemplateModelToJson(this);
  
  TourTemplate toEntity() {
    return TourTemplate(
      id: id,
      title: title,
      startLocation: startLocation,
      endLocation: endLocation,
      description: description,
    );
  }
}
