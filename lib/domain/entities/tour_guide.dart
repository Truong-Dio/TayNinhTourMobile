import 'package:equatable/equatable.dart';

/// Tour Guide entity
class TourGuide extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String? experience;
  final String? skills;
  final double rating;
  final int totalToursGuided;
  final bool isAvailable;
  final String? notes;
  final String? profileImageUrl;
  final DateTime? approvedAt;
  
  const TourGuide({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.experience,
    this.skills,
    required this.rating,
    required this.totalToursGuided,
    required this.isAvailable,
    this.notes,
    this.profileImageUrl,
    this.approvedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    phoneNumber,
    email,
    experience,
    skills,
    rating,
    totalToursGuided,
    isAvailable,
    notes,
    profileImageUrl,
    approvedAt,
  ];
}
