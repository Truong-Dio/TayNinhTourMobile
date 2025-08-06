import 'package:equatable/equatable.dart';

/// Tour Incident entity
class TourIncident extends Equatable {
  final String id;
  final String tourOperationId;
  final String title;
  final String description;
  final String severity;
  final String status;
  final List<String>? imageUrls;
  final DateTime reportedAt;
  final String? adminNotes;
  final DateTime? processedAt;
  final DateTime? resolvedAt;
  
  const TourIncident({
    required this.id,
    required this.tourOperationId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.imageUrls,
    required this.reportedAt,
    this.adminNotes,
    this.processedAt,
    this.resolvedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    tourOperationId,
    title,
    description,
    severity,
    status,
    imageUrls,
    reportedAt,
    adminNotes,
    processedAt,
    resolvedAt,
  ];
}
