import 'package:equatable/equatable.dart';

/// Active Tour entity
class ActiveTour extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final int maxGuests;
  final int currentBookings;
  final int checkedInCount;
  final int bookingsCount;
  final String status;
  final TourTemplate tourTemplate;
  
  const ActiveTour({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.maxGuests,
    required this.currentBookings,
    required this.checkedInCount,
    required this.bookingsCount,
    required this.status,
    required this.tourTemplate,
  });
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDate,
    endDate,
    price,
    maxGuests,
    currentBookings,
    checkedInCount,
    bookingsCount,
    status,
    tourTemplate,
  ];
}

/// Tour Template entity
class TourTemplate extends Equatable {
  final String id;
  final String title;
  final String startLocation;
  final String endLocation;
  final String? description;
  
  const TourTemplate({
    required this.id,
    required this.title,
    required this.startLocation,
    required this.endLocation,
    this.description,
  });
  
  @override
  List<Object?> get props => [
    id,
    title,
    startLocation,
    endLocation,
    description,
  ];
}
