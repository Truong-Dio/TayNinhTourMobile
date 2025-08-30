import 'package:equatable/equatable.dart';

/// Active Tour entity
class ActiveTour extends Equatable {
  final String id;
  final String tourDetailsId;
  final String title;
  final String? description;
  final List<String> imageUrls;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final int maxGuests;
  final int currentBookings;
  final int checkedInCount;
  final int bookingsCount;
  final String status;
  final TourTemplate tourTemplate;
  final TourSlot? currentSlot;

  const ActiveTour({
    required this.id,
    required this.tourDetailsId,
    required this.title,
    this.description,
    this.imageUrls = const [],
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.maxGuests,
    required this.currentBookings,
    required this.checkedInCount,
    required this.bookingsCount,
    required this.status,
    required this.tourTemplate,
    this.currentSlot,
  });
  
  @override
  List<Object?> get props => [
    id,
    tourDetailsId,
    title,
    description,
    imageUrls,
    startDate,
    endDate,
    price,
    maxGuests,
    currentBookings,
    checkedInCount,
    bookingsCount,
    status,
    tourTemplate,
    currentSlot,
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

/// Tour Slot entity
class TourSlot extends Equatable {
  final String id;
  final String tourDate;
  final int maxGuests;
  final int currentBookings;
  final String status;

  const TourSlot({
    required this.id,
    required this.tourDate,
    required this.maxGuests,
    required this.currentBookings,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    tourDate,
    maxGuests,
    currentBookings,
    status,
  ];
}
