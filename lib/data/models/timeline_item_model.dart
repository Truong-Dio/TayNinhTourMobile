import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/timeline_item.dart';

part 'timeline_item_model.g.dart';

@JsonSerializable()
class TimelineItemModel extends TimelineItem {
  @JsonKey(name: 'specialtyShop')
  final SpecialtyShopModel? specialtyShopModel;

  const TimelineItemModel({
    required super.id,
    required super.checkInTime,
    required super.activity,
    required super.sortOrder,
    required super.isCompleted,
    super.completedAt,
    super.completionNotes,
    this.specialtyShopModel,
  }) : super(specialtyShop: specialtyShopModel);

  factory TimelineItemModel.fromJson(Map<String, dynamic> json) => _$TimelineItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineItemModelToJson(this);

  TimelineItem toEntity() {
    return TimelineItem(
      id: id,
      checkInTime: checkInTime,
      activity: activity,
      sortOrder: sortOrder,
      isCompleted: isCompleted,
      completedAt: completedAt,
      completionNotes: completionNotes,
      specialtyShop: specialtyShopModel?.toEntity(),
    );
  }
}

@JsonSerializable()
class SpecialtyShopModel extends SpecialtyShop {
  const SpecialtyShopModel({
    required super.id,
    required super.shopName,
    required super.address,
    super.description,
  });
  
  factory SpecialtyShopModel.fromJson(Map<String, dynamic> json) => _$SpecialtyShopModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$SpecialtyShopModelToJson(this);
  
  SpecialtyShop toEntity() {
    return SpecialtyShop(
      id: id,
      shopName: shopName,
      address: address,
      description: description,
    );
  }
}
