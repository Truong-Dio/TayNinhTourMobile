import 'package:equatable/equatable.dart';

/// Timeline Item entity
class TimelineItem extends Equatable {
  final String id;
  final String checkInTime;
  final String activity;
  final int sortOrder;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completionNotes;
  final SpecialtyShop? specialtyShop;
  
  const TimelineItem({
    required this.id,
    required this.checkInTime,
    required this.activity,
    required this.sortOrder,
    required this.isCompleted,
    this.completedAt,
    this.completionNotes,
    this.specialtyShop,
  });
  
  @override
  List<Object?> get props => [
    id,
    checkInTime,
    activity,
    sortOrder,
    isCompleted,
    completedAt,
    completionNotes,
    specialtyShop,
  ];
}

/// Specialty Shop entity
class SpecialtyShop extends Equatable {
  final String id;
  final String shopName;
  final String address;
  final String? description;
  
  const SpecialtyShop({
    required this.id,
    required this.shopName,
    required this.address,
    this.description,
  });
  
  @override
  List<Object?> get props => [
    id,
    shopName,
    address,
    description,
  ];
}
