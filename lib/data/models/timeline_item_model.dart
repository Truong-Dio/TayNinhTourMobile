import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/timeline_item.dart';
import 'specialty_shop_model.dart' show SpecialtyShopModel;

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
  }) : super(specialtyShop: null);

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
      specialtyShop: specialtyShopModel != null ? SpecialtyShop(
        id: specialtyShopModel!.id,
        shopName: specialtyShopModel!.shopName ?? '',
        address: specialtyShopModel!.address ?? '',
        description: specialtyShopModel!.description,
      ) : null,
    );
  }
}
